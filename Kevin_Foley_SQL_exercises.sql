-- Kevin Foley
-- Week 


--You are hired as a data analyst to help a company make inventory management and planning decisions.
--Dataset - The Orders table [available on the Northwind database]: 
--Task - Use SQL commands like group by, having, and order by to answer the following questions: 

--"""Which months had the highest number of orders? (use the month() function)"""

--Name the columns appropriately. 
--The first column should be the month of orders, and 
--the second column should be the number of order records placed that month. 

--Using Northwind

SELECT 
	MONTH(OrderDate) as OrderMonth,
	COUNT(DISTINCT OrderID) as OrderQty			-- This will produce the same results
	--COUNT(MONTH(OrderId)) as OrderQty,		-- this will produce the same results
	--COUNT(MONTH(OrderDate)) as OrderQty,	    -- This will produce the same results
FROM 
	Orders
--WHERE OrderDate IS NOT NULL					-- This will produce the same result as the HAVING below
GROUP BY
	MONTH(OrderDate)
HAVING 
	COUNT(DISTINCT OrderDate) > 0
	--COUNT(MONTH(OrderDate)) > 0				-- This returns the same as above
	--Count(DISTINCT OrderDate) IS NOT NULL		-- This returns a null
	--COUNT(DISTINCT OrderID) IS NOT NULL		-- This returns a Null
Order By
	COUNT(MONTH(OrderDate)) DESC 

-- *******          Using the Month name ____________________****************
SELECT 
	CONCAT(Format(OrderDate,'MMMM'),'-',MONTH(OrderDate)) as OrderMonth,
	COUNT(DISTINCT OrderID) as OrderQty			-- This will produce the same results
	--COUNT(MONTH(OrderId)) as OrderQty,		-- this will produce the same results
	--COUNT(MONTH(OrderDate)) as OrderQty,	    -- This will produce the same results
FROM 
	Orders
--WHERE OrderDate IS NOT NULL					-- This will produce the same result as the HAVING below
GROUP BY
	FORMAT(OrderDate, 'MMMM'),
	MONTH(OrderDate)
HAVING 
	COUNT(DISTINCT OrderDate) > 0
	--COUNT(MONTH(OrderDate)) > 0				-- This returns the same as above
	--Count(DISTINCT OrderDate) IS NOT NULL		-- This returns a null
	--COUNT(DISTINCT OrderID) IS NOT NULL		-- This returns a Null
Order By
	COUNT(MONTH(OrderDate)) DESC 


--  ********   FORMATTING   ********
--Example:

--SELECT   lastName             AS [Last Name],
--         Count(personID)      AS [Count]
--FROM     Person
--WHERE    lastName LIKE 'M%'
--GROUP BY lastName
--HAVING   [Count]>10
--ORDER BY [Count]



