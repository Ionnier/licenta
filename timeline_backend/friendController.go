package main

import (
	"context"
	"database/sql"
	"log"
	"strings"
)

func addFriend(originalDb *sql.DB, firstId string, secondId string) error {
	log.Printf("Add friend %v and %v", firstId, secondId)
	_, err := originalDb.ExecContext(context.TODO(), "insert into friend_list values(?, ?)", firstId, secondId)
	return err
}

func getFriends(originalDb *sql.DB, user_id string) ([]string, error) {
	rows, err := originalDb.QueryContext(context.TODO(), "select * from friend_list where id_person1=? or id_person2=?", user_id, user_id)
	asd := make([]string, 0)
	if err != nil {
		return asd, err
	}
	for rows.Next() {
		var firstId string
		var seconId string
		err = rows.Scan(&firstId, &seconId)
		if err != nil {
			log.Println(err)
			continue
		}
		if firstId != user_id {
			asd = append(asd, firstId)
		} else {
			asd = append(asd, seconId)
		}
	}
	return unique(asd), nil
}

func unique(arr []string) []string {
	occurred := map[string]bool{}
	result := []string{}
	for es := range arr {
		e := strings.TrimSpace(arr[es])
		// check if already the mapped
		// variable is set to true or not
		if !occurred[e] {
			occurred[e] = true

			// Append to result slice.
			result = append(result, e)
		}
	}
	return result
}
