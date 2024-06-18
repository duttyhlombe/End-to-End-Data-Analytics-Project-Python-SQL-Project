SELECT TOP (1000) [order_id]
      ,[order_date]
      ,[ship_mode]
      ,[segment]
      ,[country]
      ,[city]
      ,[state]
      ,[postal_code]
      ,[region]
      ,[category]
      ,[sub_category]
      ,[product_id]
      ,[quantity]
      ,[discount]
      ,[sale_price]
      ,[profit]
  FROM [Hlombe Projects].[dbo].[df_orders]

  -- FIND TOP 10 HIGHEST REVEUE GENERATING PRODUCTS

  SELECT TOP 10 product_id, sum(sale_price) as sales
  FROM df_orders
  GROUP BY product_id
  ORDER BY sales desc

  -- FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION
  with cte as (
  SELECT region, product_id, sum(sale_price) as sales
  FROM df_orders
  GROUP BY region,product_id)
  SELECT * FROM (
  SELECT * 
  , row_number() over(partition by region order by sales desc) as rn
  from cte) A
  WHERE rn<5

  -- FIND MONTH OVER MONTH GROWTH COMPARISON FOR 2022 AND 2023 SALES EG: JAN 2022 VS JAN 2023

  with cte as (
  SELECT year(order_date) as order_year, month(order_date) as order_month,
  sum(sale_price) as sales
  from df_orders
  group by year(order_date), month(order_date)
  --order by year(order_date), month(order_date)
  )
  select order_month
  , sum(case when order_year=2022 then sales else 0 end) as sales_2022
  , sum(case when order_year=2023 then sales else 0 end) as sales_2023
  from cte
  group by order_month
  order by order_month

  -- FOR EACH CATEGORY WHICH HAD HIGHEST SALES

  with cte as (
  SELECT category,format(order_date, 'yyyyMM') as order_year_month, sum(sale_price) as sales
  FROM df_orders
  GROUP BY category,format(order_date, 'yyyyMM')
  --ORDER BY category,format(order_date, 'yyyyMM')
  )
  SELECT * FROM (
  SELECT *, 
  row_number() over(partition by category order by sales desc) as rn
  from cte
  ) a 
  WHERE rn=1

  -- which sub category had highest growth by profit in 2023 comopare to 2022

  with cte as (
  SELECT sub_category, year(order_date) as order_year,
  sum(sale_price) as sales
  from df_orders
  group by sub_category, year(order_date)
  --order by year(order_date), month(order_date)
  ) 
  , cte2 as ( 
  select sub_category
  , sum(case when order_year=2022 then sales else 0 end) as sales_2022
  , sum(case when order_year=2023 then sales else 0 end) as sales_2023
  from cte
  group by sub_category
  )
  SELECT TOP 1 *
  ,(sales_2023-sales_2022)*100/sales_2022
  FROM cte2
  order by (sales_2023-sales_2022)*100/sales_2022 desc