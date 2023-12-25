require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
     include Singleton

     def initialize
          super("aa_questions.db")
          self.type_translation = true
          self.results_as_hash = true
     end
end

class User
     attr_accessor :id, :fname, :lname
     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM users;")
          data.map { |datum| User.new(datum) }
     end

     def initialize(options)
          @id = options['id']
          @fname = options['fname']
          @lname = options['lname']
     end

     def create
          raise "#{self} already in a database" if @id
          QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
          INSERT INTO 
               users(fname, lname)
          VALUES
               (?, ?)
          SQL
          @id = QuestionsDBConnection.instance.last_insert_row_id
     end

     def update
          raise "#{self} not in a database" unless @id
          QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
          UPDATE 
               users
          SET
               fname = ?,
               lname = ?
          WHERE
               id = ?
          SQL
     end

     def self.find_by_id(id)
          name = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
          *
          FROM
          users
          WHERE
          id = ?
          SQL
          return nil unless name.length > 0
          User.new(name.first)
     end

     def self.find_by_name(fname, lname)
          user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
          SELECT
               *
          FROM
               users
          WHERE
               fname = ? AND lname = ?
          SQL
          return nil unless user.length > 0 
          User.new(user.first)
     end
end

class Question
     attr_accessor :id, :title, :body, :author_id
     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM questions;")
          data.map { |datum| Question.new(datum) }
     end

     def initialize(options)
          @id = options['id']
          @title = options['title']
          @body = options['body']
          @author_id = options['author_id']
     end

     def create 
          raise "#{self} already in a Database" if self.id
          QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id)
          INSERT INTO 
               questions(title, body, author_id)
          VALUES
               (?, ?, ?)
          SQL
          self.id = QuestionsDBConnection.instance.last_insert_row_id
     end

     def update
          raise "#{self} not in a Database" unless self.id
          QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id)
          UPDATE
               questions
          SET 
               title = ?, body = ?, author_id = ?
          WHERE
               id = ?
          SQL
     end

     def self.find_by_title(title)
          question = QuestionsDBConnection.instance.execute(<<-SQL, title)
          SELECT 
               *
          FROM
               questions
          WHERE
               title = ? 
          SQL
          return nil unless question.length > 0
          Question.new(question.first)
     end

     def self.find_by_id(id)
          question = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               *
          FROM
               questions
          WHERE 
               id = ?
          SQL
          return nil unless question.length > 0
          Question.new(question.first)
     end

     def self.find_by_body_part(part)
          question = QuestionsDBConnection.instance.execute(<<-SQL, "%#{part}%")
          SELECT 
               *
          FROM
               questions
          WHERE 
               body LIKE ?
          SQL
          return nil unless question.length > 0
          Question.new(question.first)
     end
end

class Question_follow

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows;")
          data.map { |datum| Question_follow.new(datum) }
     end

     def initialize(options)
          @question_id = options['question_id']
          @follower_id = options['follower_id']
     end
end

class Reply

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM replies;")
          data.map { |datum| Reply.new(datum) }
     end

     def initialize(options)
          @id = options['id']
          @question_id = options['question_id']
          @body = options['body']
          @user_id = options['user_id']
          @parent_reply = options['parent_reply']
     end
end

class Question_like

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes;")
          data.map { |datum| Question_like.new(datum) }
     end

     def initialize(options)
          @user_id = options['user_id']
          @question_id = options['question_id']
          @liked = options['liked']
     end
end