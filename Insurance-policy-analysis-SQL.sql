CREATE DATABASE InsuranceAnalysis;
Use InsuranceAnalysis;

-- TABLE CREATION
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100),
Age INT,
City VARCHAR(50),
Gender VARCHAR(10)
)

SHOW TABLES;
DESCRIBE Customers;

-- INSETING DATA INTO TABLE
INSERT INTO Customers
(CustomerID, CustomerName, Age, City, Gender)
VALUES
(1,'Amit Sharma', 30, 'Mumbai', 'Male'),
(2,'Priya Patel', 25, 'Pune', 'Female'),
(3, 'Rahul Verma', 40, 'Delhi', 'Male'),
(4, 'Neha Shah', 35, 'Mumbai', 'Female'),
(5, 'Sneha Joshi', 28, 'Pune', 'Female');

-- BASIC ANALYSIS
-- Q1 Display all the customers
SELECT * FROM Customers;

-- Q2 Find the customers how live in Mumbai
SELECT * FROM Customers WHERE City = 'Mumbai';

-- Q3 Find the customers older than 30
SELECT * FROM Customers WHERE Age> 30;

-- Q4 Count the total number of customers
SELECT count(*) AS TotalCustomers FROM Customers;

-- TABLE CREATION
CREATE TABLE Policies (
PolicyID INT PRIMARY KEY,
CustomerID INT,
PolicyType VARCHAR(50),
PremiumAmount DECIMAL(10,2),
PolicyStatus VARCHAR(20),
FOREIGN KEY (CustomerID)
	REFERENCES Customers(CustomerID)
    );

-- INSETING DATA INTO TABLE  
INSERT INTO Policies
(PolicyID, CustomerID, PolicyType, PremiumAmount, PolicyStatus)
VALUES
(101, 1, 'Life', 25000, 'Active'),
(102, 2, 'Health', 18000, 'Active'),
(103, 3, 'Life', 30000, 'Lapsed'),
(104, 4, 'Health', 22000, 'Active'),
(105, 5, 'Life', 15000, 'Active');

-- BASIC ANALYSIS
-- Q1 How many policies are active?
SELECT COUNT(*) AS ActivePolicies
FROM Policies
WHERE PolicyStatus = 'Active';

-- Q2 What is the total premium amount across all policies?
SELECT SUM(PremiumAmout) AS TotalPremium FROM Policies;

-- Q3 How many life and health policies exist?
SELECT PolicyType, COUNT(*) AS TotalPolicy FROM Policies GROUP BY PolicyType;

-- Q3 Which policies have lapsed?
SELECT * FROM Policies WHERE PolicyStatus = 'Lapsed';

-- TABLE CREATION
CREATE TABLE Payments (
PaymentID INT PRIMARY KEY,
PolicyID INT,
PaymentDate DATE,
PaymentAmount DECIMAL(10,2),
PaymentStatus VARCHAR(20),
FOREIGN KEY (PolicyID)
  REFERENCES Policies(PolicyID)
  );
  
-- INSETING DATA INTO TABLE 
INSERT INTO Payments
(PaymentID, PolicyID, PaymentDate, PaymentAmount, PaymentStatus)
VALUES
(1001, 101,'2026-01-15', 25000, 'Paid'),
(1002, 102, '2026-02-10', 18000, 'Paid'),
(1003, 103, '2026-02-20', 30000, 'Pending'),
(1004, 104, '2026-03-05', 22000, 'Paid'),
(1005, 105, '2026-03-12', 15000, 'Pending');

SELECT * From Payments;

-- JOINT ANAYSIS

-- Q1 Which customers have pending premium payment?

SELECT 
		c.CustomerName,
        p.PolicyID,
        p.PolicyType,
        pay.PaymentAmount,
        pay.PaymentStatus
FROM Customers c
INNER JOIN  Policies p
	ON c.CustomerID = p.CustomerID
INNER JOIN Payments pay
	ON p.PolicyID = pay.PolicyID
WHERE pay.PaymentStatus ='Pending';

-- Q2 Customers whose payment status is paid.
SELECT
	c.CustomerName,
    p.PolicyID,
    p.PolicyType,
    pay.PaymentAmount,
    pay.PaymentStatus
FROM Customers c
INNER JOIN Policies p
	On c.CustomerID = p.CustomerID
