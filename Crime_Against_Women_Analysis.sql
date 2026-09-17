-- Database Creation
CREATE DATABASE Crime_DB;
USE Crime_DB;

-- Table Creation
CREATE TABLE Crime_Data(
State_UT VARCHAR(50),
Crime_Head VARCHAR(150),
Crime_Category VARCHAR(100),
Cases INT
);

ALTER TABLE Crime_Data
ADD COLUMN Record_Level VARCHAR(20),
ADD COLUMN Analysis_Include VARCHAR(3);


-- Data Import
-- Data imported from Women_Crime_Data_2023.csv using MySQL Workbench Import Wizard


-- Data Preparation
-- Populate Record_Level
UPDATE Crime_Data
SET Record_Level = 
CASE WHEN Crime_Head IN (
'Kidnapping & Abduction (Total)',
'Rape (Total)',
'Attempt to Rape (Total)',
'Assault to Outrage Modesty (Total)',
'Insult to Modesty (Total)',
'Immoral Traffic (Prevention) Act (Total)',
'Women-Centric Cyber Crime (Total)',
'POCSO (Protection of Children from Sexual Offences Act) (Total)'
) THEN 'Total'
WHEN Crime_Head IN (
'Abetment to Suicide of Women',
'Acid Attack',
'Attempt to Acid Attack',
'Buying of Girls < 18',
'Cruelty by Husband/Relatives',
'Domestic Violence Act',
'Dowry Deaths',
'Dowry Prohibition Act',
'Human Trafficking',
'Indecent Representation of Women Act',
'Kidnapping for Importation - Girls < 18',
'Kidnapping for Procuration - Girls < 18',
'Miscarriage',
'Murder with Rape/Gang Rape',
'Other Kidnapping Cases',
'Selling of Girls < 18'
) THEN 'Standalone'
ELSE 'Detail'
END;

-- Populate Analysis_Include
UPDATE Crime_Data
SET Analysis_Include = 
CASE WHEN Record_Level IN ('Total', 'Standalone') THEN 'Yes'
ELSE 'No'
END;


-- Data Validation
-- Q1. How many records were successfully imported into the database?
SELECT COUNT(*) AS Total_Records FROM Crime_Data;

-- Q2. Are there any null or missing values in the dataset?
SELECT SUM(CASE WHEN State_UT IS NULL THEN 1 ELSE 0 END) AS Missing_State_UT,
       SUM(CASE WHEN Crime_Head IS NULL THEN 1 ELSE 0 END) AS Missing_Crime_Head,
       SUM(CASE WHEN Crime_Category IS NULL THEN 1 ELSE 0 END) AS Missing_Crime_Category,
       SUM(CASE WHEN Cases IS NULL THEN 1 ELSE 0 END) AS Missing_Cases
FROM Crime_Data;   

-- Q3. Are there any duplicate State-Crime Head combinations?
SELECT State_UT, Crime_Head, COUNT(*) AS Duplicate_Records FROM Crime_Data
GROUP BY State_UT, Crime_Head 
HAVING COUNT(*) > 1;   

-- Q4. Are there any records with negative or invalid case counts?
SELECT * FROM Crime_Data WHERE Cases < 0;

-- Q5. How many unique States/UTs are included in the dataset?
SELECT COUNT(DISTINCT State_UT) AS Total_States_UTs FROM Crime_Data;

-- Q6. How many unique Crime Categories are represented?
SELECT COUNT(DISTINCT Crime_Category) AS Total_Crime_Categories FROM Crime_Data;
       
-- Q7. How many unique Crime Heads are present in the dataset?
SELECT COUNT(DISTINCT Crime_Head) AS Total_Crime_Head FROM Crime_Data;

-- Q8. What is the total number of reported crime cases available for analysis?
SELECT SUM(Cases) AS Total_Reported_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes';

