SHOW DATABASES;
CREATE DATABASE students_marks CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE students_marks;
SHOW TABLES;

-- DDL from pdf (without keys)

create table grade
(
 grade int null,
 min_mark int null,
 max_mark int null
);

create table students
(
 id int null,
 name varchar(100) null,
 marks int null
);

show tables;

INSERT INTO students (name, marks) VALUES
('Liam', 87), ('Olivia', 65), ('Maria', 95),
('James', 64), ('Robert', 83), ('John', 95);

SELECT * FROM `students`;

INSERT INTO grade (grade, min_mark, max_mark) VALUES
(1, 0, 9), (2, 10, 19), (3, 20, 29),
(4, 30, 39), (5, 40, 49), (6, 50, 59),
(7, 60, 69), (8, 70, 79), (9, 80, 89),
(10, 90, 100);

SELECT * FROM `grade`;

-- SOLUTION FOR A (alternative solution after few alterings in a B section)
SELECT
	-- bad studs are nameless )))
    CASE
        WHEN g.grade >= 8 THEN s.name
        ELSE 'low'
    END AS name,
    g.grade,
    s.marks as mark
FROM
    students s
JOIN
    -- have 10 grades, but only 6 real studs
	grade g ON s.marks BETWEEN g.min_mark AND g.max_mark
ORDER BY
    -- high grades first
    g.grade DESC,
    -- if grade > 8 by alphabetical stud's name 
    CASE
        WHEN g.grade >= 8 THEN s.name
    END ASC,
    -- if grade < 8 by grade
    CASE
        WHEN g.grade < 8 THEN g.grade
    END ASC;
   
-- SOLUTION FOR B

-- ADD PRIMARY KEYs
ALTER TABLE students
MODIFY COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE grade
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- RELATION. Each student has a grade, but not every grade has a student.
ALTER TABLE students
ADD COLUMN grade_id INT,
ADD CONSTRAINT fk_grade_id
FOREIGN KEY (grade_id)
REFERENCES grade(id);

-- upgrade data for new relation!
UPDATE students s
JOIN (
	-- EACH "STUD ID" GETS "GRADE ID"
    SELECT
        s.id,
        g.id AS grade_id
    FROM
        students s
    JOIN
        grade g ON s.marks BETWEEN g.min_mark AND g.max_mark
) ranked_grades ON s.id = ranked_grades.id
SET s.grade_id = ranked_grades.grade_id;

-- additional indexes for better joins
ALTER TABLE students ADD INDEX idx_grade_id (grade_id);
ALTER TABLE grade ADD INDEX idx_id (id);

-- checks
DESCRIBE grade;
SHOW INDEX FROM grade;
SELECT * FROM grade;
DESCRIBE students;
SHOW INDEX FROM students;
SELECT * FROM students;

-- ALTERNATIVE SOLUTION FOR A, after structural alterings:
-- Faster SELECT and JOIN operations
-- Better JOIN operation
SELECT
    CASE
        WHEN g.grade >= 8 THEN s.name
        ELSE 'low'
    END AS name,
    g.grade,
    s.marks AS mark
FROM
    students s
LEFT JOIN
    grade g ON s.grade_id = g.id
ORDER BY
    g.grade DESC,
    CASE
        WHEN g.grade >= 8 THEN s.name
    END ASC,
    CASE
        WHEN g.grade < 8 THEN g.grade
    END ASC;


-- Partitioning (sharding)
-- Foreign keys cannot be used with partitioning,
-- but this can be a good alternative.
-- (Vertical partitioning is also an option, but it will affect all SELECT queries.)
-- Example of partitioning:
ALTER TABLE students
PARTITION BY RANGE COLUMNS(marks) (
    PARTITION p_0_9 VALUES LESS THAN (10),
    PARTITION p_10_19 VALUES LESS THAN (20),
    PARTITION p_20_29 VALUES LESS THAN (30),
    PARTITION p_30_39 VALUES LESS THAN (40),
    PARTITION p_40_49 VALUES LESS THAN (50),
    PARTITION p_50_59 VALUES LESS THAN (60),
    PARTITION p_60_69 VALUES LESS THAN (70),
    PARTITION p_70_79 VALUES LESS THAN (80),
    PARTITION p_80_89 VALUES LESS THAN (90),
    PARTITION p_90_100 VALUES LESS THAN (101)
);

-- REPLICATION is better for read, CLUSTERING is better for write operations
-- (also in scaling situation is the same).
-- REPLICATION is easier to configure for caching.
-- both are high available.
-- CLUSTERING is better for transactions.
-- I would use replication with load balancer here.