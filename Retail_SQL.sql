
-- DATABASE CREATION
CREATE DATABASE retail;

USE retail;

-- TABLE CREATION
CREATE TABLE retail_data 
(InvoiceNo VARCHAR(20),	
StockCode VARCHAR(20),
`Description` TEXT,
Quantity INT,
InvoiceDate VARCHAR(20),
UnitPrice DECIMAL(10,3),
CustomerID VARCHAR(20),
Country VARCHAR(50));

DESCRIBE retail_data;

-- DATASET LOADING
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OnlineRetail.csv'
INTO TABLE retail_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--
SELECT COUNT(*) FROM retail_data;

SELECT * FROM retail_data;

SELECT COUNT(DISTINCT CustomerID) FROM retail_data;

SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM retail_data;


                                  -- DATA CLEANING & PREPROCESSING

-- 1. CHECKING NULL/BLANK CELLS

SELECT * FROM retail_data WHERE InvoiceNo IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceNo) = '';

SELECT * FROM retail_data WHERE StockCode IS NULL ;
SELECT * FROM retail_data WHERE TRIM(StockCode) = '' ;

SELECT * FROM retail_data WHERE `Description` IS NULL;
SELECT * FROM retail_data WHERE TRIM(`Description`) = '';

SELECT * FROM retail_data WHERE Quantity IS NULL;
SELECT * FROM retail_data WHERE Quantity = '';

SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceDate) = '';

SELECT * FROM retail_data WHERE UnitPrice IS NULL;
SELECT * FROM retail_data WHERE UnitPrice = '';

SELECT * FROM retail_data WHERE CustomerID IS NULL;
SELECT * FROM retail_data WHERE TRIM(CustomerID) = '' ;

SELECT * FROM retail_data WHERE Country IS NULL;
SELECT * FROM retail_data WHERE TRIM(Country) = '';

-- HANDLING NULL VALUES

DELETE FROM retail_data 
WHERE TRIM(CustomerID) = '';

UPDATE retail_data 
SET `Description` = "Unknown"
WHERE TRIM(`Description`) = '';

select * FROM retail_data 
WHERE `Description` = "Unknown";

-- 2. DUPLICATION CHECK

SELECT *
FROM retail_data 
WHERE (InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID) 
IN 
(SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1) 
ORDER BY InvoiceNo ASC;

SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1; 


-- HANDLING DUPLICATES

CREATE TABLE retail_data_clean AS
SELECT DISTINCT *
FROM retail_data;

DROP TABLE retail_data;

ALTER TABLE retail_data_clean RENAME TO retail_data;

select count(*) from retail_data;


-- 3. INCONSISTENCY CHECK

SELECT DISTINCT InvoiceNo FROM retail_data ORDER BY InvoiceNo ASC;

SELECT DISTINCT StockCode FROM retail_data ORDER BY StockCode ASC;

SELECT DISTINCT `Description` FROM retail_data ORDER BY `Description` ASC;
SELECT `Description` FROM retail_data WHERE `Description` REGEXP '[^a-zA-Z0-9 ,.-]';

SELECT Quantity FROM retail_data WHERE Quantity <= 0;
SELECT COUNT(Quantity) FROM retail_data WHERE Quantity <= 0;

SELECT UnitPrice FROM retail_data WHERE UnitPrice <= 0;

SELECT DISTINCT CustomerID FROM retail_data ORDER BY CustomerID ASC;

SELECT DISTINCT Country FROM retail_data ORDER BY Country ASC;
SELECT DISTINCT Country FROM retail_data WHERE Country REGEXP '[^a-zA-Z0-9 ,.-]';

-- HANDLING INCONSISTENT VALUES

DELETE FROM retail_data WHERE Quantity <= 0;

DELETE FROM retail_data WHERE UnitPrice <= 0;

UPDATE retail_data 
SET Country = "Ireland"
WHERE Country = "EIRE";

-- 4. DATAYPE CONVERSION 

ALTER TABLE retail_data
MODIFY COLUMN InvoiceDate DATETIME;

ALTER TABLE retail_data
MODIFY COLUMN CustomerID INT;

-- Verified failed datatype conversion
SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE CustomerID IS NULL;

                                     
                                     -- FEATURE ENGINEERING
                                     
-- 1. ADDED A NEW COLUMN FOT TOTAL PRICE
ALTER TABLE retail_data
ADD COLUMN Total_Price DECIMAL (10,3);
                                     
UPDATE retail_data
SET Total_Price = Quantity * UnitPrice;	

SELECT * FROM retail_data;

				
									  -- RFM ANALYSIS
								
SELECT  MAX(InvoiceDate) FROM retail_data; 

