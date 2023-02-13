package main

import (
	"errors"
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

func validateToken(token string) (*customClaims, error) {
	validToken, err := jwt.ParseWithClaims(
		token,
		&customClaims{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(strings.TrimSpace(os.Getenv("JWT_SECRET_KEY"))), nil
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

	c.Locals("id", claims.ID)

	return c.Next()
}
