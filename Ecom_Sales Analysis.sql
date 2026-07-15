CREATE DATABASE Ecom_db;
USE Ecom_db;

/*==========================================================
    PROJECT : E-COMMERCE DATA ANALYST PROJECT
    DATABASE: Microsoft SQL Server
==========================================================*/

/*==========================================================
                    CUSTOMERS
==========================================================*/

CREATE TABLE Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode VARCHAR(15) NOT NULL UNIQUE,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male','Female','Other')),
    DateOfBirth DATE,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50) DEFAULT 'India',
    PostalCode VARCHAR(10),
    RegistrationDate DATE DEFAULT GETDATE(),
    CustomerStatus VARCHAR(20) DEFAULT 'Active'
);

GO

/*==========================================================
                    CATEGORIES
==========================================================*/

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255),
    CreatedDate DATE DEFAULT GETDATE()
);

GO

/*==========================================================
                    BRANDS
==========================================================*/

CREATE TABLE Brands
(
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName VARCHAR(100) NOT NULL UNIQUE,
    Country VARCHAR(50),
    FoundedYear SMALLINT,
    BrandStatus VARCHAR(20) DEFAULT 'Active'
);

GO

/*==========================================================
                    SUPPLIERS
==========================================================*/

CREATE TABLE Suppliers
(
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(150) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    SupplierRating DECIMAL(3,2),
    IsActive BIT DEFAULT 1
);

GO

/*==========================================================
                    WAREHOUSES
==========================================================*/

CREATE TABLE Warehouses
(
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    State VARCHAR(50),
    Capacity INT,
    ManagerName VARCHAR(100)
);

GO

/*==========================================================
                    PRODUCTS
==========================================================*/

CREATE TABLE Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(20) NOT NULL UNIQUE,
    ProductName VARCHAR(200) NOT NULL,

    CategoryID INT NOT NULL,
    BrandID INT NOT NULL,
    SupplierID INT NOT NULL,

    CostPrice DECIMAL(10,2) NOT NULL,
    SellingPrice DECIMAL(10,2) NOT NULL,

    StockQuantity INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,

    Weight DECIMAL(8,2),
    Color VARCHAR(50),
    WarrantyMonths INT,

    LaunchDate DATE,
    ProductStatus VARCHAR(20) DEFAULT 'Active',

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY(CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Brands
        FOREIGN KEY(BrandID)
        REFERENCES Brands(BrandID),

    CONSTRAINT FK_Products_Suppliers
        FOREIGN KEY(SupplierID)
        REFERENCES Suppliers(SupplierID)
);

GO

/*==========================================================
                    ORDERS
==========================================================*/

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber VARCHAR(20) UNIQUE,

    CustomerID INT NOT NULL,
    WarehouseID INT NOT NULL,

    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATETIME,

    OrderStatus VARCHAR(30),

    TotalAmount DECIMAL(12,2),
    DiscountAmount DECIMAL(10,2),
    TaxAmount DECIMAL(10,2),
    ShippingCharge DECIMAL(10,2),
    NetAmount DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY(CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Orders_Warehouses
        FOREIGN KEY(WarehouseID)
        REFERENCES Warehouses(WarehouseID)
);

GO

/*==========================================================
                ORDER DETAILS
==========================================================*/

CREATE TABLE OrderDetails
(
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL,
    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(10,2),

    DiscountPercent DECIMAL(5,2),

    DiscountAmount DECIMAL(10,2),

    LineTotal DECIMAL(12,2),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY(ProductID)
        REFERENCES Products(ProductID)
);

GO

/*==========================================================
                    PAYMENTS
==========================================================*/

CREATE TABLE Payments
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL UNIQUE,

    PaymentMethod VARCHAR(30),

    PaymentStatus VARCHAR(20),

    PaymentDate DATETIME,

    TransactionID VARCHAR(100) UNIQUE,

    AmountPaid DECIMAL(12,2),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID)
);

GO

/*==========================================================
                    SHIPPING
==========================================================*/

CREATE TABLE Shipping
(
    ShippingID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL UNIQUE,

    CourierName VARCHAR(100),

    TrackingNumber VARCHAR(100) UNIQUE,

    ShipDate DATETIME,

    EstimatedDelivery DATETIME,

    DeliveryDate DATETIME,

    ShippingStatus VARCHAR(30),

    CONSTRAINT FK_Shipping_Orders
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID)
);

