
---

# Sales Data Analysis: Insights from Retail Orders

## Overview

This project involves data extraction, cleaning, and analysis using Jupyter Notebook and MySQL. The goal is to derive insights from sales data and answer specific business questions.

## Table of Contents

1. [Technologies Used](#technologies-used)
2. [Data Extraction](#data-extraction)
3. [Data Cleaning](#data-cleaning)
4. [Data Loading](#data-loading)
5. [Queries](#queries)
6. [Results](#results)
7. [Conclusion](#conclusion)
8. [License](#license)

## Technologies Used

- **Jupyter Notebook**: For data extraction and cleaning
- **Pandas**: For data manipulation and cleaning
- **SQLAlchemy**: For loading data into MySQL
- **MySQL**: For querying and data analysis

## Data Extraction

1. **Download Data**: Data was downloaded from [data source link].
2. **Extract Data**: Utilized Python libraries to read the dataset into a Jupyter Notebook.

## Data Cleaning

In this step, several operations were performed to ensure the dataset was ready for analysis:

- **Handled Missing Values**: Addressed NaN values by [method used, e.g., filling, dropping].
- **Reformatted Dates**: Standardized date formats for consistency.
- **Removed Unwanted Columns**: Dropped columns that were not relevant to the analysis.
- **Reformatted Column Names**: Ensured column names were descriptive and consistent.
- **Added Aggregated Columns**: Created additional columns for better insights, such as total sales and average revenue.

## Data Loading

After cleaning, the data was loaded into a MySQL database using SQLAlchemy:

```python
from sqlalchemy import create_engine

# Create an engine instance
engine = create_engine('mysql+pymysql://username:password@localhost/db_name')

# Load DataFrame to MySQL
data_frame.to_sql('table_name', con=engine, if_exists='replace', index=False)
```

## Queries

To derive insights from the data, the following SQL queries were executed:

1. **Top 10 Highest Revenue Generating Products**:
   ```sql
   SELECT product_id, ROUND(SUM(sale_price * quantity), 2) AS sale
   FROM master.retail_orders
   GROUP BY product_id
   ORDER BY sale DESC
   LIMIT 10;
   ```

2. **Top 5 Highest Selling Products in Each Region**:
   ```sql
   WITH cte1 AS (
       SELECT region, product_id, SUM(quantity) AS total_sale, 
              ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(quantity) DESC) AS record_number
       FROM master.retail_orders
       GROUP BY region, product_id
       ORDER BY region, total_sale DESC 
   )
   SELECT region, product_id, total_sale AS top_5_highest_selling_Products
   FROM cte1
   WHERE record_number <= 5;
   ```

3. **Month-over-Month Growth Comparison for 2022 and 2023 Sales**:
   ```sql
   WITH sales_2022 AS (
       SELECT (DATE_FORMAT(order_date, '%m')) AS t_date, ROUND(SUM(sale_price), 2) AS total_sale_2022
       FROM master.retail_orders
       WHERE order_date BETWEEN '2022-01-01' AND '2022-12-31'
       GROUP BY t_date
   ),
   sales_2023 AS (
       SELECT (DATE_FORMAT(order_date, '%m')) AS t_date, ROUND(SUM(sale_price * quantity), 2) AS total_sale_2023
       FROM master.retail_orders
       WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
       GROUP BY t_date
   )
   SELECT s1.t_date, total_sale_2022, total_sale_2023
   FROM sales_2022 s1 
   INNER JOIN sales_2023 s2 ON s1.t_date = s2.t_date
   ORDER BY s1.t_date;
   ```

4. **For Each Category, Which Month Had Highest Sales**:
   ```sql
   WITH cte1 AS (
       SELECT category, DATE_FORMAT(order_date, '%M') AS monthnum, ROUND(SUM(sale_price * quantity), 2) AS total_sale
       FROM master.retail_orders
       GROUP BY category, monthnum
       ORDER BY category, total_sale DESC
   ),
   cte2 AS (
       SELECT *, 
              RANK() OVER (PARTITION BY category ORDER BY total_sale DESC) AS category_sale_rank
       FROM cte1
   )
   SELECT category, monthnum, total_sale
   FROM cte2
   WHERE category_sale_rank = 1;
   ```

5. **Which Subcategory Had Highest Growth by Profit in 2023 Compared to 2022**:
   ```sql
   WITH profit_sub_category_2022 AS (
       SELECT sub_category, ROUND(SUM(profit * quantity), 2) AS total_profit_2022
       FROM master.retail_orders
       WHERE order_date BETWEEN '2022-01-01' AND '2022-12-31'
       GROUP BY sub_category
   ),
   profit_sub_category_2023 AS (
       SELECT sub_category, ROUND(SUM(profit * quantity), 2) AS total_profit_2023
       FROM master.retail_orders
       WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
       GROUP BY sub_category
   ),
   cte3 AS (
       SELECT c1.sub_category, total_profit_2022, total_profit_2023, 
              total_profit_2023 - total_profit_2022 AS difference
       FROM profit_sub_category_2022 c1 
       INNER JOIN profit_sub_category_2023 c2 ON c1.sub_category = c2.sub_category
       WHERE total_profit_2023 > total_profit_2022
       ORDER BY difference DESC
   )
   SELECT sub_category, difference AS highest_profit_2023_by_sub_category
   FROM cte3
   LIMIT 1;
   ```

## Results

- **Top 10 Products**: TEC-CO-10004722,OFF-BI-10000545....
- **Top 5 Products by Region**: Central	OFF-BI-10000301	34, ...
- **Month-over-Month Growth**:February has highest growth.
- **Highest Sales by Category**: Furniture,Office Supplies,Technology
- **Highest Growth by Subcategory**: Machines

## Conclusion

This project successfully analyzed sales data to answer specific business questions, providing valuable insights into product performance and growth trends.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
