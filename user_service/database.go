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
		if client, err = mongo.Connect(context.TODO(),
			options.Client().ApplyURI(fmt.Sprintf("mongodb://%s:%s@%s?retryWrites=true&w=majority",
				os.Getenv("MONGO_USERNAME"),
				os.Getenv("MONGO_PASSWORD"),
				os.Getenv("MONGO_HOSTNAME")))); err != nil {
			log.Fatal(err)
		}
	}
	return client
}

func testConnection() {
	getDatabase()
}
