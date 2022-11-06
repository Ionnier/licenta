package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/mongo"
)

func init() {

	err := godotenv.Load(".env")

	if err != nil {
		log.Println("Error loading .env file")
	}

	assertOsEnvKey("MONGO_USERNAME")
	assertOsEnvKey("MONGO_PASSWORD")
	assertOsEnvKey("MONGO_HOSTNAME")
	hostname := []rune(os.Getenv("MONGO_HOSTNAME"))
	if string(hostname[len(hostname)-1]) != "/" {
		log.Fatalf("MONGO_HOSTNAME should end with /")
	}
	assertOsEnvKey("JWT_SECRET_KEY")

	testConnection()

}

func assertOsEnvKey(key string) {
	if _, err := os.LookupEnv(key); !err {
		log.Fatalf("%s required and doesn't exist", key)
	}
}

func main() {
	app := fiber.New(fiber.Config{
		ErrorHandler: customErrorHandler,
	})

	app.Use(logger.New())

	app.Post("/api/signup", func(c *fiber.Ctx) error {
		userInfo := new(user)

		if err := c.BodyParser(userInfo); err != nil {
			return err
		}

		userData, err := handleSignup(userInfo.UserEmail, userInfo.UserPassword)

		if err != nil {
			return err
		}

		return c.Status(fiber.StatusOK).JSON(newResponse("User created", userData))
	})

	app.Post("/api/login", func(c *fiber.Ctx) error {
		userInfo := new(user)

		if err := c.BodyParser(userInfo); err != nil {
			return err
		}

		userData, err := handleLogin(*userInfo)

		if err != nil {
			if err == mongo.ErrNoDocuments {
				return fiber.NewError(fiber.ErrTeapot.Code, "User name or password is incorrect")
			}
			return err
		}

		token := generateToken(*userData)

		return c.Status(fiber.StatusOK).JSON(newResponse("User logged in", token))
	})

	app.Patch("/api/updateSelf", protect, func(c *fiber.Ctx) error {
		userData, _ := c.Locals("userData").(user)

		newUserData := new(user)

		if err := c.BodyParser(newUserData); err != nil {
			return err
		}

		log.Printf("%s %s", userData.UserName, newUserData.UserName)
		if userData.UserName == newUserData.UserName {
			return fiber.NewError(fiber.ErrBadRequest.Code, "No data will be changed")
		}

		userData.UserName = newUserData.UserName

		err := updateUser(userData)

		if err != nil {
			return err
		}

		return c.Status(fiber.StatusOK).JSON(newResponse("User updated"))
	})

	app.Get("/api/self", protect, func(c *fiber.Ctx) error {
		userData, _ := c.Locals("userData").(user)
		freshData, err := findUser(userData)
		if err != nil {
			return err
		}
		return c.Status(fiber.StatusOK).JSON(newResponse("User info", freshData))
	})

	app.Post("/api/updatePassword", protect, func(c *fiber.Ctx) error {
		var b map[string]string

		if err := json.Unmarshal(c.Body(), &b); err != nil {
			return err
		}

		var newPassword = ""
		var currentPassword = ""

		if val, ok := b["currentPassword"]; ok {
			currentPassword = val
		}

		if val, ok := b["newPassword"]; ok {
			newPassword = val
		}

		userData, _ := c.Locals("userData").(user)

		if err := changePassword(userData.UserEmail, currentPassword, newPassword); err != nil {
			return err
		}

		return c.Status(fiber.StatusOK).JSON(newResponse("Password updated."))
	})

	app.Listen("0.0.0.0:3000")
}

type response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

func newResponse(message string, b ...interface{}) response {
	if len(b) == 0 {
		return response{
			Message: message}
	}
	return response{
		Message: message,
		Data:    b[0]}
}

func customErrorHandler(ctx *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	message := "Internal Server Error"

	switch t := err.(type) {
	case *fiber.Error:
		code = t.Code
		message = t.Message
	case error:
		message = fmt.Sprint(t)
	}

	err = ctx.Status(code).JSON(newResponse(message))

	if err != nil {
		log.Println(err)
	}

	return nil
}