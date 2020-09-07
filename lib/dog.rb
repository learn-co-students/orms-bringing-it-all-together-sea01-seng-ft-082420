class Dog
    attr_accessor  :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
       sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id
        self.update
        else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, name, breed)
        #binding.pry
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs LIMIT 1")[0][0]
        #@id = DB[:conn].execute(“SELECT last_insert_rowid() FROM dogs”)[0][0]
        end
        self
    end

    def self.create(hash)
        t = Dog.new(hash)
        t.save
        t
    end

    def self.new_from_db(array)
        self.new(id: array[0], name: array[1], breed: array[2])
    end

    def self.find_by_id(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
            self.new_from_db(row)
        end.first
      end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            new_dog = dog[0]
            dog = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        a = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
        new_instance = Dog.new(id: a[0], name: a[1], breed: a[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end