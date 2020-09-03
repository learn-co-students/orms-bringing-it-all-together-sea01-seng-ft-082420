class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL

        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    #returns an instance of the dog class
    #saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    #
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    #create a new dog object and saves that dog to the database
    #returns a new dog object
    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    #creates an instance with corresponding attribute values
    def self.new_from_db(row)
        new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    #returns a new dog object by id and returns a new instance of the Dog class
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map do |row|
            Dog.new_from_db(row)
        end.first #first element from the returned array
    end

    #returns a new dog object by name and returns a new instance of the Dog class
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end
    
    #returns a new dog object by breed and returns a new instance of the Dog class
    def self.find_by_breed(breed)
        sql = "SELECT * FROM dogs WHERE breed = ?"
        DB[:conn].execute(sql, breed).map do |row|
          self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name =? AND breed =?"
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end


end