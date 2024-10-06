use ITI;
use COMPANY;

-- 1.	Create a stored procedure without parameters to show the number of students per department name.[use ITI DB] 
CREATE PROCEDURE GetStudentsPerDepartment
AS
BEGIN
    SELECT d.Dept_Name, COUNT(s.St_Id) AS NumberOfStudents
    FROM Department d
    LEFT JOIN Student s ON d.Dept_Id = s.Dept_Id
    GROUP BY d.Dept_Name;
END;

EXEC GetStudentsPerDepartment;

-- 2.	Create a stored procedure that will check for the # of employees in the project p1 if they are more than 3 print 
-- message to the user “'The number of employees in the project p1 is 3 or more'” if they are less display a message to 
-- the user “'The following employees work for the project p1'” in addition to the first name and last name of each one. [Company DB]

CREATE PROCEDURE CheckProjectP1Employees
AS
BEGIN
    DECLARE @EmployeeCount INT;

    -- Count the number of employees in project 'p1'
    SELECT @EmployeeCount = COUNT(e.SSN)
    FROM Employee e
	JOIN WORKS_ON w ON e.SSN = w.Essn
    JOIN Project p ON w.Pno = p.Pnumber
    WHERE p.Pname = 'p1';

    -- If the number of employees is 3 or more
    IF @EmployeeCount >= 3
    BEGIN
        PRINT 'The number of employees in the project p1 is 3 or more';
    END
    ELSE
    BEGIN
        PRINT 'The following employees work for the project p1:';
        
        -- Select and print the first name and last name of employees in project 'p1'
        SELECT e.Fname, e.Lname
        FROM Employee e
        JOIN WORKS_ON w ON e.SSN = w.Essn
	    JOIN Project p ON w.Pno = p.Pnumber
        WHERE p.Pname = 'p1';
    END
END;

EXEC CheckProjectP1Employees;

-- 3.	Create a stored procedure that will be used in case there is an old employee has left the project and a new one 
-- become instead of him. The procedure should take 3 parameters (old Emp. number, new Emp. number and the project number) 
--and it will be used to update works_on table. [Company DB]
SELECT * FROM WORKS_ON;

CREATE PROCEDURE ReplaceEmployees(@oldEmp_Number int , @newEmp_Number int , @Project_Number int)
AS
BEGIN
	UPDATE WORKS_ON
	SET Essn = @newEmp_Number
	WHERE Essn = @oldEmp_Number AND Pno = @Project_Number
END;

-- 4.	add column budget in project table and insert any draft values in it then 
--     then Create an Audit table with the following structure 
-- ProjectNo 	UserName 	ModifiedDate 	Budget_Old 	Budget_New 
-- p2 			Dbo 		2008-01-31		95000		200000 

ALTER TABLE PROJECT
ADD Budget int;

UPDATE PROJECT
SET Budget = 100000
WHERE Pname = 'p1';

UPDATE PROJECT
SET Budget = 200000 
WHERE Pname = 'p2';

-- Create the Audit table
CREATE TABLE Audit (
    ProjectNo VARCHAR(50),
    UserName VARCHAR(50),
    ModifiedDate DATETIME,
    Budget_Old INT,
    Budget_New INT
);

-- Update the budget for project 'p2' and insert an audit record
DECLARE @OldBudget INT;
DECLARE @NewBudget INT;
DECLARE @ProjectNo VARCHAR(50);

-- Get the current budget value before updating
SELECT @OldBudget = Budget FROM PROJECT WHERE Pname = 'p2';

-- Update the budget value for project 'p2'
UPDATE PROJECT
SET Budget = 250000 -- new value
WHERE Pname = 'p2';

-- Get the new budget value after updating
SELECT @NewBudget = Budget FROM PROJECT WHERE Pname = 'p2';
SET @ProjectNo = 'p2';

-- Insert the audit record
INSERT INTO Audit (ProjectNo, UserName, ModifiedDate, Budget_Old, Budget_New)
VALUES (@ProjectNo, 'Dbo', GETDATE(), @OldBudget, @NewBudget);

SELECT * FROM PROJECT;
SELECT * FROM Audit;

-- 5.	Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB]
-- “Print a message for user to tell him that he can’t insert a new record in that table”

SELECT * FROM Department;

CREATE TRIGGER PreventInsertOnDepartment
ON Department
INSTEAD OF INSERT
AS
BEGIN
    -- Print message to the user
    SELECT 'You cannot insert a new record in the Department table.';
END;
INSERT INTO Department (Dept_Id, Dept_Name)
VALUES (101, 'New Department');

-- 6.	 Create a trigger that prevents the insertion Process for Employee table in March [Company DB].
SELECT * FROM Employee;

CREATE TRIGGER PreventInsertEmployee
ON Employee
INSTEAD OF INSERT
AS
BEGIN
    -- Check if the current month is March
    IF MONTH(GETDATE()) = 3
    BEGIN
        -- Print message and block the insertion
        PRINT 'You cannot insert a new employee in the month of March.';
    END
END;

-- 7.	Create a trigger on student table after insert to add Row in Student Audit table 
-- (Server User Name , Date, Note) where note will be “[username] Insert New Row with Key=[Key Value] in table [table name]”
-- Server User Name		Date	Note 
SELECT * FROM Student;

CREATE TABLE StudentAudit (
    ServerUserName VARCHAR(100),
    Date DATETIME,
    Note VARCHAR(255)
);

CREATE TRIGGER AddToStudentAudit
ON Student
AFTER INSERT
AS
BEGIN
    -- Declare variables for the audit
    DECLARE @ServerUserName VARCHAR(100);
    DECLARE @StudentID INT;
    DECLARE @Note VARCHAR(255);

    -- Get the server user name (current system user)
    SET @ServerUserName = SYSTEM_USER;

    -- Get the inserted StudentID (assuming single row insert)
    SELECT @StudentID = St_Id FROM inserted;

    -- Create the audit note
    SET @Note = @ServerUserName + ' Insert New Row with Key=' + CAST(@StudentID AS VARCHAR(10)) + ' in table Student';

    -- Insert a row into the StudentAudit table
    INSERT INTO StudentAudit (ServerUserName, Date, Note)
    VALUES (@ServerUserName, GETDATE(), @Note);
END;

-- 8.  Create a trigger on student table instead of delete to add Row in Student Audit table 
-- (Server User Name, Date, Note) where note will be“ try to delete Row with Key=[Key Value]”

CREATE TRIGGER LogDeleteAttemptOnStudent
ON Student
INSTEAD OF DELETE
AS
BEGIN
    -- Declare variables for audit logging
    DECLARE @ServerUserName VARCHAR(100);
    DECLARE @StudentID INT;
    DECLARE @Note VARCHAR(255);

    -- Get the server user name (current system user)
    SET @ServerUserName = SYSTEM_USER;

    -- Loop through deleted rows (in case of multiple deletions)
    DECLARE DeleteCursor CURSOR FOR
    SELECT St_Id FROM deleted;

    OPEN DeleteCursor;

    FETCH NEXT FROM DeleteCursor INTO @StudentID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create the audit note for each deleted row
        SET @Note = 'Try to delete Row with Key=' + CAST(@StudentID AS VARCHAR(10));

        -- Insert into the StudentAudit table
        INSERT INTO StudentAudit (ServerUserName, Date, Note)
        VALUES (@ServerUserName, GETDATE(), @Note);

        -- Fetch the next row
        FETCH NEXT FROM DeleteCursor INTO @StudentID;
    END;

    CLOSE DeleteCursor;
    DEALLOCATE DeleteCursor;

    -- Prevent the actual deletion (no DELETE statement here)
END;