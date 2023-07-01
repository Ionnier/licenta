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
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/joho/godotenv"

	_ "github.com/mattn/go-sqlite3"
	"github.com/streadway/amqp"
)

var dbsPath = path.Join(path.Dir("."), "dbs")

func main() {
	godotenv.Load(".env")

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

	if err := ch.ExchangeDeclare(
		"test_exchange", // name
		"fanout",        // type
		true,            // durable
		false,           // auto-deleted
		false,           // internal
		false,           // no-wait
		nil,             // arguments
	); err != nil {
		log.Println(err)
	}

	q, err := ch.QueueDeclare(
		"",    // name
		false, // durable
		false, // delete when unused
		true,  // exclusive
		false, // no-wait
		nil,   // arguments
	)

	if err != nil {
		log.Fatal(err)
	}

	err = ch.QueueBind(
		q.Name,          // queue name
		"",              // routing key
		"test_exchange", // exchange
		false,
		nil,
	)

	if err != nil {
		log.Fatal(err)
	}

	msgs, err := ch.Consume(
		q.Name,
		"",
		true,  // auto-ack
		false, // exclusive
		false, // no-local
		false, // no-wait
		nil,   // args
	)

	if err != nil {
		log.Printf("Error channel %v", err)
	}

	db, err := sql.Open("sqlite3", path.Join(os.Getenv("DB_DIRECTORY"), "db"))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	go func() {
		for d := range msgs {
			fmt.Printf("Received Message: %s\n", d.Body)
			message := string(d.Body)

			splits := strings.Split(message, " ")
			if len(splits) != 2 {
				return
			}

			id := splits[0]
			action := splits[1]

			if action == "ACCOUNT_UPDATE" {
				if data, err := getUserInfo(id); err != nil {
					log.Println(err)
				} else {
					log.Print(data)
					if rows, err := db.ExecContext(context.TODO(), fmt.Sprintf("update persons set name = '%v', email = '%v', image_url = '%v'  where id_person = '%v'", data.Data.UserName, data.Data.UserEmail, data.Data.ImageURL, id)); err != nil {
						log.Print(err)
					} else {
						if nr, _ := rows.RowsAffected(); nr == 0 {
							log.Println("No rows updated")
							if _, err := db.ExecContext(context.TODO(), fmt.Sprintf("insert into persons values('%v', '%v', '%v', '%v', %v)", data.Data.ID, data.Data.UserName, data.Data.UserEmail, data.Data.ImageURL, time.Now().UTC().Unix())); err != nil {
								log.Print(err)
							}
						}
					}
				}
			}
		}
	}()

	app := fiber.New()

	fmt.Println("Successfully Connected to our RabbitMQ Instance")
	app.Use(logger.New())

	_, err = db.ExecContext(
		context.TODO(),
		"create table persons(id_person text PRIMARY KEY, name text, email text, image_url text, last_updated INT)",
	)
	if err != nil {
		log.Print(err)
	}

	_, err = db.ExecContext(
		context.TODO(),
		"create table friend_list(id_person1 text , id_person2 text, PRIMARY KEY(id_person1, id_person2), constraint diff check(id_person1 <> id_person2))",
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

	app.Get("/timeline/friends/:id/", func(c *fiber.Ctx) error {
		id := c.Params("id")
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

	app.Get("/timeline/of/:id/", func(c *fiber.Ctx) error {
		id := c.Params("id")
		syncUser(db, id)
		list := []string{id}
		if data, err := getTimelineData(db, list); err != nil {
			return c.SendStatus(418)
		} else {
			return c.JSON(newResponse("Timeline", data))
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
	ImageUrl string `json:"imageUrl"`
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
