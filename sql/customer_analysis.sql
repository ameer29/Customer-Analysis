-- I FIRST CREATED DATABASE 
CREATE DATABASE INT_CS
--THEN UPLOADED THE FILE 
SELECT * FROM DBO.TRANDATA;
SELECT * FROM DBO.CUSTDATA;

ALTER TABLE DBO.TRANDATA
DROP COLUMN COLUMN13;

-- DELETED THE MCN , STOREID AND CASHMEMO WHERE THE VALUES ARE NULL
DELETE FROM DBO.TRANDATA
WHERE MCN IS NULL OR STORE_ID IS NULL OR CASH_MEMO_NO IS NULL;

--JOINED BOTH THE TABLE - FINAL_DATA
SELECT * INTO FINAL_DATA FROM DBO.TRANDATA AS A
LEFT JOIN DBO.CUSTDATA AS B ON A.MCN = B.CUSTID 


--Q1. Count the number of observations having any of the variables is having null value/missing values?

SELECT 
COUNT (*) AS NULL_VALUE
FROM FINAL_DATA
WHERE ItemCount IS NULL OR TransactionDate IS NULL OR TotalAmount IS NULL OR SaleAmount IS NULL OR SalePercent IS NULL OR Cash_Memo_No IS NULL 
OR Dep1Amount IS NULL OR Dep2Amount IS NULL OR Dep3Amount IS NULL OR Dep4Amount IS NULL OR Store_ID IS NULL OR MCN IS NULL
OR CustID IS NULL OR Gender IS NULL OR [Location] IS NULL OR Age IS NULL OR Cust_seg IS NULL OR Sample_flag IS NULL 
;

--Q2. How many customers have shopped? (Hint: Distinct Customers)
--TO FIND COUNT
SELECT COUNT(DISTINCT MCN) AS TOTAL_CUSTOMER 
FROM FINAL_DATA

--TO DISPLAY THE CUSTOMER
SELECT DISTINCT MCN
FROM FINAL_DATA

--Q3.  How many shoppers (customers) visiting more than 1 store?

SELECT COUNT(*) AS TotalShoppers
FROM (
  SELECT CustID
  FROM FINAL_DATA
  GROUP BY CustID
  HAVING COUNT (DISTINCT STORE_ID) > 1
) AS Subquery;

/* Q4.   What is the distribution of shoppers by day of the week? How the customer shopping behavior
on each day of week? (Hint: You are required to calculate number of customers, number of transactions, 
total sale amount, total quantity etc.. by each week day)
*/

SELECT 
    DATEPART(WEEKDAY, TransactionDate) AS Weekday,
    COUNT(DISTINCT CustID) AS NumberOfCustomers,
    COUNT(TotalAmount) AS NumberOfTransactions,
    SUM(SaleAmount) AS TotalSaleAmount,
    SUM(ItemCount) AS TotalQuantity
FROM FINAL_DATA
GROUP BY DATEPART(WEEKDAY, TransactionDate)
ORDER BY Weekday;


--Q5.  What is the average revenue per customer/average revenue per customer by each location?

SELECT AVG (SaleAmount) AS AVG_REV_PER_CUST,
[Location]
FROM  FINAL_DATA
GROUP BY [Location]
;

--Q6.  Average revenue per customer by each store etc?
SELECT AVG (SaleAmount) AS AVG_REV_PER_CUST,
Store_ID
FROM  FINAL_DATA
GROUP BY Store_ID
;

--Q7. Find the department spend by store wise?

SELECT 
SUM (Dep1Amount) AS DEP1AMT,
SUM(Dep2Amount) AS DEP2AMT,
SUM(Dep3Amount)AS DEP3AMT,
SUM(Dep4Amount)AS DEP4AMT,
Store_ID
FROM FINAL_DATA
GROUP BY Store_ID
;

--Q8. What is the Latest transaction date and Oldest Transaction date? (Finding the minimum and maximum transaction dates)

SELECT 
MAX (TransactionDate) LATEST_TRANSACTION_DATE,
MIN (TRANSACTIONDATE) OLDEST_TRANSACTION_DATE
FROM FINAL_DATA
;

--Q9. How many months of data provided for the analysis?

