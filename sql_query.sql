use bank_data;
select * from bank_churn;



-- 1.	What is the distribution of account balances across different regions?

SELECT 
    GeographyID,
    AVG(Balance) AS Average_Balance,
    MIN(Balance) AS Minimum_Balance,
    MAX(Balance) AS Maximum_Balance
FROM 
    customerinfo ci
    join
    bank_churn bc on ci.CustomerID=bc.CustomerID 
GROUP BY GeographyID;





-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT CustomerID, EstimatedSalary FROM  customerinfo
WHERE YEAR(BankDOJ) = (SELECT MAX(YEAR(BankDOJ)) FROM customerinfo) 
AND  MONTH(BankDOJ) >= 10 AND MONTH(BankDOJ) <= 12
ORDER BY  EstimatedSalary DESC limit 5;


-- select YEAR(BankDOJ) from customerinfo where YEAR(BankDOJ)=year(CURRENT_TIMESTAMP) ;
-- SELECT year(CURRENT_TIMESTAMP)




-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)

select round(avg(NumOfProducts),2) as Avg_n_of_product from bank_churn where HasCrCard=1;





-- 4.	Determine the churn rate by gender for the most recent year in the dataset.

SELECT c.GenderID,
    -- COUNT(CASE WHEN b.Exited = 1 THEN 1 END) AS CountOfChurnedCustomers,
    -- COUNT(b.CustomerID) AS TotalCustomers,
    Round(CAST(COUNT(CASE WHEN b.Exited=1 THEN 1 END) AS FLOAT)/COUNT(b.CustomerID) ,2) AS ChurnRate
FROM bank_churn b
join 
customerinfo c on c.customerID=b.customerID 
where YEAR(BankDOJ) = (SELECT MAX(YEAR(BankDOJ)) FROM customerinfo)
group by c.GenderID;







-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT Exited, AVG(CreditScore) AS Avg_Credit_score FROM bank_churn GROUP BY Exited ;






-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number
--      of active accounts? (SQL)

-- Gender Wise average estimated salary
SELECT c.GenderID, ROUND(AVG(c.EstimatedSalary) ,2) AS Avg_EstimatedSalary,
SUM(CASE WHEN b.IsActiveMember = 1 THEN 1 ELSE 0 END) AS ActiveAccounts
from customerinfo c
join bank_churn b on c.customerID=b.customerID GROUP BY GenderID;


-- Highest average estimated salary Gender Wise
SELECT c.GenderID, ROUND(AVG(c.EstimatedSalary) ,2) AS Avg_EstimatedSalary,
SUM(CASE WHEN b.IsActiveMember = 1 THEN 1 ELSE 0 END) AS ActiveAccounts
from customerinfo c
join bank_churn b on c.customerID=b.customerID GROUP BY GenderID order by Avg_EstimatedSalary desc limit 1;







-- 7. Segment the customers based on their credit score and identify the segment with the 
-- highest exit rate. (SQL)


select customerSegment, avg(Exited) as ExitedRate from (Select CreditScore, Exited, 
    case 
		when CreditScore>=800 and CreditScore<=850 then 'Excellent'
		when CreditScore>=740 and CreditScore<=799 then 'Very_Good'
		when CreditScore>=670 and CreditScore<=739 then 'Good'
		when CreditScore>=580 and CreditScore<=669 then 'Fair'
		else 'Poor'
	end as customerSegment from bank_churn) as c_segment  group by customerSegment 
ORDER BY ExitedRate DESC LIMIT 1 ;




    
-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater 
-- than 5 years. (SQL)
    
select GeographyID, count(CustomerId) as Active_Customer_Count from customerinfo 
where CustomerID in (
	select customerID from bank_churn where IsActiveMember=1 and Tenure>5
	) group by GeographyID 
order by Active_Customer_Count desc limit 1;




-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

select HasCrCard, avg(Exited) as churnRate from bank_churn group by HasCrCard;



-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
-- Prepare the data through SQL and then visualize it.

select Month(BankDOJ) as joinMonth, count(*) as CustomerCount 
from customerinfo group by Month(BankDOJ)  order by JoinMonth;




-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females 
-- in each geography id. Also, rank the gender according to the average value. (SQL)

SELECT GeographyID, GenderID, AVG(EstimatedSalary) AS AverageIncome,
    RANK() OVER (PARTITION BY GeographyID ORDER BY AVG(EstimatedSalary) DESC) AS GenderRank
FROM customerinfo GROUP BY GeographyID, GenderID;



-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in 
-- each age bracket (18-30, 30-50, 50+).

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+' END AS AgeBracket, 
(select AVG(Tenure) from bank_churn)AS AverageTenure
FROM customerinfo 
WHERE customerID in (select customerID from bank_churn where exited=1 ) 
GROUP BY 
  CASE
	  WHEN Age BETWEEN 18 AND 30 THEN '18-30'
	  WHEN Age BETWEEN 31 AND 50 THEN '31-50'
     ELSE '50+'
   END;
 
    


-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table?
--  If yes do this using SQL.

SELECT 
    BC.*, (SELECT ExitCategory FROM ExitCustomer EC where BC.exited=EC.exitID) AS ExitCategory
FROM Bank_Churn BC;




-- 25.	Write the query to get the customer IDs, their last name, and whether they are 
-- active or not for the customers whose surname ends with “on”.

SELECT b.CustomerID, c.surname as LastName, b.IsActiveMember FROM Bank_Churn b
left join customerinfo c on b.customerID=c.customerID WHERE surname LIKE '%on';








-- SUBJECTIVE QUESTIONS 




-- 9.	Utilize SQL queries to segment customers based on demographics and account details

-- Segment Customer by age buckets 

SELECT
    CASE
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
	END AS AgeBracket, count(*) as Customer_count
FROM customerinfo GROUP BY AgeBracket;


-- Segment Customer by credit score 

Select 
    case 
		when CreditScore>=800 and CreditScore<=850 then 'Excellent'
		when CreditScore>=740 and CreditScore<=799 then 'Very_Good'
		when CreditScore>=670 and CreditScore<=739 then 'Good'
		when CreditScore>=580 and CreditScore<=669 then 'Fair'
		else 'Poor'
	end as customerSegment, count(*) as Customer_count
from bank_churn group by customerSegment;
    
    
-- Segment Customers by Geography:

select GeographyID, count(*) as Customer_count from customerinfo group by GeographyID;


-- Segment Customers by Gender:

select GenderID, count(*) as Customer_count from customerinfo group by GenderID;


-- Segment Customers by Number of product:

select numOfProducts, count(*) as Customer_count from bank_churn group by numOfProducts;


-- Segment Customers by Account Activity:

select IsActiveMember, count(*) as Customer_count from bank_churn group by IsActiveMember;





-- 14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

alter table bank_churn rename column HasCrCard to Has_creditcard;
alter table bank_churn rename column Has_creditcard to HasCrCard;
select * from bank_churn






