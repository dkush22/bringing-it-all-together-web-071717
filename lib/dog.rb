require 'pry'

class Dog

attr_accessor :name, :breed, :id

def initialize(name:, breed:, id: nil)
	@name = name
	@breed = breed
	#@id = nil
end

def self.create_table
	sql = <<-SQL
	CREATE TABLE IF NOT EXISTS dogs (
	id INTEGER PRIMARY KEY,
	name TEXT,
	breed TEXT)
	SQL
	DB[:conn].execute(sql)
end

def self.drop_table
	sql = <<-SQL
	DROP TABLE IF EXISTS dogs
	SQL
	DB[:conn].execute(sql)
end

def save
	# if self.id
	# 	self.update
	# else
	sql = <<-SQL
	INSERT INTO dogs (name, breed) VALUES (?, ?)
	SQL
	dog = DB[:conn].execute(sql, self.name, self.breed)
	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	self
end

def self.create(name:, breed:, id: nil)
	dog = Dog.new(name: name, breed: breed, id: nil)
	dog.save
end

def self.find_by_id(id)
	sql = <<-SQL
	SELECT * FROM dogs WHERE id = ?
	SQL
	row = DB[:conn].execute(sql, id)[0]
	new_from_db(row)
end

def self.find_by_name(name)
	sql = <<-SQL
	SELECT * FROM dogs WHERE name = ?
	SQL
	row = DB[:conn].execute(sql, name)[0]
	new_from_db(row)
end


def self.new_from_db(row)
	dog = Dog.new(name: row[1], breed: row[2])
	dog.id = row[0]
	dog
end

def self.find_or_create_by(name:, breed:)
	dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
	if dog.empty?
		dog = self.create(name: name, breed: breed)
	else
		dog_data = dog[0]
		dog = Dog.new_from_db(dog_data)
	end
end

def update
	sql = <<-SQL
	UPDATE dogs SET name = ? WHERE id = ?
	SQL
	DB[:conn].execute(sql, self.name, self.id)
end

end