require 'sqlite3'
require 'singleton'

class QuestionFollowsDBConnect < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class QuestionFollow

  attr_accessor :question_id, :author_id

  def self.all
    qf = QuestionFollowsDBConnect.instance.execute('SELECT * FROM question_follows')
    qf.map { |el| QuestionFollow.new(el) }
  end

  def self.find_by_id(id)
    qf = QuestionFollowsDBConnect.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollow.new(qf.first)
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionFollowsDBConnect.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
        JOIN users
          ON question_follows.author_id = users.id
      WHERE
        question_id = ?
    SQL
    User.new(followers.first)
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionFollowsDBConnect.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
        JOIN questions
          ON question_follows.question_id = questions.id
      WHERE
        questions.author_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  # Fetches the n most followed questions
  def self.most_followed_questions(n)
    questions = QuestionFollowsDBConnect.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
    GROUP BY
      question_id
    SQL
    p questions
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @author_id = options['author_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionFollowsDBConnect.instance.execute(<<-SQL, @question_id, @author_id)
      INSERT INTO
        question_follows (question_id, author_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionFollowsDBConnect.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionFollowsDBConnect.instance.execute(<<-SQL, @question_id, @author_id, @id)
      UPDATE
        question_follows
      SET
        question_id = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end
end
