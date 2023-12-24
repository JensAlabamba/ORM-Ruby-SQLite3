require 'sqlite3'
require 'singletion'

class QuestionsDBConnection < SQLite3::Database
     include Singleton

     def initialize
          super(aa_questions.db)
          self.type_translation = true
          self.results_as_hash = true
     end
end

class User

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM users;")
          data.map { |datum| User.new(datum) }
     end

     def initialize[options]
          @id = options['id']
          @fname = options['fname']
          @lname = options['lname']
     end
end

class Question

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