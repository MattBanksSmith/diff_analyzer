package main

import (
	"net/http"
	"sample_user_api/api"
	"sample_user_api/pkg/user_repository"
)

func main() {
	repo := user_repository.NewUserRepository()
	api.SetupHandlers(repo)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}
