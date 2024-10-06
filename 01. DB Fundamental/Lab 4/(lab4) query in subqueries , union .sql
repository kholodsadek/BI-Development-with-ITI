use Company_SD

Select * From Departments;
Select * from Employee;
SELECT * FROM Dependent;
SELECT * FROM Project;
SELECT * FROM WORKS_FOR;

-- 1.	Display (Using Union Function)
--		a. The name and the gender of the dependence that's gender is Female and depending on Female Employee.
SELECT d.Dependent_name, d.Sex 
FROM Dependent d
JOIN Employee e ON d.ESSN = e.SSN
WHERE d.Sex = 'F' AND e.Sex = 'F'
UNION ALL	 -- b.	 And the male dependence that depends on Male Employee.
SELECT d.Dependent_name, d.Sex 
FROM Dependent d
JOIN Employee e ON d.ESSN = e.SSN
WHERE d.Sex = 'M' AND e.Sex = 'M';



-- 2.	For each project, list the project name and the total hours per week (for all employees) spent on that project.
SELECT p.Pname , sum(w.Hours) totalHours
FROM Project p
JOIN Works_for w ON p.Pnumber = w.Pno
Group by p.Pname;

-- 3.	Display the data of the department which has the smallest employee ID over all employees' ID.
SELECT d.* , e.SSN
FROM Departments d
JOIN Employee e ON d.Dnum = e.Dno
WHERE e.SSN = (SELECT MIN(SSN) FROM Employee);

-- 4.	For each department, retrieve the department name and the maximum, minimum and average salary of its employees.
SELECT d.Dname , MAX(e.Salary) maxSalary , MIN(e.Salary) minSalary , AVG(e.Salary) avgSalary
FROM Departments d
JOIN Employee e ON e.Dno = d.Dnum
GROUP BY d.Dname;

-- 5.	List the full name of all managers who have no dependents.
SELECT DISTINCT e.Fname , e.Lname 
FROM Employee e
JOIN Departments d ON e.SSN = d.MGRSSN
WHERE e.SSN NOT IN (Select ESSN FROM Dependent)

-- 6.	For each department-- if its average salary is less than the average salary of all employees-- display its number, name and number of its employees.
SELECT d.Dname, d.Dnum, COUNT(e.SSN) AS NumOfEmployees
FROM Departments d
JOIN Employee e ON d.Dnum = e.Dno
GROUP BY d.Dname, d.Dnum
HAVING AVG(e.Salary) < (SELECT AVG(Salary) FROM Employee);

-- 7.	Retrieve a list of employee’s names and the projects names they are working on ordered by department number and within each department, ordered alphabetically by last name, first name.
SELECT DISTINCT e.Fname, e.Lname, p.Pname, d.Dnum
FROM Employee e
JOIN Departments d ON e.Dno = d.Dnum
JOIN Works_for w ON e.SSN = w.ESSn  
JOIN Project p ON w.Pno = p.Pnumber 
ORDER BY d.Dnum, e.Lname, e.Fname;

-- 8.	Try to get the max 2 salaries using sub query
SELECT MAX(Salary) maxSalary1
FROM Employee
SELECT MAX(Salary) AS maxSalary2
FROM Employee
WHERE Salary < (SELECT MAX(Salary) FROM Employee);

-- 9.	Get the full name of employees that is similar to any dependent name
SELECT CONCAT(e.Fname, ' ', e.Lname) AS FullName, d.Dependent_name
FROM Employee e
JOIN Dependent d ON e.SSN = d.ESSN
WHERE d.Dependent_name LIKE CONCAT('%', e.Fname, ' ', e.Lname, '%');

-- 10.	Display the employee number and name if at least one of them have dependents (use exists keyword) self-study.
SELECT e.SSN, e.Fname, e.Lname
FROM Employee e
WHERE EXISTS (
    SELECT 1 
    FROM Dependent d
    WHERE e.SSN = d.ESSN
);

-- 11.	In the department table insert new department called "DEPT IT”, with id 100, employee with SSN = 112233 as a manager for this department. The start date for this manager is '1-11-2006'
INSERT INTO Departments
VALUES ('DEPT IT', 100, 112233, '1-11-2006');

-- 12.	Do what is required if you know that : Mrs.Noha Mohamed(SSN=968574)  moved to be the manager of the new department (id = 100), and they give you(your SSN =102672) her position (Dept. 20 manager) 
--	a.	First try to update her record in the department table
Update Departments
SET MGRSSN = 968574
WHERE Dnum = 100;
--	b.	Update your record to be department 20 manager.
UPDATE Employee
SET Dno = 20 
WHERE SSN = 102672;
--	c.	Update the data of employee number=102660 to be in your teamwork (he will be supervised by you) (your SSN =102672)
UPDATE Employee
Set Superssn = 102672
WHERE SSN = 102660;

-- 13.	Unfortunately the company ended the contract with Mr. Kamel Mohamed (SSN=223344) so try to delete his data from your database in case you know that you will be temporarily in his position.
-- Hint: (Check if Mr. Kamel has dependents, works as a department manager, supervises any employees or works in any projects and handle these cases).
SELECT Dependent_name
FROM Dependent
WHERE ESSN = 223344;

UPDATE Dependent
SET ESSN = 102672
WHERE ESSN = 223344;

SELECT *
FROM Departments
WHERE MGRSSN = 223344;

UPDATE Departments
SET MGRSSN = 102672
WHERE MGRSSN = 223344;

SELECT * 
FROM Employee
WHERE Superssn = 223344;

UPDATE Employee
SET Superssn = 102672
WHERE Superssn = 223344;

SELECT *
FROM Works_for
WHERE ESSn = 223344

UPDATE Works_for
SET ESSn = 102672
WHERE ESSn = 223344;

DELETE FROM Employee
WHERE SSN = 223344;

-- 14.	Try to update all salaries of employees who work in Project ‘Al Rabwah’ by 30%
UPDATE Employee
SET Salary = Salary * 1.30
WHERE SSN IN (
    SELECT e.SSN
    FROM Employee e
    JOIN Works_for w ON e.SSN = w.Essn
    JOIN Project p ON w.Pno = p.Pnumber
    WHERE p.Pname = 'Al Rabwah'
);