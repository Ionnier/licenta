package main

import (
	"errors"
	"log"
	"os"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
)

type customClaims struct {
	UserName  string `json:"userName"`
	UserEmail string `json:"userEmail"`
	ID        string `json:"id"`
	jwt.RegisteredClaims
}

func generateToken(userData user) string {
	claims := customClaims{
		UserName:  userData.UserName,
		UserEmail: userData.UserEmail,
		ID:        userData.ID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().UTC().Add(time.Minute * 300)),
			IssuedAt:  jwt.NewNumericDate(time.Now().UTC()),
			Issuer:    "user_service",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	signedToken, err := token.SignedString([]byte(os.Getenv("JWT_SECRET_KEY")))

	if err != nil {
		log.Fatal(err)
	}

	return signedToken
}

func validateToken(token string) (*customClaims, error) {
	validToken, err := jwt.ParseWithClaims(
		token,
		&customClaims{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(os.Getenv("JWT_SECRET_KEY")), nil
		},
	)

	if err != nil {
		return nil, err
	}

	claims, ok := validToken.Claims.(*customClaims)
	if !ok {
		return nil, errors.New("couldn't parse claims")
	}

	if claims.ExpiresAt.Unix() < time.Now().UTC().Unix() {
		return nil, errors.New("jwt is expired")
	}

	return claims, nil
}

func protect(c *fiber.Ctx) error {

	val, exists := c.GetReqHeaders()["Authorization"]

	if !exists {
		return fiber.NewError(fiber.StatusUnauthorized, "No authorization header.")
	}

	if !strings.HasPrefix(val, "Bearer") {
		return fiber.NewError(fiber.StatusUnauthorized, "No bearer token.")
	}

	token := strings.Split(val, " ")[1]

	claims, err := validateToken(token)

	if err != nil {
		return err
	}

	var userData user

	userData.UserEmail = claims.UserEmail
	userData.UserName = claims.UserName

	if time.Now().Add(time.Second*30).UTC().Sub(claims.IssuedAt.Time) > 0 {
		customData, _ := findUser(user{
			UserEmail: claims.UserEmail,
		})

		if customData.UpdatedDate > claims.IssuedAt.Unix() {
			return fiber.NewError(fiber.StatusUnauthorized, "User modified after JWT issued.")
		}

		userData.UserEmail = customData.UserEmail
		userData.UserName = customData.UserName
	}

	c.Locals("userData", userData)

	return c.Next()
}