INNER JOIN Payments pay
	ON p.PolicyID = pay.PolicyID
WHERE pay.PaymentStatus = 'Paid';

-- Q3 Total premium payment amount collected for each policy type

SELECT Sum(pay.PaymentAmount) as "Total Payment Amount", p.PolicyType, pay.PaymentStatus
FROM Policies p INNER JOIN Payments pay on p.PolicyID = pay.PolicyID WHERE PaymentStatus = "Paid" Group by p.PolicyType;

-- Q4 Classify policies into two categories high premium and low premium where premium amount is less than or equal to 20000

SELECT c.CustomerName,
		p.PolicyType,
        p.PremiumAmount,
		CASE 
			WHEN p.PremiumAmount > 20000 THEN "High Premium"
			ELSE "Low Premium"
		END AS PremiumCategory
FROM Policies p 
INNER JOIN Customers c
ON p.CustomerId  = c.CustomerID;

-- Q5 How many policies fall into each premium category
SELECT COUNT(*) AS TotalPolicy,
			CASE
				WHEN PremiumAmount > 20000 THEN "High Premium"
				WHEN PremiumAmount >= 15000 AND PremiumAmount <=20000 THEN "Medium Premium"
				ELSE "Low Premium"
		END AS PremiumCategory
FROM Policies GROUP BY PremiumCategory;

-- Q6 premium categories that have more than two policies.
SELECT COUNT(*) AS TotalPolicy,
			CASE
				WHEN PremiumAmount > 20000 THEN "High Premium"
				WHEN PremiumAmount >= 15000 AND PremiumAmount <=20000 THEN "Medium Premium"
				ELSE "Low Premium"
		END AS PremiumCategory
FROM Policies GROUP BY PremiumCategory HAVING COUNT(*) > 2;

-- Q7 Find all the policies where premium amount is greater than the average premium amount of all policies

SELECT PolicyID, PremiumAmount FROM Policies WHERE PremiumAmount >= (Select AVG(PremiumAmount) AS AveragePremium FROM Policies);

-- Q8 Find the Customer names and policy details of customers whose premium is greater than the average premium
SELECT * FROM Policies;
SELECT c.CustomerName,
	   p. CustomerID,
       p.PolicyType,
       p.PremiumAmount,
       p.PolicyStatus
FROM Customers c INNER JOIN Policies p 
ON c.CustomerID = p.CustomerID
WHERE p.PremiumAmount>= (SELECT AVG(PremiumAmount) FROM Policies);

-- Q9 Identify customers who have not purchased any policy.
SELECT c.CustomerName, c.CustomerID, c.City FROM Customers c LEFT JOIN Policies p 
ON p.CustomerID = c.CustomerID WHERE PolicyID IS NULL;

-- Q10 list of customers whose policy payments are still pending.
SELECT
	c.CustomerName,
    p.PolicyID,
    p.PolicyType,
    pay.PaymentAmount,
    pay.PaymentStatus
FROM Customers c 
LEFT JOIN Policies p 
	ON c.CustomerID = p.CustomerID
LEFT JOIN Payments pay 
	ON p.PolicyID = pay.PolicyID
WHERE pay.PaymentStatus = "Pending";


-- Q11 how much money has been collected from each customer.

SELECT c.CustomerName, Sum(pay.PaymentAmount) AS TotalPaymentCollected
FROM Customers c 
INNER JOIN Policies p 
	ON c.CustomerID = p.CustomerID
INNER JOIN Payments pay
	ON p.PolicyID = pay.PolicyID 
WHERE PaymentStatus = "Paid"
    GROUP BY c.CustomerName ORDER BY TotalPaymentCollected DESC;
    
    -- Q12 Identify payments made during February 2026.
    SELECT PaymentID, PolicyID, PaymentDate, PaymentAmount 
    FROM Payments 
    WHERE PaymentStatus ="Paid"
    AND PaymentDate BETWEEN "2026-02-01" AND "2026-02-28"; 	 	
    
-- Q13 Total payment amount collected in each month.

	SELECT
    MONTH(PaymentDate) AS Month,
    SUM(PaymentAmount) AS TotalCollectedAmount
FROM Payments
WHERE PaymentStatus = 'Paid'
GROUP BY MONTH(PaymentDate)
ORDER BY Month;

-- Q14 How many policies cutomers from each city have purchased?

