--ANALYSIS OF BANK CUSTOMER CHURN DATA
-- Performed an in-depth analysis of bank customer churn using SQL, 
-- ensured that was clean and ready for  exploratory data analysis, and used aggregations and joins to uncover churn patterns. 
-- Identified key churn drivers and provided SQL-based insights to support customer retention strategies.

--PART 1(Data Preparation)
-- 1. Import Bank_churn.csv into SSMS
SELECT * from Bank_Churn

-- 2. Count of rows in the data
select count(*) from Bank_Churn;
-- 10,000 rows present in the data

-- 3. Inspecting the data for nulls
select * from Bank_Churn
where CustomerId is null or Surname is null;
-- No null or missing IDs or Surnames

-- 4. Check for Duplicate rows
select CustomerId, Surname, count(*) countt
from Bank_Churn
group by CustomerId, Surname
having count(*) > 1;
-- No Duplicate rows in the data

-- 5. check for inconsistent data(Gender)
select distinct gender 
from Bank_Churn;

select * from Bank_Churn


--PART 2: EXPLORATORY DATA ANALYSIS

-- 1. how many people have churned out of the overall customers
select (Churned * 100 / Total_Customers) as churned_percentage
from  (select count(*) as Total_Customers,
		sum(case when Exited = 1 then 1 else 0 END) as Churned,
		sum(case when Exited = 0 then 1 else 0 END) as Not_churned
	   from Bank_Churn) abc
-- Out of 10,000 Customers, 2037(20%) have churned from the bank.


-- 2. What is the relationship between active_member and whether customers churn or not.
select IsActiveMember,
		sum(case when Exited = 1 then 1 else 0 END) as Churned,
		sum(case when Exited = 0 then 1 else 0 END) as Not_churned
from Bank_Churn
group by IsActiveMember;
/* Of non_active members of the bank's services, 26% of them eventually churn while for active members, 17% of them churn.
this means that there's higher chances of churn among non-active members compared to those who are still active. 
Note, This doesn't imply that active members do not churn. 
More churned customers were inactive before finally putting a stop to use of the bank's services.*/


-- 3. Compare Churn rate among the Countries
select Geography, 
		sum(case when Exited = 1 then 1 else 0 END) as Churned,
		sum(case when Exited = 0 then 1 else 0 END) as Not_churned,
		(sum(case when Exited = 1 then 1 else 0 END) + sum(case when Exited = 0 then 1 else 0 END)) as Total, 
		sum(case when Exited = 1 then 1 else 0 END) * 100 / (sum(case when Exited = 1 then 1 else 0 END) + sum(case when Exited = 0 then 1 else 0 END)) churn_percentage
from Bank_Churn
group by Geography;
/* Customers from Germany have the highest churn rate compared to France and Spain
there is something germany isnt doing right and needs investigation. */


-- 4. Compare Churn Rate among genders
select Geography, Gender,
		sum(case when Exited = 1 then 1 else 0 END) as Churned,
		sum(case when Exited = 0 then 1 else 0 END) as Not_churned
		from Bank_Churn
		group by Geography,Gender;
/* female  customers across all the 3 countries churn more than male. there could be reason for this occurrence.*/


-- 5. Number of Products used by customers( Churned vs. Not Churned )
select NumOfProducts,
sum(case when Exited = 1 then 1 else 0 END) as Churned_customers,
sum(case when Exited = 0 then 1 else 0 END) as Not_churned_customers,
count(case when  NumOfProducts = 1 then 1 else 0 end) as Total_customers
from Bank_Churn
group by NumOfProducts
order by 1;
-- steady decline in number of users in rerspect to number of products, need for marketing their other products more.


-- 6. What is the average age of churned customers by geography and gender
select geography, gender, avg(age) as avg_churn_customer_age
  from Bank_Churn
  where Exited = 1
  group by Geography, Gender;


--7.  what does churn look like in different age brackets??
select 
case when Age <= 30 then '18-30'
	 when Age <= 40 then '31-40'
	 when Age <= 50 then '41-50'
	 when Age <= 60 then '51-60'
	 when Age <= 70 then '61-70'
	 else '71 and above'
	 end as Age_brackets,
sum(case when Exited = 1 then 1 else 0 END) as Churned_customers,
sum(case when Exited = 0 then 1 else 0 END) as Not_churned_customers,
count(*) as total_customers
from Bank_Churn
group by case when Age <= 30 then '18-30'
	 when Age <= 40 then '31-40'
	 when Age <= 50 then '41-50'
	 when Age <= 60 then '51-60'
	 when Age <= 70 then '61-70'
	 else '71 and above'
	 end
order by 1;
-- age group 41-50 had most churned_customers


-- 8. Credit Score Analysis
select 
case when CreditScore <=579 then 'Poor'
	 when CreditScore <=669 then 'Fair'
	 when CreditScore <=739 then 'Good'
	 when CreditScore <=799 then 'Very Good'
	 else 'Excellent'
	 end as Credit_score, 
sum(case when Exited = 1 then 1 else 0 END) as Churned_customers,
sum(case when Exited = 0 then 1 else 0 END) as Not_churned_customers,
count(*) as total_customers
from Bank_Churn
group by case when CreditScore <=579 then 'Poor'
	 when CreditScore <=669 then 'Fair'
	 when CreditScore <=739 then 'Good'
	 when CreditScore <=799 then 'Very Good'
	 else 'Excellent'
	 end
order by Churned_customers desc;


-- 9. Credit Card Analysis
select 
hascrcard,
sum(case when Exited = 1 then 1 else 0 END) as Churned_customers,
sum(case when Exited = 0 then 1 else 0 END) as Not_churned_customers
from Bank_Churn
group by hascrcard;


-- 10. customers' number of years spent with the bank (churn vs not_churned)
select 
case when Tenure <=2 then '0-2 years'
	 when Tenure <=5 then '3-5 years'
	 when Tenure <=8 then '6-8 years'
     else '8+ years'
end  years_with_bank,
sum(case when Exited = 1 then 1 else 0 END) as Churned_customers,
sum(case when Exited = 0 then 1 else 0 END) as Not_churned_customers,
(sum(case when Exited = 1 then 1 else 0 END) + sum(case when Exited = 0 then 1 else 0 END)) as total,
sum(case when Exited = 1 then 1 else 0 END) * 100 / (sum(case when Exited = 1 then 1 else 0 END) + sum(case when Exited = 0 then 1 else 0 END)) as churn_percentage
from Bank_Churn
group by case when Tenure <=2 then '0-2 years'
	 when Tenure <=5 then '3-5 years'
	 when Tenure <=8 then '6-8 years'
     else '8+ years' end
order by 1;