package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
)

type profileData struct {
	Owner    UserInfo          `json:"owner"`
	Timeline []timelineElement `json:"timeline"`
	Profiles []UserInfo        `json:"profiles"`
}

func main() {
	godotenv.Load(".env")

	app := fiber.New()

	app.Get("/profile/:id/", func(c *fiber.Ctx) error {
		id := c.Params("id")
		userInfo := make([]UserInfo, 0)
		var err error
		var profile UserInfo

		profile, err = getUserDataOf(id)
		if err != nil {
			return err
		}

		if friends, err := getFriendsOf(id); err != nil {
			log.Println(err)
		} else {
			if len(friends) > 0 {
				userInfo, err = getUserDataOfList(friends)
				if err != nil {
					log.Println(err)
				}
			}
		}

		timelineData, _ := getTimelineOf(id)
		sdf := new(profileData)
		sdf.Profiles = userInfo
		sdf.Timeline = timelineData
		sdf.Owner = profile
		return c.Status(fiber.StatusOK).JSON(sdf)

	})

	port := os.Getenv("PORT")
	if len(strings.TrimSpace(port)) == 0 {
		port = "3000"
	}

	if err := app.Listen(fmt.Sprintf(":%s", port)); err != nil {
		log.Fatal(err)
	}

}
