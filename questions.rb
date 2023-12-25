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

     def self.authored_questions
          
          ids = QuestionsDBConnection.instance.execute(<<-SQL)
               SELECT
               id
               FROM
               users
          SQL
          ids.map do |id_hash|
               id = id_hash['id']
              Question.find_by_author_id(id)
          end
     end

     def self.authored_replies
          
          ids = QuestionsDBConnection.instance.execute(<<-SQL)
               SELECT
               id
               FROM
               users
          SQL
          ids.map do |id_hash|
               id = id_hash['id']
              Reply.find_by_user_id(id)
          end
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

     def self.find_by_author_id(id)
          question = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               *
          FROM
               questions
          WHERE 
               author_id = ?
          SQL
          return nil unless question.length > 0
          question.map { |q| Question.new(q) }
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

     def self.find_by_author_name(fname, lname)
          question = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
          SELECT 
               *
          FROM
               questions
          JOIN 
               users ON users.id = questions.author_id
          WHERE
               fname = ? AND lname = ?
          SQL
          return nil unless question.length > 0
          Question.new(question.first)
     end

     def self.replies
          replies = QuestionsDBConnection.instance.execute(<<-SQL)
          SELECT 
               id
          FROM
               questions
          SQL
          replies.map do |id|
               question_id = id['id']
               Reply.find_by_question_id(question_id)
          end
     end
end

class Question_follow

     attr_accessor :question_id, :follower_id

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows;")
          data.map { |datum| Question_follow.new(datum) }
     end

     def initialize(options)
          @question_id = options['question_id']
          @follower_id = options['follower_id']
     end

     def self.find_by_question_id(id)
          question = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               * 
          FROM
               question_follows
          WHERE 
               question_id = ?
          SQL
          return nil unless question.length > 0
         question.map { |datum| Question_follow.new(datum) }
     end
end

class Reply

     attr_accessor :id, :question_id, :body, :user_id, :parent_reply
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

     def self.find_by_id(id)
          reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               *
          FROM
               replies
          WHERE 
               id = ?
          SQL
          return nil unless reply.length > 0
          Reply.new(reply.first)
     end

     def self.find_by_user_id(id)
          reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               *
          FROM
               replies
          WHERE 
               user_id = ?
          SQL
          return nil unless reply.length > 0
          Reply.new(reply.first)
     end

     def self.find_by_question_id(id)
          reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT 
               *
          FROM
               replies
          WHERE
               question_id = ?
          SQL
          return nil unless reply.length > 0
          reply.map { |rep| Reply.new(rep) }
     end

     def author
          author = QuestionsDBConnection.instance.execute(<<-SQL)
          SELECT 
               *
          FROM
               users
          JOIN
               replies ON replies.user_id = users.id
          SQL
          return nil unless author.length > 0
          User.new(author.first)
     end
     
     def question
          question = QuestionsDBConnection.instance.execute(<<-SQL)
          SELECT 
               questions.*
          FROM
               questions
          JOIN
               replies ON replies.question_id = questions.id
          SQL
          return nil unless question.length > 0
          Question.new(question.first)
     end
end

class Question_like

     attr_accessor :user_id, :question_id, :liked

     def self.all
          data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes;")
          data.map { |datum| Question_like.new(datum) }
     end

     def initialize(options)
          @user_id = options['user_id']
          @question_id = options['question_id']
          @liked = options['liked']
     end

     def self.find_by_user_id(id)
          liked = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT
               * 
          FROM
               question_likes
          WHERE
               user_id = ?
          SQL
          return nil unless liked.length > 0
          liked.map { |like| Question_like.new(like) }
     end

     def self.find_by_question_id(id)
          liked = QuestionsDBConnection.instance.execute(<<-SQL, id)
          SELECT
               * 
          FROM
               question_likes
          WHERE
               question_id = ?
          SQL
          return nil unless liked.length > 0
          liked.map { |like| Question_like.new(like) }
     end
end