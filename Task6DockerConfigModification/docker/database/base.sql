CREATE DATABASE students_marks CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE students_marks;

create table grade
(
    grade    int null,
    min_mark int null,
    max_mark int null
);

create table students
(
    id    int null,
    name  varchar(100) null,
    marks int null
);

INSERT INTO students (name, marks) VALUES
('Liam', 87), ('Olivia', 65), ('Maria', 95),
('James', 64), ('Robert', 83), ('John', 95);

INSERT INTO grade (grade, min_mark, max_mark) VALUES
(1, 0, 9), (2, 10, 19), (3, 20, 29),
(4, 30, 39), (5, 40, 49), (6, 50, 59),
(7, 60, 69), (8, 70, 79), (9, 80, 89),
(10, 90, 100);
