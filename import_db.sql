PRAGMA foreign_keys = ON;
DROP TABLE if EXISTS users; 

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);

DROP TABLE if EXISTS questions;

CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL,
    author_id INTEGER NOT NULL,
    

    FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_follows;

CREATE TABLE question_follows(
    question_id INTEGER NOT NULL,
    follower_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE if EXISTS replies;

CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    body VARCHAR(255) NOT NULL,
    user_id INTEGER NOT NULL,
    parent_reply INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (parent_reply) REFERENCES replies(id)
);

DROP TABLE if EXISTS question_likes;

CREATE TABLE question_likes(
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    liked BOOLEAN,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    users(fname, lname)
VALUES
    ("Adam", "Driver"),
    ("Monica", "Adams"),
    ("Greta", "van Fleet"),
    ("Mathew", "Berry");

INSERT INTO 
    questions(title, body, author_id)
VALUES
    ("How do I start?", "I was wondering how to start my adventure with programming.", (SELECT id FROM users WHERE fname = "Adam" AND lname = "Driver")),
    ("Do we need SQL?", "Is SQL needed to become a FSD?", (SELECT id FROM users WHERE fname = "Greta" AND lname = "van Fleet"));

INSERT INTO 
    question_follows(question_id, follower_id)
VALUES
    (1, 4),
    (2, 4),
    (1, 2),
    (2, 3); 

INSERT INTO
    replies(question_id, body, user_id, parent_reply)
VALUES
    (1, "Start with App Academy Open!", 4, NULL),
    (1, "Thank you, I''ll check it out.", 1, 1),
    (2, "It is very usefull. Worth it.", 4, NULL),
    (2, "Than I will try to get some expierience", 3, 3);

INSERT INTO 
    question_likes(user_id, question_id, liked)
VALUES
    (4, 2, "true"),
    (2, 1, "true");