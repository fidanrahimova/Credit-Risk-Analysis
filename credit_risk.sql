-- Total number of clients
SELECT COUNT(*) AS total_clients
FROM credit_risk_dataset;


-- Number of delinquient clients
SELECT COUNT(*) AS delinquient_clients
FROM credit_risk_dataset
WHERE Is_delinquient='Yes';


-- Default rate
SELECT 
ROUND((SELECT COUNT(*) AS delinquient_clients
FROM credit_risk_dataset
WHERE Is_delinquient='Yes')*100/
(SELECT COUNT(*) AS total_clients
FROM credit_risk_dataset),2) AS default_rate;


-- Percentage share of clients with 100% credit utilization 
SELECT
ROUND((SELECT COUNT(*)
FROM credit_risk_dataset
WHERE rev_util>=0.995)*100/
(SELECT COUNT(*) AS total_clients
FROM credit_risk_dataset),2) AS max_utilization_share_ptc;

-- Number of clients and default rate for age_category
SELECT age_category,COUNT(*) AS total_clients,
ROUND(
SUM(CASE
 WHEN is_delinquient = 'Yes' THEN 1 ELSE 0 
 END)
 * 100.0 / COUNT(*),2) AS default_rate
FROM credit_risk_dataset
GROUP BY age_category
ORDER BY default_rate DESC;

-- Number of clients and default rate for risk level (debt_ratio)
SELECT Risk_level,COUNT(*) AS total_clients,
ROUND(
SUM(CASE
 WHEN is_delinquient = 'Yes' THEN 1 ELSE 0 
 END)
 * 100.0 / COUNT(*),2) AS default_rate
FROM credit_risk_dataset
GROUP BY Risk_level
ORDER BY default_rate DESC;

-- Number of clients and default rate for late category
SELECT 
CASE 
WHEN late_30_59=0 THEN '0'
WHEN late_30_59=1 OR late_30_59=2 THEN '1-2'
ELSE '3+'
END AS late_category,
COUNT(*) AS total_clients,
ROUND(
SUM(CASE
 WHEN late_90>0 THEN 1 ELSE 0 
 END)
 * 100.0 / COUNT(*),2) AS default_rate
FROM credit_risk_dataset
GROUP BY late_category
ORDER BY late_category asc;

-- Top 5 highest debt ratio clients per age category
WITH ranked_clients AS (
    SELECT 
        age_category,
        debt_ratio,
        DENSE_RANK() OVER(
            PARTITION BY age_category 
            ORDER BY debt_ratio DESC
        ) AS rnk
    FROM credit_risk_dataset
)
SELECT 
    age_category,
    debt_ratio,
    rnk
FROM ranked_clients
WHERE rnk <= 5;