-- Building Customer-Level Data 
CREATE TABLE rfm_data AS
SELECT CustomerID, 
MAX(InvoiceDate) AS Last_Purchase_Date,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary
FROM retail_data
GROUP BY CustomerID;

-- Recency Calculation
SELECT *,
DATEDIFF(
    (SELECT MAX(InvoiceDate) FROM retail_data),
    Last_Purchase_Date
) AS Recency
FROM rfm_data;

-- Final RFM data table
CREATE TABLE rfm_data_final AS
SELECT CustomerID,
DATEDIFF((SELECT MAX(InvoiceDate) FROM retail_data), MAX(InvoiceDate)) AS Recency,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary 
From retail_data
GROUP BY CustomerID;

-- Apply Scoring 
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final;

-- Creating RFM Score Table using CTE
CREATE TABLE rfm_scores AS
WITH rfm_cte AS (
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final
)
SELECT *, 
CONCAT(R_Score, F_Score, M_Score) AS RFM_Score -- combined scores
FROM rfm_cte;

-- Customer Segmentation
SELECT *,
CASE 
 WHEN R_score = 5 AND F_score = 5 AND M_score = 5 THEN 'Champions'
 WHEN R_score >=4 AND F_score >=4 THEN 'Loyal'
 WHEN R_score <=2 THEN 'At Risk'
 ELSE 'Others'
END AS Segment
FROM rfm_scores;

-- Adding Segment Column to rfm_scores Table
-- DATABASE CREATION
CREATE DATABASE retail;

USE retail;

-- TABLE CREATION
CREATE TABLE retail_data 
(InvoiceNo VARCHAR(20),	
StockCode VARCHAR(20),
`Description` TEXT,
Quantity INT,
InvoiceDate VARCHAR(20),
UnitPrice DECIMAL(10,3),
CustomerID VARCHAR(20),
Country VARCHAR(50));

DESCRIBE retail_data;

-- DATASET LOADING
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OnlineRetail.csv'
INTO TABLE retail_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--
SELECT COUNT(*) FROM retail_data;

SELECT * FROM retail_data;

SELECT COUNT(DISTINCT CustomerID) FROM retail_data;

SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM retail_data;


                                  -- DATA CLEANING & PREPROCESSING

-- 1. CHECKING NULL/BLANK CELLS

SELECT * FROM retail_data WHERE InvoiceNo IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceNo) = '';

SELECT * FROM retail_data WHERE StockCode IS NULL ;
SELECT * FROM retail_data WHERE TRIM(StockCode) = '' ;

SELECT * FROM retail_data WHERE `Description` IS NULL;
SELECT * FROM retail_data WHERE TRIM(`Description`) = '';

SELECT * FROM retail_data WHERE Quantity IS NULL;
SELECT * FROM retail_data WHERE Quantity = '';

SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceDate) = '';

SELECT * FROM retail_data WHERE UnitPrice IS NULL;
SELECT * FROM retail_data WHERE UnitPrice = '';

SELECT * FROM retail_data WHERE CustomerID IS NULL;
SELECT * FROM retail_data WHERE TRIM(CustomerID) = '' ;

SELECT * FROM retail_data WHERE Country IS NULL;
SELECT * FROM retail_data WHERE TRIM(Country) = '';

-- HANDLING NULL VALUES

DELETE FROM retail_data 
WHERE TRIM(CustomerID) = '';

UPDATE retail_data 
SET `Description` = "Unknown"
WHERE TRIM(`Description`) = '';

select * FROM retail_data 
WHERE `Description` = "Unknown";

-- 2. DUPLICATION CHECK

SELECT *
FROM retail_data 
WHERE (InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID) 
IN 
(SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1) 
ORDER BY InvoiceNo ASC;

SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1; 


-- HANDLING DUPLICATES

CREATE TABLE retail_data_clean AS
SELECT DISTINCT *
FROM retail_data;

DROP TABLE retail_data;

ALTER TABLE retail_data_clean RENAME TO retail_data;

select count(*) from retail_data;


-- 3. INCONSISTENCY CHECK

SELECT DISTINCT InvoiceNo FROM retail_data ORDER BY InvoiceNo ASC;

SELECT DISTINCT StockCode FROM retail_data ORDER BY StockCode ASC;

SELECT DISTINCT `Description` FROM retail_data ORDER BY `Description` ASC;
SELECT `Description` FROM retail_data WHERE `Description` REGEXP '[^a-zA-Z0-9 ,.-]';

SELECT Quantity FROM retail_data WHERE Quantity <= 0;
SELECT COUNT(Quantity) FROM retail_data WHERE Quantity <= 0;

SELECT UnitPrice FROM retail_data WHERE UnitPrice <= 0;

SELECT DISTINCT CustomerID FROM retail_data ORDER BY CustomerID ASC;

