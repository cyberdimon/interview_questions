# #5 Student Grades SQL

You have a project that uses a library.

## Task A. Data Selection

Given a database with students and their grades. The `students` table contains the marks of each student, and the `grade` table contains the mapping of marks to the student's grade.

You need to write a query to the database that includes three columns: `name`, `grade`, and `mark`.
- The data should be ordered by descending grades, with higher grades displayed first.
- If there are multiple students with the same grade (8-10), order these specific students by their names in alphabetical order.
- If the grade is below 8, use "low" as their name and list them by grades in descending order.
- If there are multiple students with the same grade (1-7), order these specific students by their grades in ascending order.

## Task B. DDL Modification

It is assumed that the table with students will store data for more than two million students and will continue to grow. How would you modify the database tables, considering that the `grade` field from the `grade` table is always involved in queries to retrieve student data?

```sql
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
```

## Solution A.
```sql
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
```

**Result**  
![Selection](selection.png)

## Solution B.

```sql
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
```
**Relation**  
![Selection](relation.png)

### ALTERNATIVE SOLUTION FOR TASK A 
```sql
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
```

### Sharding, replication and clustering
```sql
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
```

## CACHING and config tweaking
in `my.cnf` file

cache for selects:
```
query_cache_type = 1
query_cache_size = 64M
```

additional, but better to be tested before production:  
(like most things in section B, actually)
```
query_cache_min_res_unit = 512
innodb_buffer_pool_size = 1G
tmp_table_size = 64M
max_heap_table_size = 64M
sort_buffer_size = 4M
read_buffer_size = 2M
join_buffer_size = 2M
```