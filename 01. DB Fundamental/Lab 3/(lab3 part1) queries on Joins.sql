use Company_SD

Select * From Departments;
SELECT * FROM Dependent;
Select * from Employee;
SELECT * FROM Project;
SELECT * FROM WORKS_FOR;

-- 1.	Display the Department id, name and id and the name of its manager.
SELECT d.Dname, d.Dnum , e.SSN , e.Fname
FROM Departments d
JOIN Employee e ON d.MGRSSN = e.SSN;

-- 2.	Display the name of the departments and the name of the projects under its control.
SELECT d.Dname , p.Pname
FROM Departments d
JOIN Project p ON d.Dnum = p.Dnum;

-- 3.	Display the full data about all the dependence associated with the name of the employee they depend on him/her.
SELECT d.* , e.Fname
FROM Dependent d
JOIN Employee e ON d.ESSN = e.SSN;

-- 4.	Display the Id, name and location of the projects in Cairo or Alex city.
SELECT Pnumber , Pname , Plocation
FROM Project
WHERE City LIKE 'Cairo' OR City LIKE 'Alex';

-- 5.	Display the Projects full data of the projects with a name starts with "a" letter.
SELECT * 
FROM Project
WHERE Pname LIKE 'a%';

-- 6.	display all the employees in department 30 whose salary from 1000 to 2000 LE monthly
SELECT e.* 
FROM Employee e
WHERE Dno = 30 AND e.Salary Between 1000 AND 2000;

-- 7.	Retrieve the names of all employees in department 10 who works more than or equal 10 hours per week on "AL Rabwah" project.
SELECT DISTINCT e.* 
FROM Employee e
JOIN Works_for w ON e.SSN = w.ESSn
JOIN Project p ON w.Pno = p.Pnumber
WHERE Dno = 10 AND w.Hours >= 10 AND p.Pname = 'Al Rabwah';

-- 8.	Find the names of the employees who directly supervised with Kamel Mohamed.
SELECT e1.Fname, e1.Lname
FROM Employee e1
JOIN Employee e2 ON e1.Superssn = e2.SSN
WHERE e2.Fname = 'Kamel' AND e2.Lname = 'Mohamed';

-- 9.	Retrieve the names of all employees and the names of the projects they are working on, sorted by the project name.
SELECT DISTINCT e.Fname , p.Pname
FROM Employee e
JOIN Project p ON e.Dno = p.Dnum
JOIN Works_for w ON p.Pnumber = w.Pno
order by p.Pname;

-- 10.	For each project located in Cairo City , find the project number, the controlling department name ,the department manager last name ,address and birthdate.
SELECT p.Pnumber, d.Dname , e.Lname , e.Address , e.Bdate
FROM Project p
JOIN Departments d ON p.Dnum = d.Dnum
JOIN Employee e ON d.MGRSSN = e.SSN
WHERE p.City = 'Cairo';

-- 11.	Display All Data of the managers
SELECT e.*
FROM Employee e
JOIN Departments d ON e.SSN = d.MGRSSN

-- 12.	Display All Employees data and the data of their dependents even if they have no dependents
SELECT DISTINCT e.* , d.*
FROM Employee e
JOIN Dependent d ON e.SSN = d.ESSN OR e.SSN = d.ESSN;

-- 13.	Insert your personal data to the employee table as a new employee in department number 30, SSN = 102672, Superssn = 112233, salary=3000.
INSERT INTO Employee
VALUES ( 'Kholod' , 'Sadek' , 102672 , '2004-03-11' , '101 Haram St.Giza' , 'F' , 3000 , 112233 , 30 )

-- 14.	Insert another employee with personal data your friend as new employee in department number 30, SSN = 102660, but don’t enter any value for salary or supervisor number to him.
INSERT INTO Employee (Fname, Lname, SSN, Bdate, Address, Sex, Dno)
VALUES ( 'Malak' , 'Wael' , 102660 , '2003-11-21' , '41 Haram St.Giza' , 'F' , 30 )

-- 15.	Upgrade your salary by 20 % of its last value.
UPDATE Employee
SET Salary = Salary * 1.2
WHERE SSN = 102672;
