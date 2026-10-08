create database retail;
use retail;

create table Customers(
CustomerID int primary key,
CustomerName varchar(50),
City varchar(50),
JoinDate date);

select * from Customers;
desc Customers;

 create table Products(
ProductID int primary key,
ProductName varchar(50),
Category varchar(50),
Price int(10));

select * from Products;
desc Products;

create table Employees(
EmployeeID int primary key,
EmployeeName varchar(50),
Department varchar(50),
HireDate date);

select * from Employees;
desc Employees;

create table Orders(
OrderID int primary key,
CustomerID int(10),
OrderDate Date,
EmployeeID int(10),
foreign key(CustomerID) references Customers(CustomerID),
foreign key(EmployeeID) references Employees(EmployeeID));



select * from Orders;
desc Orders;

create table OrderDetails(
OrderDetailID int primary key,
OrderID int(10),
ProductID int(10),
Quantity int(10),
foreign key(OrderID) references Orders(OrderID),
foreign key(ProductID) references Products(ProductID));


select * from OrderDetails;
desc OrderDetails;


-- inserting data into Customers table
insert into Customers values(101,"Amit Sharma","Delhi","2022-01-10"),
(102,"Neha Varma","Mumbai","2022-03-15"),
(103,"Rahul Mehta","Bangalore","2022-05-01"),
(104,"Priya Singh","Delhi","2023-01-12"),
(105,"Karan Patel","Ahmedabad","2023-02-20"),
(106,"Sneha reddy","Hyderbad","2023-03-18"),
(107,"Arjun Nair","Kochi","2023-04-10"),
(108,"Pooja Gupta","Jaipur","2023-05-05");

select * from Customers;

-- inserting data into Products table
insert into Products values(201,"Laptop","Electronics",55000),
(202,"Mobile","Electronics",25000),
(203,"Tablet","Electronics",18000),
(204,"Headphones","Accessories",2000),
(205,"Keyboard","Accessories",1500),
(206,"Mouse","Accessories",800),
(207,"Monitor","Electronics",12000),
(208,"Printer","Electronics",9000);

select * from Products;


-- inserting data into Employees table
insert into Employees values(401,"Rajesh kumar","Sales","2020-02-01"),
(402,"Meena Iyer","Sales","2021-06-15"),
(403,"Vikram Shah","Sales","2022-09-10"),
(404,"Anil Gupta","Sales","2023-01-05");

select * from Employees;


-- inserting data into Orders table
insert into Orders values(301,101,"2023-01-15",401),
(302,102,"2023-01-18",402),
(303,103,"2023-02-05",401),
(304,104,"2023-02-10",403),
(305,105,"2023-03-01",404),
(306,106,"2023-03-15",402),
(307,107,"2023-04-01",401),
(308,108,"2023-04-20",403);

select * from Orders;


-- inserting data into OrderDetails table
insert into OrderDetails values(1,301,201,1),
(2,301,204,2),
(3,302,202,1),
(4,303,203,1),
(5,304,207,2),
(6,305,205,3),
(7,306,206,5),
(8,307,208,1),
(9,308,201,1);

select * from OrderDetails;



-- Section 1 — Joins (Basic to Intermediate)
-- 	•	Display all orders with customer names.
select c.CustomerName,o.OrderID,o.OrderDate from Customers c join Orders o on c.CustomerID=o.CustomerID;  

-- 	•	Show product names and quantities for each order.
select d.OrderID,p.ProductName,d.Quantity from Products p join OrderDetails d on p.ProductID=d.ProductID;

-- 	•	Display employee name who handled each order.
select o.OrderID,e.EmployeeName from Orders o join Employees e on e.EmployeeID=o.EmployeeID;

-- 	•	Show all customers and their orders (including customers without orders).
select c.CustomerID,c.CustomerName,o.OrderID,o.OrderDate from Customers c left join Orders o on c.CustomerID=o.CustomerID;

-- 	•	Display total number of orders handled by each employee.
select e.EmployeeID,e.EmployeeName,count(o.OrderID) as count from Employees e join Orders o on e.EmployeeID=o.EmployeeID group by e.EmployeeID,e.EmployeeName;


-- Section 2 — Subqueries
-- 	•	Find customers who placed more than 1 order.

select c.CustomerID, c.CustomerName, count(o.OrderID) as order_count
from Customers c join Orders o on c.CustomerID = o.CustomerID
group by c.CustomerID, c.CustomerName having count(o.OrderID) > 1;


-- 	•	Display products with price higher than the average product price.

select * from Products where Price>(select avg(Price) as average_price from Products);

-- 	•	Find the customer who placed the highest number of orders.

select CustomerId,CustomerName,orders from (select c.CustomerID,c.CustomerName,count(distinct o.OrderID) 
as orders from Customers c join Orders o on 
c.CustomerID=o.CustomerID group by c.CustomerID,c.CustomerName)as Customers order by orders desc  limit 1;


-- 	•	Show orders where total quantity is greater than the average quantity.

select OrderID, total_quantity from (select OrderID,sum(Quantity) as total_quantity
from OrderDetails group by OrderID) as order_totals where total_quantity > (
select avg(total_quantity)from(select OrderID,sum(Quantity) as total_quantity
from OrderDetails group by OrderID) as totals);

-- 	•	Find employees who handled more orders than the average employee.

select e.EmployeeID,e.EmployeeName,count(o.OrderID) as order_count 
from Employees e join Orders o 
on e.EmployeeID = o.EmployeeID
group by e.EmployeeID, e.EmployeeName
having order_count > (select avg(order_count)from 
(select COUNT(OrderID) as order_count from Orders group by EmployeeID) as x);

-- Section 3 — Window Functions
-- 	•	Assign rank to customers based on total purchase amount.
-- Use:RANK()
select CustomerID,CustomerName,Total_purchase_amount,rank() over (order by Total_purchase_amount desc) as rank1 from(
select c.CustomerID,c.CustomerName,sum(d.Quantity*p.Price) as Total_purchase_amount 
from Customers c join Orders o on c.CustomerID=o.CustomerID 
join OrderDetails d on o.OrderID=d.OrderID
join Products p on p.ProductID=d.ProductID 
group by  c.CustomerID,c.CustomerName)Customers;


-- 	•	Display cumulative sales amount by order date.
-- Use:SUM() OVER

select OrderDate,sales,sum(sales) over (order by OrderDate) as Cumulative_Sales from (
select o.OrderDate,sum(p.Price*d.Quantity) as sales
from Orders o join OrderDetails d on o.OrderID=d.OrderID 
join Products p on d.ProductID=p.ProductID group by OrderDate)OrderDetails ;

-- 	•	Display running total of sales for each employee.
-- Use:PARTITION BY EmployeeID

select EmployeeID,OrderDate,Total_Sales,sum(total_sales) over 
(partition by EmployeeID order by OrderDate) as Running_sales from(
select e.EmployeeID,o.OrderDate,sum(p.Price*d.Quantity) as Total_sales
from Employees e join Orders o on e.EmployeeID=o.EmployeeID
join OrderDetails d on o.OrderId=d.OrderID
join Products p on p.ProductID=d.ProductID group by e.EmployeeID,o.OrderDate)Employees; 


-- 	•	Find the highest priced product in each category.
--  Use:ROW_NUMBER()
select Category,ProductName, Price from(select category,Productname,Price, row_number() over (partition by category order by Price desc) as num from products) Products where num=1;
