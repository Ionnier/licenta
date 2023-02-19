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
		defer rows.Close()
		for rows.Next() {
			var data timelinedata
			if err := rows.Scan(&data.ID, &data.Comment, &data.StartsAt, &data.EndsAt); err != nil {
				log.Print(err)
				continue
			}
			if rows, err := originalDb.QueryContext(context.TODO(), "select name, email, image_url from persons where id_person = ?", strings.Split(data.ID, "\"")[0]); err != nil {
				log.Print(err)
			} else {
				defer rows.Close()
				var name string
				var email string
				var image_url string
				for rows.Next() {
					if err := rows.Scan(&name, &email, &image_url); err != nil {
						log.Println(err)
					}
				}
				data.Name = name
				data.Email = email
				data.ImageUrl = image_url
			}
			timelineData = append(timelineData, data)

		}
		return timelineData, nil
	}

}
