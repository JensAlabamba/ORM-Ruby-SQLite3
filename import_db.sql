
CREATE TABLE users(
    id INTEGER PRIMARY KEY
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions(
    id INTEGER PRIMARY KEY
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL,
    author_id INTEGER NOT NULL
    

    FOREIGN KEY (author_id) REFERENCES users(id)
);

