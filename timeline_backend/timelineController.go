package main

import (
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
			if rows, err := originalDb.Query(fmt.Sprintf("select name, email from persons where id_person = %s", data.ID)); err != nil {
				log.Print(err)
			} else {
				var name string
				var email string
				for rows.Next() {
					rows.Scan(&name, &email)
				}
				data.Name = name
				data.Email = name
			}
			timelineData = append(timelineData, data)

		}
		return timelineData, nil
	}

}
