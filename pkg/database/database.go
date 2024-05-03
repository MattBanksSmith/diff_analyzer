package database

import "sync"

type Database struct {
	sync.Mutex
	data map[string]interface{}
}

func NewDatabase() *Database {
	return &Database{
		data: make(map[string]interface{}),
	}
}

func (d *Database) Get(key string) (interface{}, bool) {
	d.Lock()
	defer d.Unlock()
	val, ok := d.data[key]

	//test
	return val, ok
}

func (d *Database) Set(key string, val interface{}) {
	d.Lock()
	defer d.Unlock()

	d.data[key] = val
}

func (d *Database) Delete(key string) {
	d.Lock()
	defer d.Unlock()

	delete(d.data, key)
}
