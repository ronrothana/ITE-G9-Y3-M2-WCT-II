-- Create

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    department_id INT,
    faculty_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE NOT NULL,
    grade DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

ALTER TABLE students ADD COLUMN gpa DECIMAL(4,2);




-- Insert

INSERT INTO departments (department_name) VALUES ('Computer Science'), ('Mathematics'), ('Web');

INSERT INTO faculty (first_name, last_name, email, department_id) 
VALUES 
('nin', 'ny', 'nin@example.com', 2),
('tina', 'tino', 'tina@example.com', 1),
('nano', 'nann', 'nano@example.com', 3);
INSERT INTO faculty (first_name, last_name, email, department_id) 
VALUES 
('VIVI', 'Doe', 'vivi@example.com', 1), 
('Emma', 'Duu', 'emma@example.com', 3);


INSERT INTO students (student_id, first_name, last_name, date_of_birth, email) 
VALUES 
(1, 'nin', 'ny', '2000-12-05', 'nin@example.com'),
(2, 'nano', 'nann', '2002-08-22', 'nano@example.com'),
(3, 'tina', 'tino', '2005-06-04', 'tina@example.com'),
(4, 'yoo', 'hoo', '1999-03-15', 'yohh@example.com'),
(5, 'blue', 'wave', '1992-11-08', 'blue@example.com'),
(6, 'Dark', 'ness', '2014-09-25', 'dark@example.com');


INSERT INTO courses (course_code, course_name, department_id, faculty_id) 
VALUES 
('CS101', 'Introduction to Programming', 1, 1),
('MATH101', 'Calculus I', 2, 3),
('WB101', 'Web_Dev', 3, 2);


INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) 
VALUES 
(1, 2, '2024-03-20', 95.5),
(1, 1, '2025-03-20', 85.5),
(2, 2, '2025-03-21', 90.0),
(3, 3, '2025-03-22', 99.0);






SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM departments;
SELECT * FROM enrollments;
SELECT * FROM faculty;



-- Part 6: Querying the Database

-- 1. Retrieve all students who enrolled in a specific course
SELECT s.student_id, s.first_name, s.last_name, e.course_id, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_code = 'MATH101'; 


-- 2. Find all faculty members in a particular department
SELECT f.faculty_id, f.first_name, f.last_name, d.department_name
FROM faculty f
JOIN departments d ON f.department_id = d.department_id
WHERE d.department_name = 'Web'; 


-- 3. List all courses a particular student is enrolled in
SELECT s.student_id, s.first_name, s.last_name, c.course_code, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.student_id = 1;


-- 4. Retrieve students who have not enrolled in any course
SELECT s.student_id, s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;


-- 5. Find the average grade of students in a specific course
SELECT c.course_code, c.course_name, AVG(e.grade) AS average_grade
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_code = 'CS101' 
GROUP BY c.course_code, c.course_name;




-- Bonus

-- Implement a trigger to update a student's GPA when a grade is updated.
DELIMITER $$
CREATE TRIGGER update_gpa 
AFTER UPDATE ON enrollments 
FOR EACH ROW 
BEGIN 
    DECLARE new_gpa DECIMAL(3,2);

    -- Convert grade to 4.0 scale
    IF NEW.grade >= 90 THEN
        SET new_gpa = 4.0;
    ELSEIF NEW.grade >= 80 THEN
        SET new_gpa = 3.0;
    ELSEIF NEW.grade >= 70 THEN
        SET new_gpa = 2.0;
    ELSEIF NEW.grade >= 60 THEN
        SET new_gpa = 1.0;
    ELSE
        SET new_gpa = 0.0;
    END IF;

    -- Update the student's GPA
    UPDATE students 
    SET gpa = new_gpa 
    WHERE student_id = NEW.student_id;
END$$
DELIMITER ;

UPDATE enrollments SET grade = 92 WHERE student_id = 1 AND course_id = 1;
UPDATE enrollments SET grade = 85 WHERE student_id = 2 AND course_id = 2;
UPDATE enrollments SET grade = 70 WHERE student_id = 3 AND course_id = 3;

SELECT student_id, gpa FROM students WHERE student_id = 1;
SELECT student_id, gpa FROM students WHERE student_id = 2;
SELECT student_id, gpa FROM students WHERE student_id = 3;



-- Design a stored procedure to enroll a student in a course.
DELIMITER //

CREATE PROCEDURE EnrollStudent(
    IN p_student_id INT, 
    IN p_course_id INT
)
BEGIN
    -- Check if student exists
    IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = p_student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Student does not exist.';
    END IF;

    -- Check if course exists
    IF NOT EXISTS (SELECT 1 FROM courses WHERE course_id = p_course_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Course does not exist.';
    END IF;

    -- Insert enrollment record
    INSERT INTO enrollments (student_id, course_id, enrollment_date)
    VALUES (p_student_id, p_course_id, CURDATE());

END //

DELIMITER ;

CALL EnrollStudent(1, 2);