-- Q9. Are there any blank (empty string) values in the dataset?
SELECT 
	SUM(CASE WHEN TRIM(State_UT) = '' THEN 1 ELSE 0 END) AS Blank_State_UT,
    SUM(CASE WHEN TRIM(Crime_Head) = '' THEN 1 ELSE 0 END) AS Blank_Crime_Head,
    SUM(CASE WHEN TRIM(Crime_Category) = '' THEN 1 ELSE 0 END) AS Blank_Crime_Category,
    SUM(CASE WHEN TRIM(Cases) = '' THEN 1 ELSE 0 END) AS Blank_Cases
FROM Crime_Data;    


-- Exploratory Data Analysis
-- Q10. What are the different Crime Categories included in the dataset?
SELECT DISTINCT Crime_Category FROM Crime_Data
ORDER BY Crime_Category;

-- Q11. How many Crime Heads belong to each Crime Category?
SELECT Crime_Category, COUNT(DISTINCT Crime_Head) AS Number_of_Crime_Heads FROM Crime_Data
GROUP BY Crime_Category
ORDER BY Number_of_Crime_Heads DESC;

-- Q12. Which Crime Heads reported zero cases across all States/UTs?
SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
GROUP BY Crime_Head
HAVING SUM(Cases) = 0
ORDER BY Crime_Head;

-- Q13. What are the minimum, average and maximum reported cases per Crime Head?
SELECT MIN(Total_Cases) AS Minimum_Cases, 
AVG(Total_Cases) AS Average_Cases, 
MAX(Total_Cases) AS Maximum_Cases 
FROM 
(SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head) AS Crime_Head_Totals;

