DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  parent_reply_id INTEGER,
  body VARCHAR(255) NOT NULL,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  like_button BOOLEAN,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Elaine', 'Wang'),
  ('Alex', 'Scott'),
  ('John', 'Smith'),
  ('Jane', 'Doe');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Biology', 'How many cells are in the human body?', (SELECT id FROM users WHERE fname = 'Jane')),
  ('Physics', 'What is the theory of relativity?', (SELECT id FROM users WHERE fname = 'Alex'));

INSERT INTO
  question_follows (question_id, author_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Biology'), (SELECT id FROM users WHERE fname = 'Jane')),
  ((SELECT id FROM questions WHERE title = 'Physics'), (SELECT id FROM users WHERE fname = 'Alex'));

INSERT INTO
  replies (parent_reply_id, body, question_id, author_id)
VALUES
  (NULL, '100,000', (SELECT id FROM questions WHERE title = 'Biology'), 3),
  (1, 'No that''s wrong, it''s 100 million', 1, 2),
  (NULL, 'I have no idea.', 2, 4),
  (2, 'No. you''re both wrong, it''s in the trillions', 1, 1);

INSERT INTO
    question_likes (like_button, question_id, author_id)
VALUES
  (1, 1, 1),
  (1, 1, 2),
  (1, 1, 4),
  (1, 2, 2);
