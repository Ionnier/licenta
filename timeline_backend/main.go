package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	_ "github.com/mattn/go-sqlite3"
	"github.com/streadway/amqp"
)

var dbsPath = path.Join(path.Dir("."), "dbs")

func main() {
	godotenv.Load(".env")

	log.Println(os.Getenv("STORAGE_DOMAIN"))

	err := os.Mkdir(dbsPath, fs.ModeDir)
	if err != nil {
		fmt.Println(err)
	}
	amqpServer := os.Getenv("AMQP_SERVER")
	if len(strings.TrimSpace(amqpServer)) == 0 {
		amqpServer = "amqp://localhost:5672"
	}

	conn, err := amqp.Dial(amqpServer)
	if err != nil {
		log.Println("Failed Initializing Broker Connection")
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		log.Printf("Failed Initializing Broker Connection %v", err)
	}
	defer ch.Close()

	if _, err := ch.QueueDeclare("test_queue", true, true, false, false, nil); err != nil {
		log.Printf("Failed queue %v", err)
	}

	msgs, err := ch.Consume(
		"test_queue",
		"test_queue",
		true,
		false,
		false,
		false,
		nil,
	)

	if err != nil {
		log.Printf("Error channel %v", err)
	}

	go func() {
		for d := range msgs {
			fmt.Printf("Received Message: %s\n", d.Body)
		}
	}()

	app := fiber.New()

	fmt.Println("Successfully Connected to our RabbitMQ Instance")

	db, err := sql.Open("sqlite3", "db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	_, err = db.ExecContext(
		context.TODO(),
		"create table persons(id_person INT PRIMARY KEY, name text, email text, last_updated INT)",
	)
	if err != nil {
		log.Print(err)
	}

	_, err = db.ExecContext(
		context.TODO(),
		"create table friend_list(id_person1 INT , id_person2 INT, PRIMARY KEY(id_person1, id_person2), constraint diff check(id_person1 <> id_person2))",
	)
	if err != nil {
		log.Print(err)
	}

	_, err = db.ExecContext(
		context.TODO(),
		"create table activities(id_person text, comment text, startsAt int, endsAt int, PRIMARY KEY(id_person, startsAt))",
	)

	if err != nil {
		log.Print(err)
	}

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Get("/timeline/friends", protect, func(c *fiber.Ctx) error {
		id := fmt.Sprint(c.Locals("id"))
		if list, err := getFriends(db, id); err != nil {
			return c.JSON(err)
		} else {
			return c.JSON(newResponse("Friends", list))
		}
	})

	app.Get("/timeline/", protect, func(c *fiber.Ctx) error {
		id := fmt.Sprint(c.Locals("id"))
		if list, err := getFriends(db, id); err != nil {
			return c.JSON(err)
		} else {
			for _, friend := range list {
				syncUser(db, friend)
			}
			if data, err := getTimelineData(db, list); err != nil {
				return c.SendStatus(418)
			} else {
				return c.JSON(newResponse("Timeline", data))
			}
			// return c.JSON(newResponse("Friends", list))
		}
	})

	app.Post("/timeline/friends", protect, func(c *fiber.Ctx) error {
		id := fmt.Sprint(c.Locals("id"))
		log.Printf("Add friend for %v", id)
		var b map[string]string

		if err := json.Unmarshal(c.Body(), &b); err != nil {
			return err
		}

		friendId := b["friendId"]
		if len(friendId) == 0 {
			return c.Status(400).JSON(newResponse("No friend specified"))
		}

		if err := addFriend(db, id, friendId); err != nil {
			log.Print(err)
			return c.JSON(err)
		}
		return c.SendStatus(200)

	})

	port := os.Getenv("PORT")
	if len(strings.TrimSpace(port)) == 0 {
		port = "3000"
	}

	if err := app.Listen(fmt.Sprintf(":%s", port)); err != nil {
		log.Fatal(err)
	}

}

type timelinedata struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Comment  string `json:"comment"`
	StartsAt int    `json:"startsAt"`
	EndsAt   int    `json:"endsAt"`
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