SELECT DATEDIFF(MONTH, MIN(TransactionDate),
MAX(TransactionDate)) + 1 AS Number_Months 
FROM Final_Data
;


--Q10. Find the top 3 locations interms of spend and total contribution of sales out of total sales?

SELECT TOP 3 [LOCATION], 
SUM(SaleAmount)/ (SELECT SUM(SaleAmount) 
FROM Final_Data) AS Contribution
FROM Final_Data
GROUP BY [LOCATION], SaleAmount 
ORDER BY SaleAmount DESC
;


--Q11. Find the customer count and Total Sales by Gender?

SELECT 
GENDER,
COUNT (distinct CUSTID) AS CUST_COUNT,
SUM (SALEAMOUNT) AS TOTAL_SALES
FROM FINAL_DATA
GROUP BY Gender
;

--Q12. What is total  discount and percentage of discount given by each location?

SELECT [Location], SUM(TotalAmount) - SUM(SaleAmount) AS TOTAL_DISC,
(SUM(TotalAmount) - SUM(SaleAmount)) * 100/SUM(TotalAmount) as DISC_PERCENT
FROM Final_Data
GROUP BY [Location]
;

--Q13. Which segment of customers contributing maximum sales?

SELECT TOP 1 AgeGroup, SUM(SaleAmount) AS TotalSales
FROM
(
SELECT 
CASE
WHEN Age < 18 THEN 'Under 18'
WHEN Age >= 18 AND Age < 25 THEN '18-24'
WHEN Age >= 25 AND Age < 35 THEN '25-34'
WHEN Age >= 35 AND Age < 45 THEN '35-44'
WHEN Age >= 45 AND Age < 55 THEN '45-54'
ELSE '55 and above'
END AS AgeGroup, SaleAmount
FROM Final_Data
) AS AgeSales
GROUP BY AgeGroup
ORDER BY TotalSales DESC;

--Q14. What is the average transaction value by location, gender, segment?

SELECT 
GENDER , 
[LOCATION],
CUST_SEG ,
AVG (SaleAmount) AS AVG_TRANSACTION
FROM FINAL_DATA
GROUP BY Gender , [Location] , Cust_seg
ORDER BY AVG_TRANSACTION ASC
;

--Q15. Create Customer_360 Table with below columns.
/*
Customer_id,
Gender,
Location,
Age,
Cust_seg,
No_of_transactions,
No_of_items,
Total_sale_amount,
Average_transaction_value,
TotalSpend_Dep1,
TotalSpend_Dep2,
TotalSpend_Dep3,
TotalSpend_Dep4,
No_Transactions_Dep1,
No_Transactions_Dep2,
No_Transactions_Dep3,
No_Transactions_Dep4,
No_Transactions_Weekdays,
No_Transactions_Weekends,
Rank_based_on_Spend,
Decile
etc. */


CREATE TABLE Customer_360 (
  Customer_id INT,
  Gender VARCHAR(10),
  Location VARCHAR(50),
  Age INT,
  Cust_seg VARCHAR(50),
  No_of_transactions INT,
  No_of_items INT,
  Total_sale_amount DECIMAL(20, 2),
  Average_transaction_value DECIMAL(20, 2),
  TotalSpend_Dep1 DECIMAL(20, 2),
  TotalSpend_Dep2 DECIMAL(20, 2),
  TotalSpend_Dep3 DECIMAL(20, 2),
  TotalSpend_Dep4 DECIMAL(20, 2),
  No_Transactions_Dep1 INT,
  No_Transactions_Dep2 INT,
  No_Transactions_Dep3 INT,
  No_Transactions_Dep4 INT,
  No_Transactions_Weekdays INT,
  No_Transactions_Weekends INT,
  Rank_based_on_Spend INT,
  Decile INT
);
--CUSTOMER_360 TABLE
SELECT * FROM DBO.Customer_360;


--d. Filter the Final_Data using sample_flag=1and export this data into Excel File and call this table as sample_data

SELECT * INTO SAMPLE_DATA 
FROM FINAL_DATA
WHERE Sample_flag = 1
;

--the sample data to export to excel fro task 2
SELECT * FROM SAMPLE_DATA;




