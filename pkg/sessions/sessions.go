package sessions

import "sync"

type SessionState struct {
	count    int
	sessions map[string]int
	sync.Mutex
}

func (c *SessionState) CreateSession() int {
	c.Lock()
	defer c.Unlock()

	c.count++
	return c.count
}
