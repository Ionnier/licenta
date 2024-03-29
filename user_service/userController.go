package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

const (
	USERS_DATABASE   = "Users"
	USERS_COLLECTION = "UsersCollection"
	DEFAULT_COST     = 10
)

type user struct {
	ID           string `bson:"_id, omitempty" json:"id"`
	UserName     string `bson:"user_name, omitempty" json:"userName"`
	UserEmail    string `bson:"user_email, omitempty" json:"userEmail"`
	UserPassword string `bson:"user_password, omitempty" json:"userPassword"`
	CreatedDate  int64  `bson:"created_date, omitempty" json:"createdDate"`
	UpdatedDate  int64  `bson:"updated_date, omitempty" json:"updatedDate"`
	ImageUrl     string `bson:"image_url, omitempty" json:"imageUrl"`
}

type user2 struct {
	UserName     string `bson:"user_name, omitempty" json:"userName"`
	UserEmail    string `bson:"user_email, omitempty" json:"userEmail"`
	UserPassword string `bson:"user_password, omitempty" json:"userPassword"`
	CreatedDate  int64  `bson:"created_date, omitempty" json:"createdDate"`
	UpdatedDate  int64  `bson:"updated_date, omitempty" json:"updatedDate"`
	ImageUrl     string `bson:"image_url, omitempty" json:"imageUrl"`
}

func handleSignup(userEmail string, userPassword string) (*user, error) {
	log.Println("Start handleSignup")
	if len(userEmail) == 0 || len(userPassword) == 0 {
		log.Println("Email or password empty")
		return nil, fiber.NewError(fiber.ErrBadRequest.Code, "User email or password is empty.")
	}

	if user, _ := findUser(user{
		UserEmail: userEmail,
	}); user != nil {
		return nil, fiber.NewError(fiber.ErrBadRequest.Code, "User already exists")
	}

	log.Println("User not found. Generating password.")
	hashedPassword, err := generatePassword(userPassword)

	if err != nil {
		return nil, err
	}

	userData, err := createUser(user{
		UserEmail:    userEmail,
		UserPassword: hashedPassword})

	if err != nil {
		return nil, err
	}

	return userData, nil
}

func findUserById(id string) (*user, error) {
	objectId, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, fiber.NewError(fiber.ErrBadRequest.Code, "Invalid id")
	}
	coll := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION)

	return processFindResult(coll.FindOne(context.TODO(), bson.M{"_id": objectId}))
}

func findUser(userData user) (*user, error) {
	log.Println("Start find user")
	if len(userData.UserEmail) != 0 {
		return findUserByEmail(userData.UserEmail)
	}

	if len(userData.UserName) != 0 {
		return findUserByUserName(userData.UserName)
	}

	return nil, fiber.NewError(fiber.ErrBadRequest.Code, fmt.Sprintf("No searcheable data provided %v", userData))
}

func findUserByEmail(email string) (*user, error) {
	coll := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION)

	return processFindResult(coll.FindOne(context.TODO(), bson.D{{Key: "user_email", Value: email}}))
}

func findUserByUserName(username string) (*user, error) {
	coll := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION)

	return processFindResult(coll.FindOne(context.TODO(), bson.M{"user_name": username}))
}

func processFindResult(result *mongo.SingleResult) (*user, error) {
	if err := result.Err(); err != nil {
		return nil, err
	}

	var completeUserData user

	if err := result.Decode(&completeUserData); err != nil {
		return nil, err
	}

	return &completeUserData, nil
}

func generatePassword(clearPassword string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(clearPassword), DEFAULT_COST)

	if err != nil {
		return "", err
	}

	return string(hashedPassword), nil
}

func createUser(userData user) (*user, error) {
	log.Println("Start create user")
	coll := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION)

	finalUserData := user2{
		UserEmail:    userData.UserEmail,
		UserPassword: userData.UserPassword,
		CreatedDate:  time.Now().UTC().Unix(),
		UpdatedDate:  time.Now().UTC().Unix(),
	}

	finalUserData2 := user{
		UserEmail:    userData.UserEmail,
		UserPassword: userData.UserPassword,
		CreatedDate:  time.Now().UTC().Unix(),
		UpdatedDate:  time.Now().UTC().Unix(),
	}

	if _, err := coll.InsertOne(context.TODO(), finalUserData); err != nil {
		return nil, err
	}

	return &finalUserData2, nil
}

func handleLogin(userData user) (*user, error) {
	log.Println("Start handleLogin")
	userInfo, err := findUser(userData)

	if err != nil {
		return nil, err
	}

	log.Println("Start compare password")
	if err := comparePassword(userInfo.UserPassword, userData.UserPassword); err != nil {
		return nil, mongo.ErrNoDocuments
	}

	return userInfo, nil
}

func comparePassword(hashedPassword string, clearPassword string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(clearPassword))
}

func updateUser(newUserData user) error {
	log.Println(newUserData.ID)
	log.Println("Start updateUser")
	update := bson.D{
		{Key: "$set",
			Value: bson.D{
				{Key: "user_name", Value: newUserData.UserName},
				{Key: "updated_date", Value: time.Now().UTC().Unix()},
				{Key: "user_email", Value: newUserData.UserEmail},
				{Key: "image_url", Value: newUserData.ImageUrl},
			},
		},
	}

	id, err := primitive.ObjectIDFromHex(newUserData.ID)
	if err != nil {
		return err
	}
	result, err := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION).UpdateByID(
		context.TODO(),
		id,
		update,
	)

	log.Printf("Update finished with err = %v", err)

	if err != nil || result.MatchedCount == 0 {
		if err == nil {
			return fiber.NewError(fiber.StatusBadRequest, "Didn't change")
		}
		return err
	}

	return nil
}

func changePassword(email string, currentPassword string, newPassword string) error {
	if len(email) == 0 || len(currentPassword) == 0 || len(newPassword) == 0 {
		return fiber.NewError(fiber.ErrBadRequest.Code,
			"Not enough parameters provided for password change.",
		)
	}

	user, err := findUserByEmail(email)

	if err != nil {
		return err
	}

	if err := comparePassword(user.UserPassword, currentPassword); err != nil {
		return err
	}

	hashedPassword, err := generatePassword(newPassword)

	if err != nil {
		return err
	}

	filter := bson.D{{Key: "user_email", Value: email}}
	update := bson.D{{Key: "$set", Value: bson.D{{Key: "user_password", Value: hashedPassword},
		{Key: "updated_date", Value: time.Now().UTC().Unix()}}}}

	result, err := getDatabase().Database(USERS_DATABASE).Collection(USERS_COLLECTION).UpdateOne(
		context.TODO(),
		filter,
		update,
	)

	if err != nil || result.MatchedCount == 0 {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		log.Fatal(err)
	}

	return nil

}
