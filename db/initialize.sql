/*

# useage
# cat initialize.sql | sqlite3 ./tsumugu.db

*/

/*
[ref]
### https://www.sqlite.org/datatype3.html
especially:
2.2 date and time

*/

/*
### updated_at of each row
text as date
"recently-update-date, ... 1st-update-date, new-made-date"
eath date of text is such as : "YYYY-MM-DD HH:MM:SS.SSS TIMEZOON"
*/


CREATE table craftsmans(
       id int NOT NULL,
       name varchar(28) NOT NULL,
       password varchar(144) NOT NULL,
       --
       email varchar(144),
       --
       UNIQUE(id));

INSERT INTO craftsmans(id, name, password, email) VALUES
       (0, "nil user", "password", "email@*.com");


CREATE table article(
       id int NOT NULL,
       --
       user_id int NOT NULL,
       updated_at TEXT,
       --
       title TEXT,
       tags TEXT,
       contents TEXT,
       --
       UNIQUE(id));

INSERT INTO article(id, user_id, updated_at, title, tags, contents) VALUES
       (0, 0, "bifore big bang", "title", "tags", "1st article am this");
;;
