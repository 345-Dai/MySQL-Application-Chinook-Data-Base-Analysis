/**********************************************************************************************************/
/******************************************((  Aya El Hassany ))******************************************/
/******************************************((sales performance))******************************************/

use chinook;
/*is sales generally increasing by year?*/
SELECT YEAR(InvoiceDate) AS Year,
    SUM(Total) AS TotalSales
FROM Invoice
GROUP BY YEAR(InvoiceDate)
ORDER BY Year;

/*sales by quarter*/
SELECT YEAR(InvoiceDate) AS Year,
    QUARTER(InvoiceDate) AS Quarter,
    SUM(Total) AS TotalSales
FROM Invoice
GROUP BY 
    YEAR(InvoiceDate),
    QUARTER(InvoiceDate)
ORDER BY year, Quarter;

/*sales by country*/
SELECT BillingCountry AS Country,
    SUM(Total) AS TotalSales
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalSales;
/*average total price by invoice*/
SELECT 
    AVG(Total) AS AverageInvoiceTotal
FROM Invoice;

/*top revenue generator tracks price*/
SELECT Track.TrackId,
    Track.Name AS TrackName,
    SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS Revenue
FROM InvoiceLine
JOIN Track 
    ON InvoiceLine.TrackId = Track.TrackId
GROUP BY  Track.TrackId, Track.Name
ORDER BY Revenue desc
limit 10 ;

/*lowest revenue generator tracks price*/
SELECT Track.TrackId,
    Track.Name AS TrackName,
    SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS Revenue
FROM InvoiceLine
JOIN Track 
    ON InvoiceLine.TrackId = Track.TrackId
GROUP BY  Track.TrackId, Track.Name
ORDER BY Revenue
limit 10 ;

/*is there any track that has never been selled*/
SELECT Track.TrackId,
    Track.Name AS TrackName
FROM Track
LEFT JOIN InvoiceLine 
    ON Track.TrackId = InvoiceLine.TrackId
WHERE InvoiceLine.TrackId IS NULL;
/***********************************************************************************************************/
/******************************************((  Dai El Ashry ))*********************************************/
/******************************************((Customer_Behaviour))******************************************/

/*1 Number of Customers per Country*/
select Country , COUNT(CustomerId) As NumberOfCustomers
From customer 
Group by Country
Order by 2 desc; 
/*Magority of customers are located in USA by 13 followed by canada 8 ,  Brazil and france : 5
,Germany : 4 , United Kinggom 3 ,Czech Republic &Portugal & India : 2 , and each remaining country only 1 customer */


/*2.Define VIP Customers and their country(Highest sales and orders):*/

create VIEW Top_10_Spending_Customers
AS
select c.CustomerId, concat(c.FirstName, ' ', c.LastName) as Full_Name
, sum(I.Total) AS Total_Spent 
,count(I.InvoiceId) as Total_Orders
From customer c Inner Join invoice I 
ON c.CustomerId = I.CustomerId 
group by 1,2
Order by 3 Desc 
LIMIT 10;



select * from Top_10_Spending_Customers
/*In Which Country do they live ?*/
select top.CustomerId , top.Full_Name , c.Country,top.Total_Spent,top.Total_Orders
from Top_10_Spending_Customers top inner join customer c 
on top.CustomerId = c.CustomerId
group by 1,2
 
/*3.Which tracks do the VIP customers buy ?
Track Name , Number of orders,Quantity*/
 
 select concat(c.FirstName, ' ', c.LastName)  as Customer_Name  
 , G.Name as Genre
 , sum(il.Quantity) as Total_Quantity 
 From customer c 
 Inner Join Top_10_Spending_Customers top 
 On c.CustomerId = top.CustomerId 
 Inner Join invoice I 
 on c.CustomerId = I.CustomerId
 Inner Join invoiceline il
 ON I.InvoiceId =il.InvoiceId 
 Inner Join track T
 On il.TrackId = T.TrackId
 Inner join genre G
 on T.GenreId = G.GenreId
 Group by 1 ,2 
 order by 1,3 desc ;
 

/*4.Determine Best Seller Tracks and Genre among
customers*/
Select T.Name as Track , G.Name as Genre 
,sum(IL.Quantity)as Total_Quantity
from invoiceline IL inner join track T
ON IL.TrackId = T.TrackId 
inner join genre G 
ON T.GenreId = G.GenreId
group by 1,2
order by Total_Quantity desc
Limit 10

/*5.Determine the most popular genre by country
Country, Higest Ordered Genre
Requirements : Get The Customer Country , Genre Name The total Quantity Sold 
- Then Rank The Genre of Each country by The Highest Genre by Quantity 
- Last :We will call the hiest rank of genre by Country  */

WITH GenreCounts AS (
      Select c.Country , g.Name AS Genre , sum(il.Quantity) AS Total_Purchased
      From customer c Inner Join invoice i on c.CustomerId = i.CustomerId
      Inner join invoiceline il  on i.InvoiceId = il.InvoiceId
	  Inner join track t on il.TrackId = t.TrackId 
      Inner join genre G on t.GenreId = G.GenreId
      group by c.Country ,g.Name 
      ) ,
	 Genre_Rank AS (
	   select Country , Genre ,Total_Purchased 
	   ,Rank() over (partition by Country order by Total_Purchased desc) AS Rnk
	   From GenreCounts
     )

Select Country , Genre ,Total_Purchased 
From Genre_Rank
where Rnk =1


/*6-Determine Slow mover Tracks and their genre .*/
Select T.Name as Track , G.Name as Genre 
,sum(IL.Quantity)as Total_Quantity
from invoiceline IL inner join track T
ON IL.TrackId = T.TrackId 
inner join genre G 
ON T.GenreId = G.GenreId
group by 1,2
order by Total_Quantity asc
Limit 10


/*7.Orders by Quarter (Seasonal Trend of orders)*/
select year(InvoiceDate) as 'Year',quarter(InvoiceDate) as 'Quarter', Count(InvoiceId) as Total_Orders,sum(Total) as SalesValue
from invoice
group by 1 ,2


/*8.Average number of tracks per Order.*/
Select avg(Track_Counts) as Average_Tracks_Per_Order
from (Select count(TrackId) as Track_Counts 
       From invoiceline
       group by InvoiceId) as Order_Counts


/*****************************************************************************************************************/
/******************************************((Employee Performance))******************************************/
/*- How are the customers distributed among Sales support Agents ?*/
/*Determine the Support Agent whose customers made the highest number of orders .*/
/*- Who is the best Support Agent based on sales generated by their customers*/
SELECT 
    CONCAT(e.FirstName ,' ' , e.LastName) AS EmployeeName,
    COUNT(DISTINCT c.CustomerId) AS NumberOfCustomers,
    COUNT(i.InvoiceId) AS TotalOrders,
    ROUND(SUM(i.Total), 2) AS TotalSalesValue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId
ORDER BY TotalSalesValue DESC;
/*****************************************************************************************************************/
/*Appendix*/
/*Number Of Customers*/
Select count(CustomerId) as Number_Of_Customers From customer
/*59*/
/*Orders*/
Select Count(InvoiceId) N_Orders
from invoice
/*412 orders*/
select sum(Quantity) 
from invoiceline
/*2240 units*/
