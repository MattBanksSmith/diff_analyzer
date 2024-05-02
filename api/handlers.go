package api

import (
	"encoding/json"
	"io"
	"net/http"
	"sample_user_api/pkg/user_repository"
)

type handlerContext struct {
	userRepository *user_repository.UserRepository
}

func SetupHandlers(userRepository *user_repository.UserRepository) {
	context := handlerContext{userRepository}

	http.HandleFunc("/user/get", context.getUser)
	http.HandleFunc("/user/create", context.createUser)
	http.HandleFunc("/user/delete", context.deleteUser)
	http.HandleFunc("/user/login", context.loginUser)
}

func (h handlerContext) createUser(writer http.ResponseWriter, request *http.Request) {
	b, err := io.ReadAll(request.Body)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}
	u := user_repository.User{}

	err = json.Unmarshal(b, &u)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	h.userRepository.SaveUser(u)
	writer.WriteHeader(http.StatusCreated)
}

func (h handlerContext) deleteUser(writer http.ResponseWriter, request *http.Request) {
	type Username struct {
		Username string `json:"username"`
	}

	b, err := io.ReadAll(request.Body)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	u := Username{}

	err = json.Unmarshal(b, &u)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	h.userRepository.RemoveUser(u.Username)
	writer.WriteHeader(http.StatusOK)
}

func (h handlerContext) loginUser(writer http.ResponseWriter, request *http.Request) {
	//huh?
}

func (h handlerContext) getUser(writer http.ResponseWriter, request *http.Request) {
	type Username struct {
		Username string `json:"username"`
	}

	b, err := io.ReadAll(request.Body)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	u := Username{}

	err = json.Unmarshal(b, &u)
	if err != nil {
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	user, _ := h.userRepository.GetUser(u.Username)
	b, err = json.Marshal(user)
	if err != nil {
		writer.WriteHeader(http.StatusInternalServerError)
		return
	}
	_, err = writer.Write(b)
	if err != nil {
		writer.WriteHeader(http.StatusInternalServerError)
	}
}
