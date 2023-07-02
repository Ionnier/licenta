package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
)

func syncDb(originalDb *sql.DB, filePath string, userId string) error {
	log.Printf("Start sync db %v %v", filePath, userId)
	var transcation *sql.Tx
	var err error
	if transcation, err = originalDb.BeginTx(context.TODO(), nil); err != nil {
		log.Print(err)
		transcation.Rollback()
		return err
	}
	if _, err := transcation.Exec("delete from activities where id_person = ?", userId); err != nil {
		log.Print(err)
	}

	db, err := sql.Open("sqlite3", filePath)
	if err != nil {
		log.Print(err)
		transcation.Rollback()
		return err
	}
	if rows, err := db.QueryContext(context.TODO(), "select ifnull(comment, ''), ifnull(startedAt, createdAt) \"starts\", timeSpent  from activities"); err != nil {
		log.Print(err)
		transcation.Rollback()
		return err
	} else {
		defer rows.Close()
		for rows.Next() {
			var comment string
			var startsAt int
			var endsAt int
			err = rows.Scan(&comment, &startsAt, &endsAt)
			if err != nil {
				log.Println(err)
				continue
			}
			endsAt += startsAt
			if _, err := transcation.Exec("insert into activities(id_person, comment, startsAt, endsAt) values (?, ?, ?, ?)", userId, comment, startsAt, endsAt); err != nil {
				log.Println(err)
			}
		}
	}
	defer db.Close()
	log.Print("Start transaction")
	return transcation.Commit()
}

func syncUser(originalDb *sql.DB, user string, canSkip bool) error {
	log.Printf("Start user sync %v", user)
	rows, err := originalDb.QueryContext(context.TODO(), "select last_updated from persons where id_person = ?", user)
	if err != nil {
		return err
	}
	defer rows.Close()
	var last_updated int64
	if rows.Next() {
		rows.Scan(&last_updated)
		log.Printf("User updated at %v", last_updated)
		if canSkip && (last_updated + 60*30) > time.Now().UTC().Unix() {
			log.Printf("Skip update")
			return nil
		}
	} else {
		log.Println("User does not used this service")
		return nil
	}
	file, err := getUserDb(user)
	if err != nil {
		return err
	}
	if err := syncDb(originalDb, file, user); err == nil {
		if data, err := getUserInfo(user); err != nil {
			log.Println(err)
			return err
		} else {
			if res, err := originalDb.ExecContext(context.TODO(), fmt.Sprintf("insert into persons values('%v', '%v', '%v', '%v', %v)", user, data.Data.UserName, data.Data.UserEmail, data.Data.ImageURL, time.Now().UTC().Unix())); err != nil {
				log.Print(err)
				nr, _ := res.RowsAffected()
				log.Println(nr)
				if _, err := originalDb.ExecContext(context.TODO(), "update persons set last_updated = ? where id_person = ?", time.Now().UTC().Unix(), user); err != nil {
					log.Print(err)
					return err
				} else {
					return nil
				}
			}
			return nil
		}

	} else {
		return err
	}
}

func getUserDb(user string) (string, error) {
	log.Printf("Start user get db %v", user)
	a := fiber.AcquireAgent()
	req := a.Request()
	req.Header.SetMethod(fiber.MethodGet)
	req.SetRequestURI(fmt.Sprintf("%v/storage/getdb/%v", os.Getenv("STORAGE_DOMAIN"), user))

	if err := a.Parse(); err != nil {
		panic(err)
	}

	status, bytes, errs := a.Bytes()
	log.Printf("Start user get db status %v", status)
	if status != 200 {
		log.Println(errs)
		return "", errors.New("there was an error getting the db")
	}
	os.Remove(user)
	if file, err := os.Create(user); err != nil {
		log.Print(err)
		return "", err
	} else {
		_, err := file.Write(bytes)
		if err != nil {
			log.Print(err)
		}
		log.Printf("File written %v", user)
		return user, nil
	}
}

type AutoGenerated struct {
	Message string `json:"message"`
	Data    struct {
		ID           string `json:"id"`
		UserName     string `json:"userName"`
		UserEmail    string `json:"userEmail"`
		UserPassword string `json:"userPassword"`
		CreatedDate  int    `json:"createdDate"`
		UpdatedDate  int    `json:"updatedDate"`
		ImageURL     string `json:"imageUrl"`
	} `json:"data"`
}

func getUserInfo(user string) (AutoGenerated, error) {
	log.Printf("Start get user info %v", user)
	var asd AutoGenerated

	a := fiber.AcquireAgent()
	req := a.Request()
	req.Header.SetMethod(fiber.MethodGet)
	req.SetRequestURI(fmt.Sprintf("%v/api/users/%v/", os.Getenv("AUTH_DOMAIN"), user))

	if err := a.Parse(); err != nil {
		panic(err)
	}

	status, bytes, errs := a.Bytes()

	log.Printf("Start get user info status %v", status)
	if status != 200 {
		log.Println(errs)
		return asd, errors.New("there was an error getting the info")
	}

	if err := json.Unmarshal(bytes, &asd); err != nil {
		return asd, err
	}
	return asd, nil
}