SELECT DISTINCT Country FROM retail_data ORDER BY Country ASC;
SELECT DISTINCT Country FROM retail_data WHERE Country REGEXP '[^a-zA-Z0-9 ,.-]';

-- HANDLING INCONSISTENT VALUES

DELETE FROM retail_data WHERE Quantity <= 0;

DELETE FROM retail_data WHERE UnitPrice <= 0;

UPDATE retail_data 
SET Country = "Ireland"
WHERE Country = "EIRE";

-- 4. DATAYPE CONVERSION 

ALTER TABLE retail_data
MODIFY COLUMN InvoiceDate DATETIME;

ALTER TABLE retail_data
MODIFY COLUMN CustomerID INT;

-- Verified failed datatype conversion
SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE CustomerID IS NULL;

                                     
                                     -- FEATURE ENGINEERING
                                     
-- 1. ADDED A NEW COLUMN FOT TOTAL PRICE
ALTER TABLE retail_data
ADD COLUMN Total_Price DECIMAL (10,3);
                                     
UPDATE retail_data
SET Total_Price = Quantity * UnitPrice;	

SELECT * FROM retail_data;

				
									  -- RFM ANALYSIS
								
SELECT  MAX(InvoiceDate) FROM retail_data; 

-- Building Customer-Level Data 
CREATE TABLE rfm_data AS
SELECT CustomerID, 
MAX(InvoiceDate) AS Last_Purchase_Date,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary
FROM retail_data
GROUP BY CustomerID;

-- Recency Calculation
SELECT *,
DATEDIFF(
    (SELECT MAX(InvoiceDate) FROM retail_data),
    Last_Purchase_Date
) AS Recency
FROM rfm_data;

-- Final RFM data table
CREATE TABLE rfm_data_final AS
SELECT CustomerID,
DATEDIFF((SELECT MAX(InvoiceDate) FROM retail_data), MAX(InvoiceDate)) AS Recency,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary 
From retail_data
GROUP BY CustomerID;

-- Apply Scoring 
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final;

-- Creating RFM Score Table using CTE
CREATE TABLE rfm_scores AS
WITH rfm_cte AS (
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final
)
SELECT *, 
CONCAT(R_Score, F_Score, M_Score) AS RFM_Score -- combined scores
FROM rfm_cte;

-- Customer Segmentation
SELECT *,
CASE 
 WHEN R_score = 5 AND F_score = 5 AND M_score = 5 THEN 'Champions'
 WHEN R_score >=4 AND F_score >=4 THEN 'Loyal'
 WHEN R_score <=2 THEN 'At Risk'
 ELSE 'Others'
END AS Segment
FROM rfm_scores;

-- Adding Segment Column to rfm_scores Table
-- DATABASE CREATION
CREATE DATABASE retail;

USE retail;

-- TABLE CREATION
CREATE TABLE retail_data 
(InvoiceNo VARCHAR(20),	
StockCode VARCHAR(20),
`Description` TEXT,
Quantity INT,
InvoiceDate VARCHAR(20),
UnitPrice DECIMAL(10,3),
CustomerID VARCHAR(20),
Country VARCHAR(50));

DESCRIBE retail_data;

-- DATASET LOADING
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OnlineRetail.csv'
INTO TABLE retail_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--
SELECT COUNT(*) FROM retail_data;

SELECT * FROM retail_data;

SELECT COUNT(DISTINCT CustomerID) FROM retail_data;

SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM retail_data;


                                  -- DATA CLEANING & PREPROCESSING

-- 1. CHECKING NULL/BLANK CELLS

SELECT * FROM retail_data WHERE InvoiceNo IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceNo) = '';

SELECT * FROM retail_data WHERE StockCode IS NULL ;
SELECT * FROM retail_data WHERE TRIM(StockCode) = '' ;

SELECT * FROM retail_data WHERE `Description` IS NULL;
SELECT * FROM retail_data WHERE TRIM(`Description`) = '';

SELECT * FROM retail_data WHERE Quantity IS NULL;
SELECT * FROM retail_data WHERE Quantity = '';

SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE TRIM(InvoiceDate) = '';

SELECT * FROM retail_data WHERE UnitPrice IS NULL;
SELECT * FROM retail_data WHERE UnitPrice = '';

SELECT * FROM retail_data WHERE CustomerID IS NULL;
SELECT * FROM retail_data WHERE TRIM(CustomerID) = '' ;

SELECT * FROM retail_data WHERE Country IS NULL;
SELECT * FROM retail_data WHERE TRIM(Country) = '';

-- HANDLING NULL VALUES

DELETE FROM retail_data 
WHERE TRIM(CustomerID) = '';

UPDATE retail_data 
SET `Description` = "Unknown"
WHERE TRIM(`Description`) = '';

select * FROM retail_data 
WHERE `Description` = "Unknown";

