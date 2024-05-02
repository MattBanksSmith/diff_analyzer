package user_repository

import "sample_user_api/pkg/database"

type UserRepository struct {
	db *database.Database
}

type User struct {
	Username  string
	FirstName string
	LastName  string
}

func NewUserRepository() *UserRepository {
	return &UserRepository{}
}

func (u *UserRepository) GetUser(username string) (User, bool) {
	val, ok := u.db.Get(username)
	if !ok {
		return User{}, false
	}
	return val.(User), true
}

func (u *UserRepository) SaveUser(user User) {
	u.db.Set(user.Username, user)
}

func (u *UserRepository) RemoveUser(username string) {
	u.db.Delete(username)
}
