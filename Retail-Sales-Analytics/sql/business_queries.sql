USE RetailSales
SELECT DB_NAME();
SELECT *
FROM dbo.sales_data

SELECT * FROM dbo.sales_data
--Query 1(TOTAL SALES)
SELECT SUM(Sales) AS total_sales FROM  dbo.sales_data

--Query 2(TOTAL PROFIT)
SELECT SUM(Profit) AS total_profit FROM  dbo.sales_data

--Query 3(TOTAL ORDERS)
SELECT COUNT(*) AS total_orders FROM  dbo.sales_data
 
 --Query 4(Which region generates the highest sales?)
 SELECT Region,SUM(Sales) AS TOTAL_SALES
 FROM dbo.sales_data 
 GROUP BY Region 
 ORDER BY TOTAL_SALES DESC

 --QUERY 5(Which region generates the highest profit?)
 SELECT Region,SUM(Profit) AS TOTAL_PROFIT
 FROM dbo.sales_data 
 GROUP BY Region 
 ORDER BY TOTAL_PROFIT DESC

 --QUERY 6(Which categories generate the highest sales?)
 SELECT Category,SUM(Sales) AS TOTAL_SALES
 FROM dbo.sales_data 
 GROUP BY Category 
 ORDER BY TOTAL_Sales DESC

 --QUERY 7(Which categories generate the highest profit?)
 SELECT Category,SUM(Profit) AS TOTAL_PROFIT
 FROM dbo.sales_data 
 GROUP BY Category 
 ORDER BY TOTAL_PROFIT DESC

  --QUERY 8(Which SEGMENT generate the highest sales?)
 SELECT Segment,SUM(Sales) AS TOTAL_SEGMENT
 FROM dbo.sales_data 
 GROUP BY SEGMENT 
 ORDER BY TOTAL_SEGMENT DESC

 
  --QUERY 9(Which SEGMENT generate the highest profit?)
 SELECT Segment,SUM(Sales) AS TOTAL_profit
 FROM dbo.sales_data 
 GROUP BY SEGMENT 
 ORDER BY TOTAL_profit DESC

 --Query 10(Top 10 cities by total sales)
 SELECT TOP(10) City,SUM(Sales) AS TOTAL_sales
 FROM dbo.sales_data 
 GROUP BY City 
 ORDER BY TOTAL_sales DESC

 --Query 11(Top 10 cities by total profit)
 SELECT TOP(10) City,SUM(Profit) AS TOTAL_profit
 FROM dbo.sales_data 
 GROUP BY City 
 ORDER BY TOTAL_profit DESC

 --Query 12(High Sales but Low/Negative Profit Sub-Categories)
 SELECT Sub_Category,SUM(Sales) AS TOTAL_SALES,SUM(Profit) AS TOTAL_PROFIT
 FROM dbo.sales_data
 GROUP BY Sub_Category
 ORDER BY TOTAL_SALES DESC,TOTAL_PROFIT ASC

 --Query 13(Which cities are generating losses for the company?)
 SELECT TOP(5) City,SUM(Profit) AS TOTAL
 FROM dbo.sales_data
 GROUP BY City
 ORDER BY TOTAL ASC

 --Query 14(sub-categories have the highest profit margin?)
 SELECT TOP(1) Sub_Category,SUM(Sales) AS TOTAL_S,SUM(Profit) AS TOTAL_P,
  ROUND((SUM(Profit) * 100.0 / SUM(Sales)), 2)  AS PROFIT_MARGIN
 FROM dbo.sales_data
 GROUP BY Sub_Category
 ORDER BY PROFIT_MARGIN DESC
 
 --Query 15(Does higher discount reduce profitability?)
 SELECT
    CASE
        WHEN Discount = 0 THEN '0%'
        WHEN Discount > 0 AND Discount <= 0.10 THEN '0-10%'
        WHEN Discount > 0.10 AND Discount <= 0.20 THEN '10-20%'
        WHEN Discount > 0.20 AND Discount <= 0.30 THEN '20-30%'
        WHEN Discount > 0.30 AND Discount <= 0.40 THEN '30-40%'
        ELSE '40%+'
    END AS Discount_Range,

    COUNT(*) AS Total_Orders,

    ROUND(SUM(Sales),2) AS Total_Sales,

    ROUND(SUM(Profit),2) AS Total_Profit,

    ROUND((SUM(Profit) * 100.0 / SUM(Sales)),2) AS Profit_Margin_Percent

FROM dbo.sales_data

