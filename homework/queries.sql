--- Get the top 3 product types that have proven most profitable
SELECT product_line, SUM(profit) AS product_profit
FROM products
INNER JOIN profit
ON products.product_code = profit.product_code
GROUP BY product_line
ORDER BY product_profit DESC
LIMIT(3);

--- Get the top 3 products by most items sold
SELECT product_name, SUM(quantity_ordered) AS items_sold
FROM products
INNER JOIN profit
ON products.product_code = profit.product_code
GROUP BY products.product_code
ORDER BY items_sold DESC
LIMIT(3);

--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium
(SELECT product_name, customers.country, SUM(quantity_ordered) AS items_sold
FROM products
INNER JOIN profit
ON products.product_code = profit.product_code
INNER JOIN customers
ON profit.customer_number = customers.customer_number
WHERE customers.country = 'USA'
GROUP BY customers.country, product_name
ORDER BY items_sold DESC
LIMIT(3))
UNION ALL
(SELECT product_name, customers.country, SUM(quantity_ordered) AS items_sold
FROM products
INNER JOIN profit
ON products.product_code = profit.product_code
INNER JOIN customers
ON profit.customer_number = customers.customer_number
WHERE customers.country = 'Spain'
GROUP BY customers.country, product_name
ORDER BY items_sold DESC
LIMIT(3))
UNION ALL
(SELECT product_name, customers.country, SUM(quantity_ordered) AS items_sold
FROM products
INNER JOIN profit
ON products.product_code = profit.product_code
INNER JOIN customers
ON profit.customer_number = customers.customer_number
WHERE customers.country = 'Belgium'
GROUP BY customers.country, product_name
ORDER BY items_sold DESC
LIMIT(3));


--- Get the most profitable day of the week
SELECT date_weekday, SUM(profit) AS total_profit
FROM dates
INNER JOIN profit
ON dates.full_date = profit.order_date
GROUP BY date_weekday
ORDER BY total_profit DESC
LIMIT(1);

--- Get the top 3 city-quarters with the highest average profit margin in their sales
SELECT offices.city, dates.date_quarter, AVG(profit_margin) AS avg_margin
FROM dates
INNER JOIN profit
ON dates.full_date = profit.order_date
INNER JOIN offices
ON profit.office_code = offices.office_code
GROUP BY offices.city, dates.date_quarter
ORDER BY avg_margin DESC
LIMIT(3);


--- List the employees who have sold more goods (in $ amount) than the average employee.
SELECT employees.employee_number AS top_employees, SUM(revenue) AS total_revenue
FROM employees
INNER JOIN profit
ON employees.employee_number = profit.sales_rep_employee_number
GROUP BY employee_number
HAVING SUM(revenue) > (SELECT SUM(revenue)/COUNT(DISTINCT(employee_number))
                       FROM employees
                       INNER JOIN profit
                       ON employees.employee_number = profit.sales_rep_employee_number);


--- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts
--- (BONUS: Add the employee number)
SELECT order_number, sales_rep_employee_number, sum(revenue) AS total_revenue
FROM profit
GROUP BY order_number, sales_rep_employee_number
ORDER BY total_revenue DESC
LIMIT(SELECT (COUNT(*)/10) FROM orders);
