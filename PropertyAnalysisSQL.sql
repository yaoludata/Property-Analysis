/*--------------------------------------------------------------------------------------------
Task 1.a Display a list of all property names and their property id’s for Owner Id: 1426
*/
SELECT p.Name, p.Id
FROM Property AS p
LEFT JOIN OwnerProperty AS op
ON p.Id = op.PropertyId
WHERE op.OwnerId = '1426'

/*--------------------------------------------------------------------------------------------
Task 1.b Display the current home value for each property in question a)
*/
SELECT p.Name, pv.PropertyId, pv.Value
FROM PropertyHomeValue pv
INNER JOIN (SELECT p.Name, p.Id
FROM Property AS p
LEFT JOIN OwnerProperty AS op
ON p.Id = op.PropertyId
WHERE op.OwnerId = '1426') p
ON pv.PropertyId = p.Id
WHERE pv.IsActive = 1

/*---------------------------------------------------------------------------------------------
Task 1.c For each property in question a), return the following: 
i) Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query that returns 
the sum of all payments from start date to end date. 
*/
SELECT p.Name AS Property_Name, p.Id AS Property_ID, tp.StartDate, tp.EndDate, trt.Name AS RentalPaymentFrequency, rp.Amount AS RentalPaymentAmount, 
CASE

WHEN trt.Id = 1

THEN

DATEDIFF(Week,tp.StartDate,tp.EndDate)* rp.Amount

WHEN trt.Id = 2

THEN

(DATEDIFF(Week,tp.StartDate,tp.EndDate)/2)* rp.Amount

WHEN trt.Id = 3

THEN

DATEDIFF(Month,tp.StartDate,tp.EndDate)* rp.Amount
ELSE ''

END TotalPaymentAmount
FROM Keys.dbo.Property AS p
LEFT JOIN Keys.dbo.OwnerProperty AS o
ON p.Id = o.PropertyId
LEFT JOIN Keys.dbo.PropertyHomeValue AS v
ON p.Id = v.PropertyId
LEFT JOIN Keys.dbo.TenantProperty tp
ON p.Id = tp.PropertyId
LEFT JOIN PropertyRentalPayment AS rp
ON p.id = rp.PropertyId
LEFT JOIN TargetRentType as trt
on rp.FrequencyType = trt.Id
WHERE o.OwnerId = '1426'
AND v.IsActive = '1';

/*---------------------------------------------------------------------------------------------
Task 1.c For each property in question a), return the following: 
ii) Display the yield. 
*/
SELECT p.Name AS Property_Name, p.Id AS Property_ID, v.Value AS CurrentHomeValue, tp.StartDate, tp.EndDate, pe.Amount AS PropertyExpense, pe.Description AS ExpenseDescription, trt.Name AS RentalPaymentFrequency, rp.Amount AS RentalPaymentAmount, 
(
(
(CASE

WHEN trt.Id  = 1

THEN

DATEDIFF(Week,tp.StartDate,tp.EndDate)* rp.Amount

WHEN trt.Id  = 2

THEN

(DATEDIFF(Week,tp.StartDate,tp.EndDate)/2)* rp.Amount

WHEN trt.Id  = 3

THEN

DATEDIFF(Month,tp.StartDate,tp.EndDate)* rp.Amount
ELSE ''

END ) 
- ISNULL(SUM(pe.Amount), 0))/v.Value)*100 AS Yield
FROM Keys.dbo.Property AS p
LEFT JOIN Keys.dbo.OwnerProperty AS o
ON p.Id = o.PropertyId
LEFT JOIN Keys.dbo.PropertyHomeValue AS v
ON p.Id = v.PropertyId
LEFT JOIN Keys.dbo.TenantProperty AS tp
ON p.Id = tp.PropertyId
LEFT JOIN PropertyRentalPayment AS rp
ON p.id = rp.PropertyId
LEFT JOIN TargetRentType as trt
on rp.FrequencyType = trt.Id
LEFT JOIN PropertyExpense AS pe
on p.id = pe.PropertyId
WHERE o.OwnerId = '1426'
and v.IsActive = '1'
GROUP BY p.Name, p.Id, v.Value, tp.StartDate, tp.EndDate, pe.Amount, pe.Description, trt.Name, rp.Amount , trt.Id

/*---------------------------------------------------------------------------------------------
Task 1.d. Display all the jobs available in the marketplace (jobs that owners have advertised for service suppliers). 
*/
SELECT DISTINCT j.Id AS JobID, j.PropertyId, j.OwnerId, J.JobDescription, jm.IsActive
FROM Job AS j
INNER Join JobMedia AS jm
ON j.Id = jm.JobId
WHERE jm.IsActive = 1

/*---------------------------------------------------------------------------------------------
Task 1.e. Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for 
the properties in question a). 
*/
SELECT p.Name AS Property_Name, pe.FirstName, pe.LastName, rp.Amount AS RentalPaymentAmount, trt.Name AS  RentalPaymentFrequency
FROM Keys.dbo.Property AS p
LEFT JOIN Keys.dbo.TenantProperty AS tp
ON p.Id = tp.PropertyId
LEFT JOIN Keys.dbo.Person AS pe
ON tp.TenantId = pe.Id
LEFT JOIN Keys.dbo.OwnerProperty AS o
ON p.Id = o.PropertyId
LEFT JOIN Keys.dbo.PropertyRentalPayment AS rp
ON p.id = rp.PropertyId
LEFT JOIN Keys.dbo.TargetRentType AS trt
on rp.FrequencyType = trt.Id
WHERE o.OwnerId = '1426';

/*-----------------------------------------------------------------------------------------------
Set up dataset for Report Builder or Visual Studio (SSRS) to develop the report
*/
Select p.Id,p.[Name] AS PropertyName
, RTRIM(LTRIM(
CONCAT(
COALESCE(Person.FirstName + ' ', '')
, COALESCE(Person.MiddleName + ' ', '')
, COALESCE(Person.Lastname, '')
)
)) AS OwnerName
, RTRIM(LTRIM(
CONCAT(
COALESCE(a.Number + ' ', '')
, COALESCE(a.Street + ' ', '')
, COALESCE(a.Suburb + ' ', '')
, COALESCE(a.PostCode + ' ', '')
, COALESCE(a.Region + ' ', '')
, COALESCE(Country.[Name], '')
)
)) AS PropertyAddress
, CONCAT(p.Bathroom,' Bathroom, ',p.Bedroom,' Bedroom, ',p.ParkingSpace,' ParkingSpace') AS PropertyDetails
, prp.Amount as RentalAmount
, CASE 
WHEN trt.[Name] ='Weekly' THEN 'Week'
WHEN trt.[Name] ='Fortnightly' THEN 'Fortnight'
ELSE 'Month'
 END AS RentalPaymentFrequency
, e.[Description], e.Amount, e.[Date]
FROM Property AS p 
INNER JOIN OwnerProperty AS op ON p.Id=op.PropertyId
INNER JOIN Owners AS o ON op.OwnerId=o.Id
INNER JOIN Person ON o.Id=Person.Id
INNER JOIN [Address] AS a ON p.AddressId=a.AddressId
INNER JOIN Country ON a.CountryId=Country.Id
INNER JOIN PropertyRentalPayment AS prp ON p.Id=prp.PropertyId
INNER JOIN TargetRentType as trt ON prp.FrequencyType=trt.Id
LEFT JOIN PropertyExpense AS e ON p.Id=e.PropertyId
WHERE p.[Name]=@Property