-- *****----  comparing the qyt of monthly orders' average totals versus the orders' sum totals for that month  ----------***********
SELECT 
	'' as [Orders Per Month Averages],
	MONTH(Orders.OrderDate) as OrderMonth,
	-- count(MONTH(Orders.OrderDate)) as OrderQty,		-- This will produce the incorrect results
	count(DISTINCT Orders.OrderID) as OrderQty,
	round(avg([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) as [Order Avg Totals],
	round(sum([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) as [Order Sum Totals]
FROM 
	Orders
Right JOIN
	[Order Details]
ON	
	Orders.OrderID = [Order Details].OrderID
GROUP BY
	MONTH(OrderDate)
HAVING 
	COUNT(MONTH(OrderDate)) >= 1
Order By
	round(avg([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) Desc
	--OPTION (LABEL = 'Orders Per Month Averages')  This hasn't produced a title for me


-- *****----  comparing the qyt of monthly orders' sum totals vs the total amount of the orders' average totals for that month  ----------***********
SELECT 
	'' as [Orders Per Month Sums],
	MONTH(Orders.OrderDate) as OrderMonth,
	count(DISTINCT Orders.OrderID) as OrderQty,
	round(avg([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) as [Order Avg Totals],
	round(sum([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) as [Order Sum Totals]
FROM 
	Orders
JOIN
	[Order Details]
ON	
	Orders.OrderID = [Order Details].OrderID
GROUP BY
	MONTH(OrderDate)
HAVING 
	COUNT(MONTH(OrderDate)) >= 1
Order By
	round(sum([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount)),2) Desc





--Using Northwind
 
-- From the table Products and Categories:


-- ***************________________task 1______________*************************
-- Show the category IDs and names of categories with products ([INNER] JOIN, DISTINCT) 
-- (8 records).

SELECT 
	DISTINCT P.CategoryID,
	C.CategoryName
FROM
	Categories C
JOIN Products P ON C.CategoryID = P.CategoryID 
ORDER BY
	C.CategoryName
		

-- ***************________________task 2______________*************************
-- Show the category IDs, names of categories, and product names for categories with products. 
-- Only include discontinued products with non-zero units in stock. 
-- Order by categories' categoryID ([INNER] JOIN)  
-- (4 records).

SELECT
	P.CategoryID,
	C.CategoryName,
	P.ProductName
FROM
	Categories C--(PK)
	JOIN Products P ON C.CategoryID = P.CategoryID -- (PK = FK)
WHERE
	Discontinued = 1  -- 'True' 
	AND UnitsInStock > 0
ORDER BY
	C.CategoryID


-- ***************________________task 3______________*************************
-- We need a report that tells us everything we need to place an order. 
-- This should be only non-discontinued products whose 
-- (unitsInstock + unitsOnOrder) is less than or equal to the Reorderlevel. 
-- As the final column, it should show how many to order. 
-- We usually order twice the reorderlevel. 
-- Columns should be CategoryID, CategoryName, productID, productName, and amount to order. 
-- Order by CategoryID ([INNER] JOIN) 
-- (2 records).

SELECT
	P.CategoryID,
	C.CategoryName,
	P.ProductID,
	P.ProductName,
	p.ReorderLevel,
	P.ReorderLevel*2 AS AmountToOrder
FROM
	Categories C
	JOIN Products P ON C.CategoryID = P.CategoryID
WHERE 
	P.Discontinued = 0 --'FALSE'
	AND (P.UnitsInStock + P.UnitsOnOrder) <= P.ReorderLevel
ORDER BY
	CategoryID


-- ***************________________task 4______________*************************
-- Do # 4 again, but also add the cost, which will be the order amount multiplied by the unit price 
-- (2 records).

SELECT
	P.CategoryID,
	C.CategoryName,
	P.ProductID,
	P.ProductName,
	P.ReorderLevel*2 AS AmountToOrder,
	P.ReorderLevel*2*P.UnitPrice AS Cost
FROM
	Categories C
	JOIN Products P ON C.CategoryID = P.CategoryID
WHERE
	P.Discontinued = 0 --'False'
	AND (p.UnitsInStock + P.UnitsOnOrder) <= P.ReorderLevel
ORDER BY 
	CategoryID


-- ***************________________task 5______________*************************
-- Show the category IDs and names of categories. 
-- Include categories even if they don't have any products in them (LEFT [OUTER] JOIN, DISTINCT)
-- (10 records).

SELECT
	Distinct P.CategoryID,
	C.CategoryName
FROM
	Categories C
	LEFT JOIN Products P ON C.CategoryID = P.CategoryID
ORDER BY
	CategoryID	


-- ***************________________task 6______________*************************
-- Show the category IDs and names of categories that do not have products in them. (LEFT  [OUTER]  JOIN, WHERE IS NULL) 
-- (2 records).

SELECT
	P.CategoryID,
	C.CategoryName
FROM
	Categories C
	LEFT JOIN Products P ON C.CategoryID = P.CategoryID
WHERE 
	P.CategoryID IS NULL
ORDER BY
	C.CategoryName