require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info('#{self.table_name}')"
        DB[:conn].execute(sql).collect do |column|
            column["name"]
        end
    end

    def initialize(attributes = {})
        attributes.each {|key, value| self.send(("#{key}="), value)}
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|column_name| column_name == "id"}.join(", ")
    end

    def table_name_for_insert
        self.class.table_name
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |column_name|
            values << "'#{send(column_name)}'" unless send(column_name) == nil
        end
        values.join(", ")
    end

    def save
        # sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (?)"
        # DB[:conn].execute(sql, [self.values_for_insert])
        
        # DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?)", [values_for_insert])

        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        conditionals = []
        hash.each do |key, value|
            conditionals << "#{key} = '#{value}'"
        end
        condition_string = conditionals.join(", ")
        puts condition_string
        sql = "SELECT * FROM #{table_name} WHERE #{condition_string}"
        DB[:conn].execute(sql)
    end

end