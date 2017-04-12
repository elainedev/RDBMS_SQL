require 'sqlite3'
require 'singleton'
require_relative 'question_follows.rb'

class UsersDBConnect < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class User

  attr_accessor :fname, :lname

  def self.find_by_id(id)
    user = UsersDBConnect.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(user.first)
  end

  def self.all
    users = UsersDBConnect.instance.execute('SELECT * FROM users')
    users.map { |user| User.new(user) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    UsersDBConnect.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = UsersDBConnect.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    UsersDBConnect.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
end
