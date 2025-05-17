--Cleaning data
SELECT
  TO_DATE(DATE, 'DD/MM/YYYY') AS sales_date,
  TO_NUMBER(REPLACE(SALES, ',', '.')) AS sales,
  TO_NUMBER(REPLACE(COST_OF_SALES, ',', '.')) AS cost_of_sales,
  TO_NUMBER(REPLACE(QUANTITY_SOLD, ',', '.')) AS quantity_sold
FROM sales;
--Creating temporary table to work on
CREATE OR REPLACE TEMP TABLE cleaned_sales AS
SELECT
  TO_DATE(DATE, 'DD/MM/YYYY') AS sales_date,
  TO_NUMBER(REPLACE(SALES, ',', '.')) AS sales,
  TO_NUMBER(REPLACE(COST_OF_SALES, ',', '.')) AS cost_of_sales,
  TO_NUMBER(REPLACE(QUANTITY_SOLD, ',', '.')) AS quantity_sold
FROM sales;
--View cleaned sales data
SELECT * 
FROM cleaned_sales;
--Q1: daily price per unit
SELECT
  sales_date,
  ROUND(sales / quantity_sold, 0) AS daily_price_per_unit
FROM cleaned_sales
WHERE quantity_sold != 0;
--Q2: Average unit sales price
SELECT
  ROUND(SUM(sales) / SUM(quantity_sold), 0) AS avg_price_per_unit
FROM cleaned_sales;
WHERE quantity_sold != 0;
--Q3: Daily % gross profit
SELECT
  sales_date,
  TO_CHAR(ROUND(((sales - cost_of_sales) / sales) * 100, 2)) || '%' AS daily_gross_profit_percent
FROM cleaned_sales
WHERE sales != 0;
--Q4: Daily % gross profit per unit
SELECT
  sales_date,
  ROUND(((sales - cost_of_sales) / quantity_sold) * 100, 2) || '%' AS gross_profit_per_unit
FROM cleaned_sales
WHERE quantity_sold != 0;
--Q5: Price elasticity of demand
--First calculate the top 3 highest sales
SELECT
  sales_date,
  sales,
  cost_of_sales,
  quantity_sold
FROM cleaned_sales
ORDER BY sales DESC
LIMIT 3;
--Price elasticity of demand
WITH TopSales AS (
  SELECT
    sales_date AS period,
    SUM(sales) AS total_sales,
    SUM(quantity_sold) AS total_quantity_sold,
    ROUND(SUM(sales) / NULLIF(SUM(quantity_sold), 0), 2) AS price_per_unit
  FROM cleaned_sales
  GROUP BY sales_date
  ORDER BY total_sales DESC
  LIMIT 3
)
SELECT
  T1.period AS period_1,
  T2.period AS period_2,
  
  ROUND(((T2.total_quantity_sold - T1.total_quantity_sold) / NULLIF(T1.total_quantity_sold, 0)) * 100, 2) AS percent_change_quantity,
  ROUND(((T2.price_per_unit - T1.price_per_unit) / NULLIF(T1.price_per_unit, 0)) * 100, 2) AS percent_change_price,
  
  ROUND(
    (
      ((T2.total_quantity_sold - T1.total_quantity_sold) / NULLIF(T1.total_quantity_sold, 0)) /
      NULLIF((T2.price_per_unit - T1.price_per_unit) / NULLIF(T1.price_per_unit, 0), 0)
    ), 2
  ) AS price_elasticity_demand

FROM TopSales T1
JOIN TopSales T2 ON T1.period < T2.period
ORDER BY period_1;




