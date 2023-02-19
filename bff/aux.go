package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
)

type timelineElement struct {
	Comment  string `json:"comment"`
	StartsAt int64  `json:"startsAt"`
	EndsAt   int64  `json:"endsAt"`
}

type AutoGenerated struct {
	Message string `json:"message"`
	Data    []struct {
		ID       string `json:"id"`
		Name     string `json:"name"`
		Email    string `json:"email"`
		ImageURL string `json:"imageUrl"`
		Comment  string `json:"comment"`
		StartsAt int64  `json:"startsAt"`
		EndsAt   int64  `json:"endsAt"`
	} `json:"data"`
}

type AutoGenerated2 struct {
	Message string   `json:"message"`
	Data    []string `json:"data"`
}

func getFriendsOf(userId string) ([]string, error) {
	log.Printf("Start getFriendsOf %v", userId)
	lst := make([]string, 0)
	a := fiber.AcquireAgent()
	req := a.Request()
	req.Header.SetMethod(fiber.MethodGet)
	req.SetRequestURI(fmt.Sprintf("%v/timeline/friends/%v", os.Getenv("TIMELINE_DOMAIN"), userId))

	if err := a.Parse(); err != nil {
		panic(err)
	}

	status, bytes, errs := a.Bytes()
	log.Printf("Status getFriendsOf %v", status)
	if status != 200 {
		log.Println(errs)
		return lst, errors.New("there was an error getting friends")
	}

	var asd AutoGenerated2

	log.Printf("Start unmarshal")
	if err := json.Unmarshal(bytes, &asd); err != nil {
		log.Print(err)
		return lst, err
	}

	log.Printf("Elements: %v", len(asd.Data))

	return asd.Data, nil
}

func getTimelineOf(userId string) ([]timelineElement, error) {
	log.Printf("Start getTimelineOf %v", userId)
	lst := make([]timelineElement, 0)
	a := fiber.AcquireAgent()
	req := a.Request()
	req.Header.SetMethod(fiber.MethodGet)
	req.SetRequestURI(fmt.Sprintf("%v/timeline/of/%v", os.Getenv("TIMELINE_DOMAIN"), userId))

	if err := a.Parse(); err != nil {
		panic(err)
	}

	status, bytes, errs := a.Bytes()
	log.Printf("Start get timeline %v", status)
	if status != 200 {
		log.Println(errs)
		return lst, errors.New("there was an error getting timeline")
	}

	var asd AutoGenerated

	log.Printf("Start unmarshal")
	if err := json.Unmarshal(bytes, &asd); err != nil {
		log.Print(err)
		return lst, err
	}

	log.Printf("Elements: %v", len(asd.Data))

	for _, elem := range asd.Data {
		aux := new(timelineElement)
		aux.StartsAt = elem.StartsAt
		aux.EndsAt = elem.EndsAt
		aux.Comment = elem.Comment
		lst = append(lst, *aux)
	}

	return lst, nil
}

type AutoGenerated3 struct {
	Message string   `json:"message"`
	Data    UserInfo `json:"data"`
}

type UserInfo struct {
	ID           string `json:"id"`
	UserName     string `json:"userName"`
	UserEmail    string `json:"userEmail"`
	UserPassword string `json:"userPassword"`
	CreatedDate  int    `json:"createdDate"`
	UpdatedDate  int    `json:"updatedDate"`
	ImageURL     string `json:"imageUrl"`
}

func getUserDataOfList(userIds []string) ([]UserInfo, error) {
	log.Printf("Start getUserDataOf %v", userIds)
	lst := make([]UserInfo, 0)
	for _, userId := range userIds {
		if data, err := getUserDataOf(userId); err != nil {
			log.Println(err)
		} else {
			lst = append(lst, data)
		}
	}
	return lst, nil
}

func getUserDataOf(userId string) (UserInfo, error) {
	userInfo := new(UserInfo)

	a := fiber.AcquireAgent()
	req := a.Request()
	req.Header.SetMethod(fiber.MethodGet)
	req.SetRequestURI(fmt.Sprintf("%v/api/users/%v", os.Getenv("AUTH_DOMAIN"), userId))

	if err := a.Parse(); err != nil {
		panic(err)
	}

	status, bytes, errs := a.Bytes()

	if status != 200 {
		log.Println(errs)
		return *userInfo, errors.New("there was an error getting the info")
	}

	var asd AutoGenerated3

	log.Printf("Start unmarshal for %v", userId)
	if err := json.Unmarshal(bytes, &asd); err != nil {
		log.Print(err)
		return *userInfo, err
	}
	return asd.Data, nil
}
