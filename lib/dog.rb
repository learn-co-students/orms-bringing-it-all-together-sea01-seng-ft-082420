class Dog

    attr_accessor :id, :name, :breed

    def initialize (attributes)
        attributes.each do |key, value|
            # self.class.attr_accessor(key)
            self.send("#{key}=", value)
        end
        # if self.id 
        #     self.id = nil
        # end
        self.id ||= nil
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create (attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = { 
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        self.new(new_dog)
    end

    def self.find_by_id(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND BREED = ?;", name, breed).first
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({name: name, breed: breed})
        end
        new_dog
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).map {|row| self.new_from_db(row)}.first
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id)
    end
end