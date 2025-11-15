
---------------------------------------------------------------------------------------------------------------------------------------------

-- Manufacturing Analysis SQL Script
-- Date: 22-10-2025

-- Objective:
-- The purpose of this analysis is to understand the monthly manufacturing performance,
-- including total production, rejected quantities, and rejection percentages etc.
-- This will help identify trends, high-rejection months, and areas for improvement.

-- Data Description:
-- Table: manufacturing
-- Columns:
--   doc_date      : Document date (DD-MM-YYYY)
--   today_mfg     : Quantity manufactured on the day
--   rej_qty       : Quantity rejected on the day
--   dept_name 	   : Department Name  

-- The queries below will:
--   1. Aggregate production and rejection data by month.
--   2. Calculate rejection percentages.
--   3. Identify maximum and minimum quantities per month.
--   4. Provide insights for management decision-making and so many other Insights. 



-- KPIs.



DELIMITER //

CREATE FUNCTION format_km(num BIGINT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);
    
    IF num >= 1000000 THEN
        SET result = CONCAT(ROUND(num/1000000,1),'M');
    ELSEIF num >= 1000 THEN
        SET result = CONCAT(ROUND(num/1000,1),'K');
    ELSE
        SET result = num;
    END IF;
    
    RETURN result;
END;
//

DELIMITER ;







# Total Manufactured Qty.
SELECT 
format_km(SUM(today_mfg)) AS total_manufactured
FROM manufacturing;


# Total Rejected Qty. 
SELECT 
format_km(SUM(rej_qty)) AS total_rejected
FROM manufacturing;


# Rejection Rate
SELECT 
ROUND(SUM(rej_qty) * 100 / SUM(today_mfg), 2) AS rejection_percentage
FROM manufacturing;


# Total Processed 
SELECT 
format_km(SUM(processed_qty)) AS total_processed
FROM manufacturing;


# Wastage Qty
SELECT 
format_km(SUM(rej_qty) - SUM('Repeat')) AS Wastage_Qty
FROM manufacturing;


# Department-wise Manufacture vs Rejection
-- Shows which department has highest rejection %
SELECT 
Dept_name,
SUM(today_mfg) AS total_manufactured,
SUM(rej_qty) AS total_rejected,
ROUND(SUM(rej_qty) * 100 / SUM(today_mfg), 2) AS Rejection_percentage
FROM manufacturing
GROUP BY Dept_name
ORDER BY Rejection_percentage DESC;


# Machine-wise Rejected Quantity
-- Identifies machines causing the most rejections.
SELECT 
machine_code,
(rej_qty) AS total_rejected
FROM manufacturing
GROUP BY machine_code
ORDER BY total_rejected DESC
Limit 10;


# Employee-wise Rejected Quantity
-- Employees with high rejection ratio
SELECT 
Emp_name,
SUM(rej_qty) AS total_rejected,
ROUND(SUM(rej_qty)*100 / SUM(today_mfg), 2) AS rejection_percent
FROM manufacturing
GROUP BY Emp_name
ORDER BY total_rejected DESC;


# Monthly Production Trend
-- Shows how production and rejection changed month-to-month

SELECT 
DATE_FORMAT(STR_TO_DATE(doc_date, '%d-%m-%Y'), '%Y-%m') AS month,
SUM(today_mfg) AS total_manufactured,
SUM(rej_qty) AS total_rejected,
ROUND(SUM(Rej_qty) / SUM(today_mfg) * 100, 2) AS rejection_percentage
FROM manufacturing
GROUP BY DATE_FORMAT(STR_TO_DATE(doc_date, '%d-%m-%Y'), '%Y-%m')
ORDER BY month;


# Department Efficiency (Processed vs Manufactured)
SELECT 
dept_name,
SUM(today_mfg) AS manufactured,
SUM(processed_qty) AS processed,
ROUND(SUM(processed_qty)*100 / SUM(today_mfg), 2) AS efficiency_percentage
FROM manufacturing
GROUP BY dept_name
ORDER BY efficiency_percentage DESC;


/* More Insights */
# Top 5 EMP Code with Highest Production

SELECT 
Emp_code,
SUM(today_mfg) AS total_produced
FROM manufacturing
GROUP BY Emp_code
ORDER BY total_produced DESC
LIMIT 5;


# Date with Maximum Rejection
SELECT 
doc_date,
SUM(rej_qty) AS total_rejected
FROM manufacturing
GROUP BY doc_date
ORDER BY total_rejected DESC
LIMIT 1;

# Date with Maximum Production 
SELECT 
doc_date,
Sum(today_mfg) AS Total_Produced
FROM manufacturing 
GROUP BY doc_date
ORDER BY Total_Produced DESC
LIMIT 1;


# Top 5 machine code with highest efficiency 
SELECT 
machine_code,
ROUND(SUM(processed_qty)*100 / SUM(today_mfg), 2) AS machine_efficiency
FROM manufacturing
GROUP BY machine_code
ORDER BY machine_efficiency DESC
LIMIT 5;