GROUP BY
    CASE
        WHEN Discount = 0 THEN '0%'
        WHEN Discount > 0 AND Discount <= 0.10 THEN '0-10%'
        WHEN Discount > 0.10 AND Discount <= 0.20 THEN '10-20%'
        WHEN Discount > 0.20 AND Discount <= 0.30 THEN '20-30%'
        WHEN Discount > 0.30 AND Discount <= 0.40 THEN '30-40%'
        ELSE '40%+'
    END

ORDER BY
    MIN(Discount);

--Query 16(categories have the highest profit margin?)
 SELECT TOP(1) Category,SUM(Sales) AS TOTAL_S,SUM(Profit) AS TOTAL_P,
  ROUND((SUM(Profit) * 100.0 / SUM(Sales)), 2)  AS PROFIT_MARGIN
 FROM dbo.sales_data
 GROUP BY Category
 ORDER BY PROFIT_MARGIN DESC

 --Query 17(Which ship mode is most preferred and most profitable?)
 SELECT Ship_Mode, COUNT(*) AS ORDERS,SUM(SALES) AS TS,SUM(PROFIT) AS TP
 FROM dbo.sales_data
 GROUP BY Ship_Mode
 ORDER BY ORDERS DESC

 --Query 18(Categories have high sales but below-average profit margin?)
 WITH SalesCTE AS
(
    SELECT
        Sub_Category,
        SUM(Sales) AS Total_Sales
    FROM dbo.sales_data
    GROUP BY Sub_Category
),

RunningSales AS
(
    SELECT
        Sub_Category,
        Total_Sales,

        SUM(Total_Sales) OVER
        (
            ORDER BY Total_Sales DESC
        ) AS Cumulative_Sales,

        SUM(Total_Sales) OVER () AS Overall_Sales

    FROM SalesCTE
)

SELECT
    Sub_Category,
    Total_Sales,
    Cumulative_Sales,
    ROUND(
        (Cumulative_Sales * 100.0 / Overall_Sales),
        2
    ) AS Cumulative_Percentage

FROM RunningSales

ORDER BY Total_Sales DESC;

--Query 19(Which Regions are Over-Discounted?)
SELECT
    Region,
    AVG(Discount) AS Avg_Discount,
    SUM(Profit) AS Total_Profit
FROM dbo.sales_data
GROUP BY Region
HAVING AVG(Discount) >
(
    SELECT AVG(Discount)
    FROM dbo.sales_data
)
ORDER BY Avg_Discount DESC;

--Query 20(hiddengems category)
SELECT
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) * 100.0 / SUM(Sales)),
        2
    ) AS Profit_Margin
FROM dbo.sales_data
GROUP BY Sub_Category
HAVING SUM(Sales) <
(
    SELECT AVG(TotalSales)
    FROM
    (
        SELECT SUM(Sales) AS TotalSales
        FROM dbo.sales_data
        GROUP BY Sub_Category
    ) A
)
ORDER BY Profit_Margin DESC;

--21 Top 5 Cities by Sales (RANK)
SELECT
    City,
    SUM(Sales) AS Total_Sales,
    RANK() OVER(ORDER BY SUM(Sales) DESC) AS Sales_Rank
FROM Superstore
GROUP BY City;
--22Top 5 Cities by Profit (DENSE_RANK)
SELECT
    City,
    SUM(Profit) AS Total_Profit,
    DENSE_RANK() OVER(ORDER BY SUM(Profit) DESC) AS Profit_Rank
FROM Superstore
GROUP BY City;
--23 . Sales Contribution by Category (%)
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    ROUND(
        100.0 * SUM(Sales) /
        SUM(SUM(Sales)) OVER (),
        2
    ) AS Sales_Percentage
FROM Superstore
GROUP BY Category;

--24 . Running Total Sales by Region
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(SUM(Sales)) OVER(
        ORDER BY SUM(Sales)
    ) AS Running_Sales
FROM Superstore
GROUP BY Region;

--25 Previous Region Profit Comparison (LAG)
SELECT
    Region,
    SUM(Profit) AS Total_Profit,
    LAG(SUM(Profit))
    OVER(ORDER BY SUM(Profit)) AS Previous_Profit
FROM Superstore
GROUP BY Region;

-- 26 Highest Selling Product in Each Category (ROW_NUMBER)
WITH ProductSales AS
(
    SELECT
        Category,
        [Sub-Category],
        SUM(Sales) AS Total_Sales,
        ROW_NUMBER() OVER(
            PARTITION BY Category
            ORDER BY SUM(Sales) DESC
        ) AS rn
    FROM Superstore
    GROUP BY Category, [Sub-Category]
)

SELECT *
FROM ProductSales
WHERE rn = 1;