GO

/*==========================================================
                    RETURNS
==========================================================*/

CREATE TABLE Returns
(
    ReturnID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL,

    ReturnDate DATE,

    ReturnReason VARCHAR(200),

    RefundAmount DECIMAL(12,2),

    RefundStatus VARCHAR(20),

    CONSTRAINT FK_Returns_Orders
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID)
);

GO

CREATE TABLE Inventory
(
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    CurrentStock INT NOT NULL,
    ReservedStock INT DEFAULT 0,
    ReorderLevel INT NOT NULL,
    LastRestockDate DATE,
    InventoryStatus VARCHAR(20),

    CONSTRAINT FK_Inventory_Product
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_Inventory_Warehouse
        FOREIGN KEY (WarehouseID)
        REFERENCES Warehouses(WarehouseID)
);



select * from Brands;
select * from Categories;
select * from Customers;
select * from Inventory;
select * from OrderDetails;
select * from Orders;
select * from Payments;
select * from Products;
select * from Returns;
select * from Shipping;
select * from Suppliers;
select * from Warehouses;
--Which products generate the highest revenue?

select 
top 1
p.ProductID,
p.ProductName,
sum(od.Quantity) as Total_Qty,
sum(od.revenue) as Total_rev
from Products as p
inner join 
OrderDetails as od
on p.ProductID = od.ProductID
group by p.ProductID, p.ProductName
Order by Total_rev desc

--Which products sell the highest quantity?

select Top 1 
p.ProductId,
p.productName,
sum(od.Quantity) as Total_Qty
from Products as p
inner join
OrderDetails as od
on p.ProductID = od.ProductID
group by p.ProductId,
p.productName
order by total_qty desc

--Which categories contribute the most revenue?

select Top 1
c.CategoryID,
c.CategoryName,
sum(od.revenue) as Total_rev
from Categories as c
inner join 
products as p
on c.categoryID = p.categoryID
inner join
orderdetails as od 
on p.productID = od.productID
group by c.CategoryID,
c.CategoryName
order by Total_rev desc

--Which brands generate the highest sales?

select Top 1
b.BrandID,
b.BrandName,
sum(od.Quantity) as Total_Qty
from Brands as b
inner join Products as p
on b.BrandID = p.BrandID
inner join orderDetails as od
on p.productID = od.productID
group by b.BrandID,
b.BrandName
order by Total_Qty

--Which suppliers contribute the highest sales?

select Top 1
s.SupplierID,
s.SupplierName,
sum(od.Quantity) as Total_sales
from Suppliers as s
inner join Products as p
on s.SupplierID = p.SupplierID
inner join 
OrderDetails as od
on p.productID = od.ProductID
group by s.SupplierID,
s.SupplierName
order by Total_sales

--Which warehouse processes the highest sales?

select Top 1
w.WarehouseID,
w.WarehouseName,
sum(od.Quantity) as Total_Sales
from Warehouses as w
inner join
Orders as o
on w.WarehouseID = o.WarehouseID
inner join 
OrderDetails  as od 
on o.orderID = od.Quantity
group by w.WarehouseID,
w.WarehouseName
order by Total_Sales

--Which cities generate the highest revenue?

select Top 1
c.city,
c.state,
sum(od.Quantity) as Total_Qty
from Customers as c
inner join Orders as o
on c.CustomerID = o.CustomerID
inner join OrderDetails as od
on o.OrderID = od.OrderID
group by c.city,
c.state
order by Total_Qty desc

--Which customers contribute the most revenue?

select Top 10
c.FirstName,
c.LastName,
sum(od.quantity) as Total_Sales,
sum(od.Revenue) as Total_Rev
from Customers as c
inner join 
Orders as o
on c.CustomerID=o.CustomerID
inner join 
OrderDetails as od 
on o.OrderID = od.OrderID
group by c.FirstName,
c.LastName
order by Total_Sales

--Which products have never been sold?

select 
p.productName,
p.productID,
sum(od.quantity) as Total_sal
from Products as p
inner join 
OrderDetails as od
on p.ProductID = od.ProductID
group by p.ProductName,
p.ProductID
having sum(od.Quantity)=0
order by Total_sal desc

--Which products are out of stock?

select * from Inventory
where InventoryStatus = 'out of stock'

