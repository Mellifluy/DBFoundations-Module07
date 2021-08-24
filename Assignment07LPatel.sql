--*************************************************************************--
-- Title: Assignment07
-- Author: Lulu Patel
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-08-23, LPatel,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_LuluPatel')
	 Begin 
	  Alter Database [Assignment07DB_LuluPatel] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_LuluPatel;
	 End
	Create Database Assignment07DB_LuluPatel;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go
Use Assignment07DB_LuluPatel;

-- Create Tables (Module 01)-- 
Create Table CateGories
([CateGoryID] [int] IDENTITY(1,1) NOT NULL 
,[CateGoryName] [nvarchar](100) NOT NULL
);
Go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CateGoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
Go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
Go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
Go

-- Add Constraints (Module 02) -- 
Begin  -- CateGories
	Alter Table CateGories 
	 Add Constraint pkCateGories 
	  Primary Key (CateGoryId);

	Alter Table CateGories 
	 Add Constraint ukCateGories 
	  Unique (CateGoryName);
End
Go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCateGories 
	  Foreign Key (CateGoryId) References CateGories(CateGoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
Go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
Go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
Go

-- Adding Data (Module 04) -- 
Insert Into CateGories 
(CateGoryName)
Select CateGoryName 
 From Northwind.dbo.CateGories
 Order By CateGoryID;
Go

Insert Into Products
(ProductName, CateGoryID, UnitPrice)
Select ProductName,CateGoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
Go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
Go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
Go

-- Adding Views (Module 06) -- 
Create View vCateGories With SchemaBinding
 AS
  Select CateGoryID, CateGoryName From dbo.CateGories;
Go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CateGoryID, UnitPrice From dbo.Products;
Go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
Go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
Go

-- Show the Current data in the CateGories, Products, and Inventories Tables
Select * From vCateGories;
Go
Select * From vProducts;
Go
Select * From vEmployees;
Go
Select * From vInventories;
Go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!
Go
Create or Alter Function dbo.fProductPrice()
    Returns Table  
    As 
        Return(
            Select  ProductName,
   UnitPrice = format(UnitPrice, 'C2')
From Assignment07DB_LuluPatel.dbo.Products);
Go
Select * From dbo.fProductPrice() Order By ProductName;
Go

-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of CateGory and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the CateGory and Product!
Go
Create or Alter Function dbo.fCateGoryProductPrice()
    Returns Table  
    As 
        Return(
            Select  CateGoryName, ProductName,
   UnitPrice = format(UnitPrice, 'C2')
From dbo.Products as p
Join dbo.CateGories as c
On c.CateGoryID = p.CateGoryID
Group by CateGoryName, ProductName, UnitPrice);
Go
Select * From dbo.fCateGoryProductPrice() Order By CateGoryName, ProductName;
Go

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?"                               
-- Order the results by the Product, Date, and Count!   
Go
Create or Alter Function dbo.fProductDateCount()
    Returns Table  
    As 
        Return(
            Select  ProductName, InventoryDate = (DateName(mm, InventoryDate) + ',' + ' ' + CAST(YEAR(InventoryDate) as varchar(4))), COUNT
FROM dbo.Inventories as i
Join dbo.Products as p
On i.ProductID = p.ProductID
Group by ProductName, InventoryDate, Count);
Go

Select * From dbo.fProductDateCount() 
Go

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,             
-- and Count!
Go
Create or Alter View vProductInventories
with SCHEMABINDING
As
Select TOP 10000000000
ProductName, InventoryDate = (DateName(mm, InventoryDate) + ',' + ' ' + CAST(YEAR(InventoryDate) as varchar(4))), Count
    From dbo.Inventories Join dbo.Products
        On Inventories.ProductID = Products.ProductID
    Order BY ProductName, Inventories.InventoryDate, Count
Go

Select * from vProductInventories

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCateGoryInventories 
-- that shows a list of CateGory names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGoRY, with the date FORMATTED like January, 2017?      
Go
Create or Alter View vCateGoryInventories
with SCHEMABINDING
As
Select TOP 1000000000000
CateGoryName, InventoryDate = (DateName(mm, InventoryDate) + ',' + ' ' + CAST(YEAR(InventoryDate) as varchar(4))),
[InventoryCountByCateGory] = SUM(Count)
From dbo.CateGories 
    Join dbo.Products
        On CateGories.CateGoryID = Products.CateGoryID
   Join dbo.Inventories
        On Products.ProductID = Inventories.ProductID
    Group by CateGoryName, InventoryDate
    Order BY CateGoryName, Cast(InventoryDate as datetime)
Go

Select * from vCateGoryInventories

-- Question 6 (10% of pts): -- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product, Date, and Count. 
-- This new view must use your vProductInventories view!

--I first created a view to bring in the product, date, and count columns. That was simple, but the previous month's count stumped me for a while. I added the previous month count
--column with the isnull syntax, but not all the January 2017 counts were zero. I added the IIF syntax to narrow it down to just ones with January and it zeroed out those months.
Go
Create or Alter View vProductInventoriesWithPreviousMonthCounts
with SCHEMABINDING
As
Select TOP 10000000000
ProductName, InventoryDate, InventoryCount = Count, [PreviousMonthCount] = IIF(Month(InventoryDate) = 1, 0, IsNull(Lag(Sum(Count)) Over(Order By ProductName, Month(InventoryDate)), 0))
    From dbo.vProductInventories   
Group By ProductName, InventoryDate, Count
Order By ProductName, Month(InventoryDate), Count
Go

Select * From vProductInventoriesWithPreviousMonthCounts;
Go

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!

Go
Create or Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
with SCHEMABINDING
As
Select TOP 1000000000
ProductName, InventoryDate, InventoryCount, PreviousMonthCount, [CountVsPreviousCountKPI] = Case --Using the example from the Demo, I added the Case syntax comparing current month count and previous month count.
   When InventoryCount > PreviousMonthCount Then 1
   When InventoryCount = PreviousMonthCount Then 0
   When InventoryCount < PreviousMonthCount Then -1
   End
    From dbo.vProductInventoriesWithPreviousMonthCounts  --Using this new view I had created from Question 6.
Order By ProductName, Month(InventoryDate), InventoryCount
Go

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;


-- Question 8 (25% of pts): CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!
Go
Create or Alter Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI int)
    Returns Table  
    As 
        Return(
            Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountVsPreviousCountKPI = @CountVsPreviousCountKPI); -- Created option to specify KPI
Go
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1) 
Go 

Go
Create or Alter Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI int)
    Returns Table  
    As 
        Return(
			Select TOP 1000000000000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs v1
Where CountVsPreviousCountKPI = @CountVsPreviousCountKPI
Order By Year(Cast(v1.InventoryDate as Date)));
Go
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1) 
Go 

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
Go

/***************************************************************************************/