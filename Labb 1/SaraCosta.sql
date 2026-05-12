-- MoonMissions uppgift:

SELECT 
    Spacecraft,
    [Launch date],
    [Carrier rocket],
    Operator,
    [Mission type]
INTO SuccessfulMissions
FROM MoonMissions
WHERE Outcome = 'Successful'

GO

UPDATE SuccessfulMissions
SET Operator = TRIM(Operator)

GO

UPDATE SuccessfulMissions
SET Spacecraft = LEFT(Spacecraft, CHARINDEX('(', Spacecraft + '(') - 2)

GO

SELECT 
    Operator,
    [Mission type],
    COUNT(*) AS [Mission count]
FROM SuccessfulMissions
GROUP BY Operator, [Mission type]
HAVING COUNT(*) > 1
ORDER BY Operator, [Mission type]

GO

-- Users uppgift:

SELECT 
    ID,
    UserName,
    Password,
    FirstName,
    LastName,
    Email,
    Phone,
    FirstName + ' ' + LastName AS Name,
    CASE 
        WHEN SUBSTRING(ID, LEN(ID)-1, 1) % 2 = 0 THEN 'Female'
        ELSE 'Male'
    END AS Gender
INTO NewUsers
FROM Users

GO

SELECT 
    UserName, 
    COUNT(*) AS DuplicateCount 
FROM NewUsers 
GROUP BY Username 
HAVING COUNT(*) > 1

GO

--Förlänger antal bokstäver i COLUMN pga error message att
--man går över limit
ALTER TABLE NewUsers
ALTER COLUMN Username VARCHAR(50)

GO

WITH cte AS (
    SELECT 
        Id,
        Username,
        ROW_NUMBER() OVER (PARTITION BY Username ORDER BY Id) AS nr
    FROM NewUsers
)


UPDATE cte
SET Username = Username + CAST(nr AS VARCHAR)
WHERE nr > 1

GO

DELETE FROM NewUsers 
WHERE Gender = 'Female' 
AND LEFT(ID, 4) < '1970' 

GO

INSERT INTO NewUsers (ID, UserName, FirstName, LastName, Email, Phone, [Name], Gender)
VALUES ('000427-0000', 'sarcos', 'Sara', 'Costa', 'sara.costa@iths.se', '0707-000000', 'Sara Costa', 'Female')

GO

SELECT 
    Gender,
    AVG(
        DATEDIFF(
            YEAR,
            TRY_CONVERT(date,
                CASE 
                    WHEN LEFT(ID, 2) <= RIGHT(YEAR(GETDATE()), 2)
                    THEN '20'
                    ELSE '19'
                END
                + LEFT(ID, 2) + '-' +
                SUBSTRING(ID, 3, 2) + '-' +
                SUBSTRING(ID, 5, 2)
            ),
            GETDATE()
        )
    ) AS [average age]
FROM NewUsers
GROUP BY Gender

GO

-- Company (Joins) uppgift

SELECT 
    company.products.Id,
    company.products.ProductName AS Product,
    company.suppliers.CompanyName AS Supplier,
    company.categories.CategoryName AS Category
FROM company.products
JOIN company.suppliers
ON company.products.SupplierId = company.suppliers.Id
JOIN company.categories
ON company.products.CategoryId = company.categories.Id

GO

SELECT company.regions.RegionDescription, 
    COUNT(DISTINCT company.employee_territory.EmployeeId) AS NumberOfEmployees
FROM company.regions
JOIN company.territories 
    ON company.regions.Id = company.territories.RegionId
JOIN company.employee_territory 
    ON company.territories.Id = company.employee_territory.TerritoryId
GROUP BY company.regions.RegionDescription
ORDER BY company.regions.RegionDescription

GO

SELECT 
    company.employees.Id,
    company.employees.TitleOfCourtesy + ' ' + company.employees.FirstName + ' ' + company.employees.LastName AS Name,
    ISNULL(managers.TitleOfCourtesy + ' ' + managers.FirstName + ' ' + managers.LastName, 'Nobody!') AS [Reports to]
FROM company.employees
LEFT JOIN company.employees AS managers ON company.employees.ReportsTo = managers.Id
ORDER BY company.employees.Id

GO