--Which products are below the reorder level ?

select 
i.inventoryID,
i.ReorderLevel,
i.CurrentStock,
p.productName,
p.productID
from Inventory as i
inner join 
Products as p
on i.ProductID = p.ProductID
where i.ReorderLevel>i.CurrentStock

--Which warehouse has the highest stock?

select Top 1
w.warehouseID,
w.warehousename,
w.managerName,
i.inventoryID,
i.currentStock as current_stock
from Warehouses as w
inner join 
inventory as i
on w.WarehouseID = i.WarehouseID
order by current_stock desc

--Which warehouse has the lowest stock?

select Top 1
w.warehouseID,
w.warehousename,
w.managerName,
i.inventoryID,
i.currentStock as current_stock
from Warehouses as w
inner join 
inventory as i
on w.WarehouseID = i.WarehouseID
order by current_stock asc

--Which products have excess inventory?

select Top 10 
p.Productname,
i.ProductID,
i.CurrentStock,
i.ReorderLevel,
(i.CurrentStock - i.ReorderLevel) as Excess_Stock
from Inventory as i
inner join 
products as p
on i.ProductID = p.ProductID
where i.CurrentStock > (i.ReorderLevel *2)
order by Excess_Stock desc

--Which products should be reordered immediately?

select * from Inventory
where InventoryStatus = 'out of stock';

--Which categories have the highest inventory value?

select c.CategoryID,
c.CategoryName,
P.ProductID,
p.ProductName,
i.CurrentStock as CurrentStock
from Categories as c
inner join 
Products as p
on c.CategoryID = p.CategoryID
inner join 
Inventory as i
on p.ProductID = i.ProductID
order by CurrentStock desc

--What is the total inventory value?

select 
sum(i.CurrentStock * p.sellingPrice) as Total_value
from Inventory as i
inner join 
Products as p
on i.ProductID = p.ProductID

--Which supplier's products remain unsold?

select S.SupplierName,
S.SupplierID,
p.ProductName,
p.ProductID,
i.CurrentStock
from suppliers as S
inner join 
Products as p
on 
s.supplierID = p.SupplierID
inner join 
inventory as i 
on p.productID = i.productID
order by i.CurrentStock desc


--Which warehouse needs replenishment first?

select Top 1
i.CurrentStock,
i.ReorderLevel,
i.inventoryStatus,
w.WarehouseID,
w.WarehouseName
from inventory as i 
inner join Warehouses AS W
on i.WarehouseID = w.WarehouseID
where i.CurrentStock < i.ReorderLevel
order by i.CurrentStock asc

--Which courier delivers the fastest?

select CourierName,
avg(DATEDIFF(day,ShipDate, EstimatedDelivery)) as Avg_Days
from Shipping
where DeliveryDate is not null
group by CourierName
order by Avg_days asc

--Which courier delivers the slowest?

select CourierName,
avg(DATEDIFF(day,ShipDate, EstimatedDelivery)) as Avg_Days
from Shipping
where DeliveryDate is not null
group by CourierName
order by Avg_days Desc

--Average delivery time by courier.

select CourierName,
    count(OrderID) as Total_Order,
    avg(datediff(day, shipDate,DeliveryDate)) as Avg_days
from Shipping
where DeliveryDate is not null
group by CourierName
order by Avg_days asc


--Which warehouse has the most delayed deliveries?

SELECT
    w.WarehouseID,
    w.WarehouseName,
    COUNT(*) AS DelayedOrders
FROM Warehouses AS w
INNER JOIN Orders AS o
    ON w.WarehouseID = o.WarehouseID
INNER JOIN Shipping AS s
    ON o.OrderID = s.OrderID
WHERE DATEDIFF(DAY, s.ShipDate, s.DeliveryDate) > 5
GROUP BY
    w.WarehouseID,
    w.WarehouseName
ORDER BY
    DelayedOrders DESC

--What percentage of orders are delivered on time?

SELECT
    COUNT(CASE WHEN ShippingStatus = 'Delivered' THEN 1 END) * 100.0
        / COUNT(*) AS OnTimeDeliveryPercentage
FROM Shipping;

--Which shipping routes experience delays?

select 
    w.city as Source_city,
    c.city as Destination_city,
    count(o.orderID) as Total_order,
    round(avg(datediff(day, s.ShipDate, s.DeliveryDate)),2) as Avg_days
