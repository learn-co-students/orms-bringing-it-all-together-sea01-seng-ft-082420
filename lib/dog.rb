require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(args)
        args.each {|key, value| self.send("#{key}=", value)}
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(args)
        self.new(args).save
    end

    def self.new_from_db(dog)
        self.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(args)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, args[:name], args[:breed])
        if !dog.empty?
            dog = self.new_from_db(dog.first)
        else
            dog = self.create(args)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end