-- 2. DUPLICATION CHECK

SELECT *
FROM retail_data 
WHERE (InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID) 
IN 
(SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1) 
ORDER BY InvoiceNo ASC;

SELECT InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
FROM retail_data
GROUP BY InvoiceNo, StockCode, Quantity,  InvoiceDate, UnitPrice, CustomerID
HAVING COUNT(*) > 1; 


-- HANDLING DUPLICATES

CREATE TABLE retail_data_clean AS
SELECT DISTINCT *
FROM retail_data;

DROP TABLE retail_data;

ALTER TABLE retail_data_clean RENAME TO retail_data;

select count(*) from retail_data;


-- 3. INCONSISTENCY CHECK

SELECT DISTINCT InvoiceNo FROM retail_data ORDER BY InvoiceNo ASC;

SELECT DISTINCT StockCode FROM retail_data ORDER BY StockCode ASC;

SELECT DISTINCT `Description` FROM retail_data ORDER BY `Description` ASC;
SELECT `Description` FROM retail_data WHERE `Description` REGEXP '[^a-zA-Z0-9 ,.-]';

SELECT Quantity FROM retail_data WHERE Quantity <= 0;
SELECT COUNT(Quantity) FROM retail_data WHERE Quantity <= 0;

SELECT UnitPrice FROM retail_data WHERE UnitPrice <= 0;

SELECT DISTINCT CustomerID FROM retail_data ORDER BY CustomerID ASC;

SELECT DISTINCT Country FROM retail_data ORDER BY Country ASC;
SELECT DISTINCT Country FROM retail_data WHERE Country REGEXP '[^a-zA-Z0-9 ,.-]';

-- HANDLING INCONSISTENT VALUES

DELETE FROM retail_data WHERE Quantity <= 0;

DELETE FROM retail_data WHERE UnitPrice <= 0;

UPDATE retail_data 
SET Country = "Ireland"
WHERE Country = "EIRE";

-- 4. DATAYPE CONVERSION 

ALTER TABLE retail_data
MODIFY COLUMN InvoiceDate DATETIME;

ALTER TABLE retail_data
MODIFY COLUMN CustomerID INT;

-- Verified failed datatype conversion
SELECT * FROM retail_data WHERE InvoiceDate IS NULL;
SELECT * FROM retail_data WHERE CustomerID IS NULL;

                                     
                                     -- FEATURE ENGINEERING
                                     
-- 1. ADDED A NEW COLUMN FOT TOTAL PRICE
ALTER TABLE retail_data
ADD COLUMN Total_Price DECIMAL (10,3);
                                     
UPDATE retail_data
SET Total_Price = Quantity * UnitPrice;	

SELECT * FROM retail_data;

				
									  -- RFM ANALYSIS
								
SELECT  MAX(InvoiceDate) FROM retail_data; 

-- Building Customer-Level Data 
CREATE TABLE rfm_data AS
SELECT CustomerID, 
MAX(InvoiceDate) AS Last_Purchase_Date,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary
FROM retail_data
GROUP BY CustomerID;

-- Recency Calculation
SELECT *,
DATEDIFF(
    (SELECT MAX(InvoiceDate) FROM retail_data),
    Last_Purchase_Date
) AS Recency
FROM rfm_data;

-- Final RFM data table
CREATE TABLE rfm_data_final AS
SELECT CustomerID,
DATEDIFF((SELECT MAX(InvoiceDate) FROM retail_data), MAX(InvoiceDate)) AS Recency,
COUNT(DISTINCT InvoiceNo) AS Frequency,
SUM(Total_Price) AS Monetary 
From retail_data
GROUP BY CustomerID;

-- Apply Scoring 
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final;

-- Creating RFM Score Table using CTE
CREATE TABLE rfm_scores AS
WITH rfm_cte AS (
SELECT *,
NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
FROM rfm_data_final
)
SELECT *, 
CONCAT(R_Score, F_Score, M_Score) AS RFM_Score -- combined scores
FROM rfm_cte;

-- Customer Segmentation

-- Adding Segment Column to rfm_scores Table
ALTER TABLE rfm_scores
ADD COLUMN Segment VARCHAR(20);

UPDATE rfm_scores
SET Segment = 
CASE 
 WHEN R_score = 5 AND F_score = 5 AND M_score = 5 THEN 'Champions'
 WHEN R_score >=4 AND F_score >=4 THEN 'Loyal'
 WHEN R_score <=2 THEN 'At Risk'
 ELSE 'Low Value' 
 END;

-- Final Validation 

SELECT Segment, COUNT(*) 
FROM rfm_scores 
GROUP BY Segment;

SELECT Segment, SUM(Monetary) 
FROM rfm_scores 
GROUP BY Segment;

 