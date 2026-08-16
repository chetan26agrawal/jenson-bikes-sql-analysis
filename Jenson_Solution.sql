
## 1. Find the total number of products sold by each store along with the store name.
SELECT 
    s.store_name, SUM(oi.quantity) AS Total_Products_Sold
FROM
    stores s
        JOIN
    orders o USING (store_id)
        JOIN
    order_items oi USING (order_id)
GROUP BY s.store_name
ORDER BY Total_Products_Sold DESC;

## 2. Calculate the cumulative sum of quantities sold for each product over time.
SELECT 
    p.product_name,
    o.order_date,
    oi.quantity,
    SUM(oi.quantity) OVER (
        PARTITION BY p.product_id
        ORDER BY o.order_date, o.order_id
    ) AS cumulative_quantity
FROM products p
JOIN order_items oi using(product_id)
JOIN orders o using(order_id)
ORDER BY p.product_name, o.order_date;

## 3. Find the product with the highest total sales (quantity * price) for each category.
WITH Product_Sales AS
(
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity * oi.list_price) AS Total_Sales,
        RANK() OVER(
            PARTITION BY c.category_id
            ORDER BY SUM(oi.quantity * oi.list_price) DESC
        ) AS rnk
    FROM categories c
    JOIN products p USING(category_id)
    JOIN order_items oi USING(product_id)
    GROUP BY c.category_id, c.category_name, p.product_id, p.product_name
)
SELECT
    category_name,
    product_name,
    Total_Sales
FROM Product_Sales
WHERE rnk = 1;

## 4. Find the customer who spent the most money on orders.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS Customers_Name,
    SUM(oi.quantity * oi.list_price) AS Total_Money
FROM
    customers c
        JOIN
    orders o USING (customer_id)
        JOIN
    order_items oi USING (order_id)
GROUP BY Customers_Name
ORDER BY Total_Money DESC
LIMIT 1;

## 5. Find the highest-priced product for each category name.
SELECT 
    c.category_name, p.product_name, p.list_price
FROM
    categories c
        JOIN
    products p USING (category_id)
WHERE
    p.list_price = (SELECT 
            MAX(p2.list_price)
        FROM
            products p2
        WHERE
            p2.category_id = p.category_id);
            
## 6. Find the total number of orders placed by each customer per store.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS Customers_Name,
    s.store_name,
    COUNT(o.order_id) AS Total_Orders
FROM
    customers c
        JOIN
    orders o USING (customer_id)
        JOIN
    stores s USING (store_id)
GROUP BY Customers_Name , s.store_name
ORDER BY Total_Orders DESC;

## 7. Find the names of staff members who have not handled any order.
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    order_id
FROM
    staffs s
        LEFT JOIN
    orders o USING (staff_id)
WHERE
    order_id IS NULL;

## 8. Find the top 3 most sold products in terms of quantity.
SELECT 
    p.product_name, SUM(oi.quantity) AS Total_Quantity_Sold
FROM
    products p
        JOIN
    order_items oi USING (product_id)
GROUP BY p.product_name
ORDER BY Total_Quantity_Sold DESC
LIMIT 3;

## 9. Find the median value of the price list. 
SELECT 
    list_price AS median_price
FROM
    products
ORDER BY list_price
LIMIT 1 OFFSET 160;

## 10. List all products that have never been ordered.(use Exists)
SELECT 
    p.product_id, p.product_name
FROM
    products p
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            order_items oi
        WHERE
            p.product_id = oi.product_id);

## 11. List the names of staff members who have handled more orders than the average number of orders handled by all staff members.
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    COUNT(o.order_id) AS Total_Sales
FROM
    staffs s
        JOIN
    orders o USING (staff_id)
GROUP BY s.staff_id , staff_name
HAVING COUNT(o.order_id) > (SELECT 
        AVG(staff_total)
    FROM
        (SELECT 
            COUNT(o.order_id) AS Staff_Total
        FROM
            staffs s
        LEFT JOIN orders o USING (staff_id)
        GROUP BY staff_id) AS avg_sale);

## 12. Identify the customers who have ordered all types of products from Road Bikes category.
SELECT 
    customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS Customers_Name
FROM
    customers c
        JOIN orders o USING (customer_id)
        JOIN order_items oi USING (order_id)
        JOIN products p USING (product_id)
        JOIN categories ca USING (category_id)
WHERE category_name = 'Road Bikes'
GROUP BY customer_id
HAVING COUNT(DISTINCT p.product_id) = (SELECT COUNT(*) FROM products p
            JOIN categories ca USING (category_id)
    WHERE category_name = 'Road Bikes');
        
        select distinct category_name from categories;

