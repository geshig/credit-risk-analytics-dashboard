#Credit Risk Analysis - SQL Queries
#Dataset: UCI Credit Card Default (30K records)

#1 Default rate by education level
SELECT 
    COUNT(id) AS Total_clients, 
    SUM(default_payment) AS Total_defaults, 
    ROUND(SUM(default_payment) * 100 / COUNT(*), 2) AS Default_percent, 
    CASE 
        WHEN EDUCATION = 1 THEN 'Graduate School'
        WHEN EDUCATION = 2 THEN 'University'
        WHEN EDUCATION = 3 THEN 'High School'
        ELSE 'Other'
    END AS Education_level
FROM credit_card
GROUP BY Education_level
ORDER BY Default_percent DESC;


#2 Compare defaulters vs non-defaulters
#Average credit limit, bill amount, and payment for each group
WITH CTEavg AS
    (SELECT 
        default_payment,
        ROUND(AVG(LIMIT_BAL), 1) AS Avg_limit,
        ROUND(AVG(BILL_AMT1), 1) AS Avg_bill,
        ROUND(AVG(PAY_AMT1), 1) AS Avg_payment
    FROM credit_card
    GROUP BY default_payment)
    
SELECT * FROM CTEavg;


#3 Risk segmentation (Low/Medium/High)
WITH Risk_segmentation AS 
    (SELECT *,
        CASE
            WHEN default_payment = 0 AND LIMIT_BAL >= 100000 THEN 'LOW_RISK'
            WHEN default_payment = 0 AND LIMIT_BAL < 100000 THEN 'MEDIUM_RISK'
            WHEN default_payment = 1 THEN 'HIGH_RISK'
        END AS Risk_level
    FROM credit_card)
    
SELECT 
    Risk_level,
    COUNT(*) AS Total_clients,
    ROUND(AVG(LIMIT_BAL), 0) AS Avg_limit,
    ROUND(AVG(BILL_AMT1), 0) AS Avg_bill
FROM Risk_segmentation
GROUP BY Risk_level;


#4 Top 10 highest-risk defaulters
#Clients who defaulted and have highest bill amounts, ranked
WITH TOP10 AS 
    (SELECT ID, age, education, 
        limit_bal, 
        bill_amt1,
        RANK() OVER (ORDER BY bill_amt1 DESC) AS Ranking
    FROM credit_card
    WHERE default_payment = 1)
    
SELECT * FROM TOP10
WHERE Ranking <= 10
ORDER BY Ranking;