from Shipping as s
inner join 
    Orders as o
    on s.OrderID = o.OrderID
inner join
    Warehouses as w
    on o.WarehouseID = w.WarehouseID
inner join
    Customers as c
    on o.CustomerID = c.CustomerID
where DeliveryDate is not null
group by
    w.City,
    c.city
order by
    Avg_days desc

--Which city has the highest delivery delays?
   
select 
    c.city as Destination_city,
    count(o.orderID) as Total_order,
    round(avg(datediff(day, s.ShipDate, s.DeliveryDate)),2) as Avg_days
from Shipping as s
inner join 
    Orders as o
    on s.OrderID = o.OrderID
inner join
    Customers as c
    on o.CustomerID = c.CustomerID
where DeliveryDate is not null
group by
    c.city
order by
    Avg_days desc

--Average shipping cost by warehouse?

select 
    avg(s.ShippingCost) as Avg_Cost,
    w.WarehouseName
from Shipping as s
inner join
    Orders as o
    on s.OrderID = o.OrderID
inner join
    Warehouses as w
    on o.WarehouseID = w.WarehouseID
group by
    w.WarehouseName
order by
    Avg_Cost desc;

--Which courier has the highest return rate?            

SELECT
    s.CourierName,
    COUNT(r.ReturnID) AS TotalReturns,
    COUNT(DISTINCT s.OrderID) AS TotalDeliveredOrders,
    ROUND(
        COUNT(r.ReturnID) * 100.0 /
        COUNT(DISTINCT s.OrderID),
        2
    ) AS ReturnRate
FROM Shipping AS s
LEFT JOIN Returns AS r
    ON s.OrderID = r.OrderID
GROUP BY
    s.CourierName
ORDER BY
    ReturnRate DESC;

--Which warehouse has the highest shipping cost?

select Top 10
    w.WarehouseName,
    s.ShippingCost
from Shipping as s
inner join
    Orders as o
    on s.OrderID = o.OrderID
inner join
    Warehouses as w
    on o.WarehouseID = w.WarehouseID
order by
    s.ShippingCost desc

--Which payment method is most popular?

select Top 1
    PaymentMethod,
    count(OrderID) as Total_Trs
from Payments
group by
    PaymentMethod
order by   
    Total_Trs desc

--Payment success rate.