-- Q14. How are the reported cases distributed across different Crime Categories?
SELECT Crime_Category, SUM(Cases) AS Total_Cases, 
ROUND(100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Percentage_of_Total
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Percentage_of_Total DESC;


-- State-wise Analysis
-- Q15. Which States/UTs reported the highest total crimes against women?
SELECT State_UT, SUM(Cases) AS Total_Crimes FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Crimes DESC
LIMIT 10;

-- Q16. Which States/UTs reported the lowest total crimes against women?
SELECT State_UT, SUM(Cases) AS Total_Crimes FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Crimes ASC
LIMIT 10;

-- Q17. Rank all States/UTs based on the total reported crime cases.
SELECT State_UT, SUM(Cases) AS Total_Cases,
DENSE_RANK() OVER(ORDER BY SUM(Cases) DESC) AS State_Rank
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY State_Rank;

-- Q18. Which States/UTs reported crime cases above the national average?
SELECT State_UT, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
HAVING SUM(Cases) > 
(SELECT AVG(State_Total) FROM (SELECT State_UT, SUM(Cases) AS State_Total FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT) AS State_Totals) 
ORDER BY Total_Cases DESC;

-- Q19. What percentage of total reported crimes does each State/UT contribute?
SELECT State_UT, SUM(Cases) AS Total_Cases, 
ROUND(100 * SUM(Cases)/(SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Percentage_of_Total FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Percentage_of_Total DESC;

-- Q20. Which five States/UTs together account for the largest share of reported crimes?
SELECT SUM(Total_Cases) AS Top_5_Total_Cases, 
ROUND(100 * SUM(Total_Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Top_5_Percentage_of_Total 
FROM (SELECT State_UT, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Cases DESC
LIMIT 5) AS Top_5_States;


-- Crime Category Analysis
-- Q21. Which Crime Categories have the highest number of reported cases?
SELECT Crime_Category, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Total_Cases DESC
LIMIT 5;

-- Q22. Which Crime Categories have the lowest number of reported cases?
SELECT Crime_Category, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Total_Cases ASC
LIMIT 5;

-- Q23. What percentage of total reported crimes does each Crime Category contribute?
SELECT Crime_Category, SUM(Cases) AS Total_Cases,
ROUND(100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Percentage_of_Total
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Total_Cases DESC; 

-- Q24. Rank all Crime Categories based on total reported cases.
SELECT Crime_Category, SUM(Cases) AS Total_Cases,
DENSE_RANK() OVER(ORDER BY SUM(Cases) DESC) AS Crime_Rank
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Crime_Rank;

-- Q25. Which Crime Categories should be prioritized based on their overall contribution to reported crimes?
SELECT Crime_Category, SUM(Cases) AS Total_Cases,
ROUND(100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Percentage_of_Total,
CASE WHEN
100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes') >= 15 THEN 'High Priority'
WHEN
100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes') >= 10 THEN 'Medium Priority'
ELSE 'Low Priority'
END AS 'Priority Level'
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Percentage_of_Total DESC;


-- Crime Head Analysis
-- Q26. Which are the Top 10 most repeated Crime Heads across India?
SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
ORDER BY Total_Cases DESC
LIMIT 10;

-- Q27. Which Crime Heads have the lowest reported cases?
SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
ORDER BY Total_Cases ASC
LIMIT 10;

-- Q28. Which Crime Heads reported cases above the overall average?
SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
HAVING SUM(Cases) > 
(SELECT AVG(Crime_Head_Total) FROM 
(SELECT Crime_Head, SUM(Cases) AS Crime_Head_Total FROM Crime_Data WHERE Analysis_Include = 'Yes' GROUP BY Crime_Head) AS Crime_Head_Totals)
ORDER BY Total_Cases DESC;

-- Q29. What percentage of the total reported crimes is contributed by the Top 10 Crime Heads?
SELECT SUM(Total_Cases) AS Top_10_Total_Cases,
ROUND(100 * SUM(Total_Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Top_10_Percentage_of_Total
FROM (SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
ORDER BY Total_Cases DESC
LIMIT 10) AS Top_10_Crime_Heads;

-- Q30. Which Crime Heads contribute less than 1% of the total reported crimes?
SELECT Crime_Head, SUM(Cases) AS Total_Cases,
ROUND(100 * SUM(Cases) / (SELECT SUM(Cases) FROM Crime_Data WHERE Analysis_Include = 'Yes'), 2) AS Percentage_of_Total
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
HAVING 100 * SUM(Cases) / (SELECT SUM(Cases) FROM crime_Data WHERE Analysis_Include = 'Yes') < 1
ORDER BY Percentage_of_Total DESC;


-- Comparative Analysis
-- Q31. Which State/UT reported highest number of Rape cases?
SELECT State_UT, SUM(Cases) AS Total_Rape_Cases FROM Crime_Data
WHERE Crime_Head = 'Rape (Total)' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Rape_Cases DESC
LIMIT 1; 

-- Q32. Which State/UT reported the highest number of Domestic Violence related cases?
SELECT State_UT, SUM(Cases) AS Total_Domestic_Violence_Cases FROM Crime_Data
WHERE Crime_Category = 'Domestic Violence' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Domestic_Violence_Cases DESC
LIMIT 1;

-- Q33. Which State/UT reported the highest number of Cyber Crime cases against women?
SELECT State_UT, SUM(Cases) AS Total_Cyber_Crime_Cases FROM Crime_Data
WHERE Crime_Head = 'Women-Centric Cyber Crime (Total)' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Cyber_Crime_Cases DESC
LIMIT 1;

-- Q34. Which State/UT reported the highest number of Human Trafficking cases?
SELECT State_UT, SUM(Cases) AS Total_Human_Trafficking_Cases FROM Crime_Data
WHERE Crime_Category = 'Human Trafficking' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Human_Trafficking_Cases DESC
LIMIT 1;

-- Q35. Which State/UT reported the highest number of POCSO - related cases involving girl chidren?
SELECT State_UT, SUM(Cases) AS Total_POCSO_Cases FROM Crime_Data
WHERE Crime_Head = 'POCSO (Protection of Children from Sexual Offences Act) (Total)' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_POCSO_Cases DESC
LIMIT 1;

-- Q36. Which State/UT reported the highest number of Kidnapping and Abduction cases?
SELECT State_UT, SUM(Cases) AS Total_Kidnapping_and_Abduction_Cases FROM Crime_Data
WHERE Crime_Head = 'Kidnapping & Abduction (Total)' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Kidnapping_and_Abduction_Cases DESC
LIMIT 1;

-- Q37. Which State/UT reported the highest number of Assault on Women cases?
SELECT State_UT, SUM(Cases) AS Total_Assault_on_Women_Cases FROM Crime_Data
WHERE Crime_Head = 'Assault to Outrage Modesty (Total)' AND Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Assault_on_Women_Cases DESC
LIMIT 1;


-- Advanced SQL Analysis
-- Q38. How can all States/UTs be ranked based on total reported crime cases using Window functions?
SELECT State_UT, SUM(Cases) AS Total_Cases,
DENSE_RANK() OVER(ORDER BY SUM(Cases) DESC) AS State_Rank
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY State_Rank ASC;

-- Q39. What is the highest reported Crime Head within each Crime Category?
WITH Ranked_Crimes AS(
SELECT Crime_Category, Crime_Head, SUM(Cases) AS Total_Cases,
DENSE_RANK() OVER(PARTITION BY Crime_Category ORDER BY SUM(Cases) DESC) AS Crime_Head_Rank
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category, Crime_Head)
SELECT Crime_Category, Crime_Head, Total_Cases FROM Ranked_Crimes
WHERE Crime_Head_Rank = 1
ORDER BY Total_Cases DESC;

-- Q40. Which States/UTs reported crime cases above the national average using a Common Table Expression (CTE)?
WITH State_Totals AS (
SELECT State_UT, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT)
SELECT State_UT, Total_Cases FROM State_Totals
WHERE Total_Cases > (SELECT AVG(Total_Cases) FROM State_Totals)
ORDER BY Total_Cases DESC;

-- Q41. How can States/UTs be classified into High, Medium and Low crime groups based on total reported cases?
WITH State_Totals AS(
SELECT State_UT, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT)
SELECT State_UT, Total_Cases,
CASE WHEN Total_Cases >= 1.5 * (SELECT AVG(Total_Cases) FROM State_Totals) THEN 'High Crime'
     WHEN Total_Cases >= 0.75 * (SELECT AVG(Total_Cases) FROM State_Totals) THEN 'Medium Crime'
	 ELSE 'Low Crime'
END AS 'Crime Group'
FROM State_Totals
ORDER BY Total_Cases DESC;     

-- Q42. What are the Top 3 Crime Heads reported in each State/UT?
WITH Crime_Head_Totals AS(
SELECT State_UT, Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
 WHERE Analysis_Include = 'Yes' AND Record_Level <> 'Total'
GROUP BY State_UT, Crime_Head),
Ranked_Crimes AS(
SELECT State_UT, Crime_Head, Total_Cases,
ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Total_Cases DESC) AS Head_Rank FROM Crime_Head_Totals)
SELECT State_UT, Crime_Head, Total_Cases, Head_Rank FROM Ranked_Crimes
WHERE Head_Rank <= 3
ORDER BY State_UT, Head_Rank;


-- Dashboard KPI Analysis
-- KPI 1. What is the total number of reported crime cases?
SELECT SUM(Cases) AS Total_Reported_Cases FROM Crime_Data WHERE Analysis_Include = 'Yes';

-- KPI 2. How many States/UTs are included in the analysis?
SELECT COUNT(DISTINCT State_UT) AS Number_of_State_and_UTs FROM Crime_Data WHERE Analysis_Include = 'Yes';

-- KPI 3. How many Crime Categories are represented in the dataset?
SELECT Crime_Category AS Name_of_Crime, 
DENSE_RANK() OVER(ORDER BY Crime_Category) AS Crime_Number
FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category;

-- KPI 4. How many unique Crime Heads are analyzed?
SELECT COUNT(DISTINCT Crime_Head) AS Number_of_Crime_Heads FROM Crime_Data;

-- KPI 5. Which State/UT reported the highest total crime cases?
SELECT State_UT, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY State_UT
ORDER BY Total_Cases DESC
LIMIT 1;

-- KPI 6. Which Crime Category reported the highest number of cases?
SELECT Crime_Category, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Category
ORDER BY Total_Cases DESC
LIMIT 1;

-- KPI 7. Which Crime_Head reported the highest number of cases?
SELECT Crime_Head, SUM(Cases) AS Total_Cases FROM Crime_Data
WHERE Analysis_Include = 'Yes'
GROUP BY Crime_Head
ORDER BY Total_Cases DESC
LIMIT 1;