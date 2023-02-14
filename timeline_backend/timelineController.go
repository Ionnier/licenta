package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"strings"
)

func getTimelineData(originalDb *sql.DB, friend_list []string) ([]timelinedata, error) {
	var timelineData = make([]timelinedata, 0)
	var newFriends = make([]string, 0)

	for _, el := range friend_list {
		newFriends = append(newFriends, fmt.Sprintf("'%v'", strings.TrimSpace(el)))
	}
	arg := strings.Join(newFriends, ",")
	arg = fmt.Sprintf("(%s)", arg)
	log.Println(arg)
	if rows, err := originalDb.Query(fmt.Sprintf("select id_person, comment, startsAt, endsAt from activities where id_person in %s", arg)); err != nil {
		log.Print(err)
		return timelineData, err
	} else {
		for rows.Next() {
			var data timelinedata
			if err := rows.Scan(&data.ID, &data.Comment, &data.StartsAt, &data.EndsAt); err != nil {
				log.Print(err)
				continue
			}
			log.Println("asd")
			log.Println(strings.Split(data.ID, "\"")[0])
			fmt.Printf("select name, email from persons where id_person = '%v'", data.ID)
			if rows, err := originalDb.QueryContext(context.TODO(), "select name, email from persons where id_person = ?", strings.Split(data.ID, "\"")[0]); err != nil {
				log.Print(err)
			} else {
				var name string
				var email string
				for rows.Next() {
					if err := rows.Scan(&name, &email); err != nil {
						log.Println(err)
					}
				}
				log.Println(name, email)
				data.Name = name
				data.Email = name
			}
			log.Println(data)
			timelineData = append(timelineData, data)

		}
		return timelineData, nil
	}

}