SELECT
    COUNT(CASE WHEN PaymentStatus = 'Paid' THEN 1 END) AS SuccessfulPayments,
    COUNT(*) AS TotalPayments,
    ROUND(
        COUNT(CASE WHEN PaymentStatus = 'Paid' THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS PaymentSuccessRate
FROM Payments;

--Payment failure rate.

SELECT
    COUNT(CASE WHEN PaymentStatus = 'Failed' THEN 1 END) AS SuccessfulPayments,
    COUNT(*) AS TotalPayments,
    ROUND(
        COUNT(CASE WHEN PaymentStatus = 'Failed' THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS PaymentSuccessRate
FROM Payments;

--Total discounts given.

select 
    ProductID,
    sum(DiscountAmount) as Total_Disc
from OrderDetails
group by 
    ProductID

--Total shipping charges collected.

select 
    CourierName,
    sum(ShippingCost) as Total_ship_cost
from Shipping
group by
    CourierName
order by
    Total_ship_cost desc

--Total tax collected.

select 
    p.ProductName,
    sum(Revenue)  * 18/100 as Total_tax
    from Products as p
inner join
    OrderDetails as o
    on p.productID = o.productID
group by
    p.ProductName
order by
    Total_tax
    
--Net revenue after discounts.?


select (Revenue - DiscountAmount) as Revenue_after_Tax
from OrderDetails

--Revenue by payment method.?

select 
    p.PaymentMethod,
    sum(o.Revenue) as Total_revby_Pay_met
from Payments as p
inner join
    OrderDetails as o
    on p.OrderID = o.OrderID
group by
    p.PaymentMethod
order by
    Total_revby_Pay_met desc

--Revenue by payment method.

select 
    p.PaymentMethod,
    avg(o.Revenue) as Total_revby_Pay_met
from Payments as p
inner join
    OrderDetails as o
    on p.OrderID = o.OrderID
group by
    p.PaymentMethod
order by
    Total_revby_Pay_met desc

--Refund amount by month.

select 
    year(ReturnDate) as Return_Year,
    month(ReturnDate) as Return_Month,
    datename(MONTH, ReturnDate) as MonthName,
    sum(RefundAmount) as Total_Refund_Amt
from Returns
group by
    year(ReturnDate),
    month(ReturnDate),
    datename(month,ReturnDate)
order by
    Return_Year,
    Return_Month

--Who are our top 20 customers?

select Top 20
    c.FirstName,
    c.LastName,
    concat(c.Firstname,' ',c.lastName) as Customer_Name,
    sum(od.Revenue) as Total_rev
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join 
    OrderDetails as od
    on o.OrderID = od.OrderID
group by
    c.FirstName,
    c.LastName
order by 
    Total_rev desc

--Which customers haven't ordered in the last 6 months?

select * from Customers
select
    c.CustomerID,
    c.Email,
    c.Phone,
    concat(c.FirstName,' ',C.LastName) as CustomerName,
    max(o.OrderDate) AS LastOrderDate
from Customers AS c
left join
    Orders as o
    on c.CustomerID = o.CustomerID
group by
    C.FirstName,
    c.LastName,
    c.CustomerID,
    c.Phone,
    c.email
having 
    max(o.OrderDate) < dateadd(month, -6,getdate())
order by
    LastOrderDate
   
--Repeat VS new Customer

select
    case
        when OrderCount = 1 then 'New Customer'
        else 'Repeat Customer'
    end as CustomerType,
    count(*) as TotalCustomers
from
(
    select
        CustomerID,
        count(OrderID) AS OrderCount
    from Orders
group by
    CustomerID
) as CustomerOrders
group by
    case
        when OrderCount = 1 then 'New Customer'
        else 'Repeat Customer'
    end

--Customer lifetime value (CLV).

select 
    c.CustomerID,
    concat(c.FirstName,' ',c.LastName) as CustomerName,
    count(o.OrderID) as Total_order,
    sum(od.Revenue) as Customer_CLV
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join
    OrderDetails as od
    on o.OrderID = od.OrderID
group by
    c.CustomerID,
    c.FirstName,
    c.LastName
order by
    Customer_CLV desc

--Average orders per customer.

select 
    c.CustomerID,
    concat(c.FirstName,' ',c.LastName) as CustomerName,
    count(o.OrderID) as Total_Order
from Customers as c
left join 
    Orders as o
    on c.CustomerID = o.CustomerID
group by 
    c.FirstName,
    c.LastName,
    c.CustomerID
order by
    Total_Order desc

--Which city has the most loyal customers?

select top 1
    c.city,
    count(o.OrderID) as Total_Order
from Customers as c
left join
    Orders as o
    on c.CustomerID = o.CustomerID
group by
    c.City
order by
    Total_Order desc

--Which customers frequently return products?

select
    c.CustomerID,
    concat(c.FirstName,' ',c.LastName) as Customer_Name,
    count(r.OrderID) as Total_Order
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join
    Returns as r
    on o.OrderID = r.OrderID
group by 
    c.CustomerID,
    c.FirstName,
    c.LastName
order by
    Total_Order desc

--Which age group spends the most?

select 
    case
    when datediff(year,DateOfBirth,getdate()) between 18 and 24 then '18-24'
    when datediff(year,DateOfBirth,getdate()) between 25 and 35 then '25-35'
    when datediff(year,DateOfBirth,getdate()) between 36 and 45 then '36-45'
    when datediff(year,DateOfBirth,getdate()) between 46 and 55 then '46-55'
    else '56+'
end as AgeGroup,
count(Distinct c.CustomerID) as Total_customer,
count(distinct o.OrderID) as Total_Order,
sum(od.Revenue) as Total_Spending
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join
    OrderDetails as od
    on o.OrderID = od.OrderID
group by
    case
    when datediff(year,DateOfBirth,getdate()) between 18 and 24 then '18-24'
    when datediff(year,DateOfBirth,getdate()) between 25 and 35 then '25-35'
    when datediff(year,DateOfBirth,getdate()) between 36 and 45 then '36-45'
    when datediff(year,DateOfBirth,getdate()) between 46 and 55 then '46-55'
    else '56+'
end
order by
    Total_Spending desc
   
--Which gender spends more?

select 
    c.Gender,
    sum(od.Revenue) as Total_Spending
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join
    OrderDetails as od
    on o.OrderID = od.OrderID
group by 
    c.Gender
order by
    Total_Spending desc

--Which products are returned the most?

select 
    p.ProductName,
    sum(r.RefundAmount) as Total_Ref_Amt
from Products as p
inner join
    OrderDetails as o
    on p.ProductID = o.ProductID
inner join
    Returns as r
    on o.OrderID = r.OrderID
group by
    p.ProductName
order by
    Total_Ref_Amt desc

    
--Which category has the highest return rate?
    
select 
    c.CategoryName,
    count(distinct o.OrderID) as Total_Order,
    count(distinct r.OrderID) as Total_ret_ord,
    round(
    count(distinct r.OrderID) *100.0 /
    count(distinct o.OrderID),2) as Return_rate
from Categories as c
inner join 
    Products as p
    on c.CategoryID = p.CategoryID
inner join
    OrderDetails as o
    on p.ProductID = o.ProductID
left join
    Returns as r
    on o.OrderID = r.OrderID
group by
    c.CategoryID,
    c.CategoryName
order by
    Return_rate Desc

--Which supplier has the highest return rate?

select 
    s.SupplierName,
    count(distinct o.OrderID) as Total_order,
    count(distinct r.OrderID) as Total_Ret_Order,
    round(count(distinct r.OrderID) * 100/
    count(distinct o.OrderID),2) as Return_Rate
from Suppliers as s
inner join
    Products as p
    on s.SupplierID = p.SupplierID
inner join
    OrderDetails as o
    on p.ProductID = o.ProductID
left join
    Returns as r
    on o.OrderID = r.OrderID
group by
    s.SupplierName
order by
    Return_Rate

--Which brand has the highest return rate?

select 
    b.BrandName,
    count(distinct o.OrderID) as Total_order,
    count(distinct r.OrderID) as Total_Ret_Order,
    round(count(distinct r.OrderID) * 100/
    count(distinct o.OrderID),2) as Return_Rate
from Brands as b
inner join
    Products as p
    on b.BrandID = p.BrandID
inner join
    OrderDetails as o
    on p.ProductID = o.ProductID
left join
    Returns as r
    on o.OrderID = r.OrderID
group by
    b.BrandName
order by
    Return_Rate

--Most common return reason.?

select * from Returns
select top 1
    ReturnReason,
    count(*) as TotalReason
from Returns
group by
    ReturnReason
order by   
    TotalReason desc

--Return rate by warehouse.

select 
    w.WarehouseName,
    count(distinct o.OrderID) as Total_Orders,
    count(distinct r.OrderID) as Total_Ret_Orders,
    round( count(distinct r.OrderID) * 100.0 /
    count(distinct o.OrderID),2) as Return_Rate
from Warehouses as w
inner join
    Orders as o
    on w.WarehouseID = o.WarehouseID
left join
    Returns as r
    on o.OrderID = r.OrderID
group by
    w.WarehouseName
order by
    Return_Rate desc

--Return rate by courier.

select 
    s.Couriername,
    count(distinct s.OrderID) as Total_Orders,
    count(distinct r.OrderID) as Total_Ret_Orders,
    round( count(distinct r.OrderID) * 100.0 /
    count(distinct s.OrderID),2) as Return_Rate
from Shipping as s
left join
    Returns as r
    on s.OrderID = r.OrderID
group by
    s.CourierName
order by
    Return_Rate desc

--Which category has the fastest growth?

with MonthlySales as
(
    select 
        c.CategoryName,
        year(o.OrderDate) as OrderYear,
        month(o.OrderDate) as OrderMonth,
        sum(od.Revenue) as Revenue
    from Categories c
    join Products p
        on c.CategoryID = p.CategoryID
    join OrderDetails od
        on p.ProductID = od.ProductID
    join Orders o
        on od.OrderID = o.OrderID
    group by
        c.CategoryName,
        year(o.OrderDate),
        month(o.OrderDate)
),
Growth as
(
    select
        CategoryName,
        OrderYear,
        OrderMonth,
        Revenue,
        round(
            (
                Revenue -
                lag(Revenue) over
                (
                    partition by CategoryName
                    order by OrderYear, OrderMonth
                )
            ) * 100.0
            /
            nullif(
                lag(Revenue) over
                (
                    partition by CategoryName
                    order by OrderYear, OrderMonth
                ),
                0
            ),
            2
        ) as GrowthPercentage
    from monthlySales
)

select Top 1 *
from Growth
where  
    GrowthPercentage is not null
order by
    GrowthPercentage desc

--Which products should be promoted?

select Top 1
    p.ProductName,
    sum(od.Quantity) as Total_qty,
    sum(Revenue) as Total_rev
from Products as p
inner join
    OrderDetails as od
    on p.ProductID = od.ProductID
group by
    P.ProductName
order by
    Total_rev desc

--Which payment method is preferred by premium customers?

select 
    PaymentMethod,
    sum(AmountPaid) as Total_spending
from Payments
group by
    PaymentMethod
order by
    Total_spending desc

--Which city should receive more marketing budget?

select 
    c.City,
    count(c.CustomerID) as Total_Customer,
    count(o.OrderID) as Total_Order,
    sum(od.Revenue) as Total_rev,
    avg(od.Revenue) as Avg_Rev
from Customers as c
inner join
    Orders as o
    on c.CustomerID = o.CustomerID
inner join
    OrderDetails as od
    on o.OrderID = od.OrderID
group by
    c.City
order by
    Total_rev desc

--Which categories have declining sales?

with MonthlySales as
(
    select
        c.CategoryName,
        year(o.OrderDate) as SalesYear,
        month(o.OrderDate) as SalesMonth,
        sum(od.Revenue) AS Revenue
    from Categories as c
    inner join Products as p
        on c.CategoryID = p.CategoryID
    inner join OrderDetails as od
        on p.ProductID = od.ProductID
    inner join Orders as o
        on od.OrderID = o.OrderID
    group by
        c.CategoryName,
        year(o.OrderDate),
        month(o.OrderDate)
),

SalesTrend as
(
    select 
        CategoryName,
        SalesYear,
        SalesMonth,
        Revenue,
        lag(Revenue) over
        (
            partition by CategoryName
            order by SalesYear, SalesMonth
        ) as PreviousRevenue
    from MonthlySales
)

select
    CategoryName,
    SalesYear,
    SalesMonth,
    PreviousRevenue,
    Revenue,

    round(
        ((Revenue - PreviousRevenue) * 100.0) /
        nullif(PreviousRevenue,0),
        2
    ) as GrowthPercentage

from SalesTrend

where Revenue < PreviousRevenue

order by
    GrowthPercentage

--Which brands need promotions?

select 
    b.BrandName,
    count(distinct p.ProductID) as Total_Products,
    sum(i.currentStock) as Total_inventory,
    isnull(sum(od.Quantity),0) as Total_qty_Sold,
    isnull(sum(od.Revenue),0) as Total_rev
from Brands as b
inner join
    Products as p
    on b.BrandID = p.BrandID
inner join
    Inventory as i
    on p.ProductID = i.ProductID
left join
    OrderDetails as od
    on p.ProductID = od.ProductID
group by
    b.BrandName
order by
    Total_qty_Sold asc,
    Total_rev asc,
    Total_inventory desc

--Which products generate the highest profit?

select 
    p.Productname,
    sum(od.Revenue) as Total_Profit
from Products as p
inner join
    OrderDetails as od
    on p.ProductID = od.ProductID
group by
    p.ProductName
order by
    Total_Profit desc

--Which products have declining sales?

select
    p.ProductID,
    p.ProductName,
    year(o.OrderDate) as SalesYear,
    month(o.OrderDate) as SalesMonth,
    sum(od.Revenue) as TotalRevenue,
    sum(od.Quantity) as TotalSale
from Products as p
inner join OrderDetails as od
    on p.ProductID = od.ProductID
inner join Orders as o
    on od.OrderID = o.OrderID
group by
    p.ProductID,
    p.ProductName,
    year(o.OrderDate),
    month(o.OrderDate)
order by
    p.ProductName,
    SalesYear,
    SalesMonth;

--Which categories have the highest ASP?

select 
    c.CategoryName,
    sum(od.Revenue) as Total_Rev,
    sum(od.quantity) as Total_sale,
    round(sum(od.Revenue) *1/sum(od.quantity),2) as Avg_Selling_price
from Categories as c
inner join
    Products as p
    on c.CategoryID = p.ProductID
inner join
    OrderDetails as od
    on p.ProductID = od.ProductID
group by
    c.CategoryName
order by
    Avg_Selling_price desc
    


