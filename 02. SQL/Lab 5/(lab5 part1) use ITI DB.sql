use ITI

SELECT * FROM Course;
SELECT * FROM Department;
SELECT * FROM Ins_Course;
SELECT * FROM Topic;
SELECT * FROM Instructor;
SELECT * FROM Student;
SELECT * FROM Stud_Course;

-- 1.	Retrieve number of students who have a value in their age. 
SELECT COUNT(St_Id)
From Student
WHERE St_Age IS NOT NULL;

-- 2.	Get all instructors Names without repetition
SELECT DISTINCT Ins_Name
FROM Instructor;

-- 3.	Display student with the following Format (use isNull function)
	-- Student ID	Student Full Name	Department name
SELECT s.St_Id , CONCAT(s.St_Fname,' ' ,s.St_Lname) Full_Name , d.Dept_Name
FROM Student s
JOIN Department d ON s.Dept_Id = d.Dept_Id
WHERE s.St_Id is NULL;

-- 4.	Display instructor Name and Department Name 
	-- Note: display all the instructors if they are attached to a department or not
SELECT i.Ins_Name , d.Dept_Name
FROM Instructor i
LEFT JOIN Department d ON i.Dept_Id = d.Dept_Id;

-- 5.	Display student full name and the name of the course he is taking For only courses which have a grade  
SELECT CONCAT(s.St_Fname , ' ', s.St_Lname) Full_Name , c.Crs_Name
FROM Stud_Course sc
JOIN Student s ON sc.St_Id = s.St_Id
JOIN Course c ON sc.Crs_Id = c.Crs_Id
WHERE sc.Grade IS NOT NULL;

-- 6.	Display number of courses for each topic name
SELECT t.Top_Name , COUNT(c.Crs_Id) num_of_Courses
FROM Course c
JOIN Topic t ON c.Top_Id = t.Top_Id
GROUP BY t.Top_Name;

-- 7.	Display max and min salary for instructors
SELECT Ins_Name , MAX(Salary) max_Salary , MIN(Salary) min_Salary
FROM Instructor
GROUP BY Ins_Name;

-- 8.	Display instructors who have salaries less than the average salary of all instructors.
SELECT Ins_Name 
FROM Instructor
WHERE Salary < ( SELECT AVG(Salary) FROM Instructor );

-- 9.	Display the Department name that contains the instructor who receives the minimum salary.
SELECT d.Dept_Name
FROM Department d
JOIN Instructor i ON d.Dept_Id = i.Dept_Id
WHERE i.Salary = ( SELECT MIN(Salary) FROM Instructor );

--10.  Select max two salaries in instructor table. 
SELECT MAX(Salary) maxSalary1
FROM Instructor
SELECT MAX(Salary) AS maxSalary2
FROM Instructor
WHERE Salary < (SELECT MAX(Salary) FROM Instructor);

--11.  Select instructor name and his salary but if there is no salary display instructor bonus keyword. “use coalesce Function”
SELECT Ins_Name, COALESCE(CAST(Salary AS VARCHAR), 'Bonus') AS Salary_or_Bonus
FROM Instructor;

-- 12.	Select Average Salary for instructors 
SELECT AVG(Salary) AS average_Salary
FROM Instructor;

-- 13.	Select Student first name and the data of his supervisor 
SELECT s1.St_Fname AS Student_FirstName, s2.St_Fname AS Supervisor_FirstName, s2.St_Lname AS Supervisor_LastName , s2.St_Id AS Supervisor_ID
FROM Student s1
JOIN Student s2 ON s1.St_super = s2.St_Id;

-- 14.	Create a view that displays student full name, course name if the student has a grade more than 50. 
CREATE VIEW StudentCourseAbove50
AS
SELECT CONCAT(s.St_Fname, ' ', s.St_Lname) AS Full_Name, 
       c.Crs_Name AS Course_Name, 
       sc.Grade
FROM Stud_Course sc
JOIN Student s ON sc.St_Id = s.St_Id
JOIN Course c ON sc.Crs_Id = c.Crs_Id
WHERE sc.Grade > 50;

Select * From StudentCourseAbove50;

-- 15.  Create an Encrypted view that displays manager names and the topics they teach. 
CREATE VIEW EncryptedManagerTopics
WITH ENCRYPTION
AS
SELECT d.Dept_Manager, t.Top_Name
FROM Department d
JOIN Instructor i ON d.Dept_Manager = i.Ins_Id
JOIN Ins_Course ic ON i.Ins_Id = ic.Ins_Id
JOIN Course c ON ic.Crs_Id = c.Crs_Id
JOIN Topic t ON c.Top_Id = t.Top_Id;

-- Drop the existing view
DROP VIEW IF EXISTS EncryptedManagerTopics;

Select * From EncryptedManagerTopics;

-- 16.	Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department 
CREATE VIEW InstructorDepartment
AS
SELECT i.Ins_Name , d.Dept_Name
FROM Instructor i
JOIN Department d ON i.Dept_Id = d.Dept_Id
WHERE d.Dept_Name = 'SD' OR d.Dept_Name = 'Java';

Select * From InstructorDepartment;