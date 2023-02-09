package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var client *mongo.Client = nil

func getDatabase() *mongo.Client {
	if client == nil {
		var err error = nil
		database_url := fmt.Sprintf("mongodb+srv://%s:%s@%s?retryWrites=true&w=majority",
			os.Getenv("MONGO_USERNAME"),
			os.Getenv("MONGO_PASSWORD"),
			os.Getenv("MONGO_HOSTNAME"))
		log.Println(database_url)
		if client, err = mongo.Connect(context.Background(),
			options.Client().ApplyURI(database_url)); err != nil {
			log.Fatal(err)
		}
	}
	return client
}

func testConnection() {
	if err := getDatabase().Ping(context.TODO(), nil); err != nil {
		log.Fatal(err)
	}
}
