package main

import (
	"context"
	"database/sql"
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
		return err
	}
	if _, err := transcation.Exec("delete from activities where id_person = ?", userId); err != nil {
		log.Print(err)
	}

	db, err := sql.Open("sqlite3", filePath)
	if err != nil {
		log.Print(err)
		return err
	}
	if rows, err := db.QueryContext(context.TODO(), "select ifnull(comment, ''), ifnull(startedAt, createdAt) \"starts\", timeSpent  from activities"); err != nil {
		log.Print(err)
		return err
	} else {
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

func syncUser(originalDb *sql.DB, user string) error {
	log.Printf("Start user sync %v", user)
	rows, err := originalDb.QueryContext(context.TODO(), "select last_updated from persons where id_person = ?", user)
	if err != nil {
		return err
	}
	var last_updated int64
	if rows.Next() {
		rows.Scan(&last_updated)
		log.Printf("User updated at %v", last_updated)
		if (last_updated + 60*30) > time.Now().UTC().Unix() {
			log.Printf("Skip update")
			return nil
		}
	}
	file, err := getUserDb(user)
	if err != nil {
		return err
	}
	if err := syncDb(originalDb, file, user); err == nil {
		if _, err := originalDb.ExecContext(context.TODO(), "insert into persons values(?, ?)", user, time.Now().UTC().Unix()); err != nil {
			log.Print(err)
			return err
		}
		return nil
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