SELECT c.City , Count(p.CustomerID) AS TotalPolicyPurchased
FROM Customers c INNER JOIN Policies p 
ON c.CustomerID = p.CustomerID GROUP BY c.City;

-- Q15 How many policies are Active and how many are Lapsed.
SELECT PolicyStatus, Count(PolicyStatus) AS TotalPolicies  FROM Policies GROUP BY PolicyStatus;


-- Q16 customers who have paid more than ₹20,000 in total.

SELECT c.CustomerName, SUM(pay.PaymentAmount) AS TotalPaymentCollected 
FROM Customers c INNER JOIN Policies p 
ON c.CustomerID = p.CustomerID 
INNER JOIN Payments pay
ON p.PolicyID = pay.PolicyID 
WHERE pay.PaymentStatus ="Paid" 
GROUP BY c.CustomerID, c.CustomerName HAVING SUM(pay.PaymentAmount) > 20000
ORDER BY TotalPaymentCollected DESC;

-- Q17	Find the total premium amount and number of policies for each policy type, considering only Active policies.
Select * FROM Policies;
SELECT PolicyType, SUM(PremiumAmount) AS TotalPremiumAmount, Count(PolicyID) AS NoOfPolicies FROM Policies 
WHERE PolicyStatus = "Active" GROUP BY PolicyType;

-- Q18 Find the customers who have more than one policy.

SELECT c.CustomerName, Count(p.CustomerID) As NoOfPolicy
FROM Customers c INNER JOIN Policies p 
ON c.CustomerID = p.CustomerID
GROUP BY c.CustomerID, c.CustomerName HAVING Count(p.CustomerID)> 1;

-- Q19 Find the total premium amount collected for each city considering only payments with status Paid

SELECT c.City, SUM(p.PremiumAmount) AS TotalPremiumAmount
FROM Customers c INNER JOIN Policies p 
ON c.CustomerID = p.CustomerID INNER JOIN Payments pay
ON p.PolicyID = pay.PolicyID WHERE pay.PaymentStatus = "Paid" 
GROUP BY c.City;

-- Q20 Find policies that have no payment records.

SELECT p.PolicyID, p.PolicyType, c.CustomerName FROM Policies p LEFT JOIN 
Payments pay ON p.PolicyID = pay.PolicyID
LEFT JOIN Customers c ON
p.CustomerID = c.CustomerID WHERE pay.PaymentDate IS NULL;

-- Q21 Customers whose total paid amount is less than their policy premium.

SELECT c.CustomerName, SUM(pay.PaymentAmount) AS TotalPaidAmount, p.PremiumAmount
FROM Policies p INNER JOIN Customers c 
ON p.CustomerID = c.CustomerID 
INNER JOIN Payments pay 
ON p.PolicyID = pay.PolicyID
WHERE pay.PaymentStatus = "Paid" 
GROUP BY c.CustomerName, c.CustomerId, p.PolicyID, p.PremiumAmount
HAVING SUM(pay.PaymentAmount) < p.PremiumAmount;

-- Q22Find the policy with the highest premium amount.
SELECT
    p.PolicyID,
    c.CustomerName,
    p.PremiumAmount
FROM Policies p
INNER JOIN Customers c
    ON p.CustomerID = c.CustomerID
ORDER BY p.PremiumAmount DESC
LIMIT 1;

-- Q23 Find the top 3 customers with the highest policy premium.

SELECT c.CustomerName,
		p.PolicyType,
        p.PremiumAmount
FROM Customers c INNER JOIN Policies p 
ON p.CustomerID = c.CustomerID
ORDER BY p.PremiumAmount DESC LIMIT 3;

-- Q24 Find the number of payments under each payment status.
Select * from Payments;
SELECT PaymentStatus, COUNT(PaymentID) AS TotalPayment, SUM(PaymentAmount) AS TotalPaymentAmount
FROM Payments GROUP BY PaymentStatus;

-- Q25 City-wise number of active policies and their total premium amount.

SELECT c.City, Count(p.PolicyStatus) AS ActivePolicies, SUM(p.PremiumAmount) AS TotalPremiumAmount
FROM Customers c INNER JOIN Policies p ON
c.CustomerID = p.CustomerID 
WHERE p.PolicyStatus = "Active"
GROUP BY c.City



 



























							
 





