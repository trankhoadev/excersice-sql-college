USE [AdventureWorks2008R2]
GO
--1)	Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có tổng tiền >70000, thông tin gồm SalesOrderID,
		Orderdate, SubTotal, trong đó SubTotal =SUM(OrderQty*UnitPrice).
--Cách 1:
		SELECT sd.[SalesOrderID], sh.[OrderDate], SUM(sd.OrderQty*sd.UnitPrice) AS SubTotal
		FROM [Sales].[SalesOrderDetail] sd JOIN [Sales].[SalesOrderHeader] sh
			ON sd.[SalesOrderID] = sh.[SalesOrderID]
		WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) =2008
		GROUP BY sd.[SalesOrderID], sh.[OrderDate]
		HAVING SUM(OrderQty*UnitPrice) >70000
--Cách 2:
		SELECT sd.[SalesOrderID], sh.[OrderDate], SUM(sd.OrderQty*sd.UnitPrice) AS SubTotal
		FROM [Sales].[SalesOrderDetail] sd, [Sales].[SalesOrderHeader] sh
		WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) =2008 AND sd.[SalesOrderID] = sh.[SalesOrderID]
		GROUP BY sd.[SalesOrderID], sh.[OrderDate]
		HAVING SUM(OrderQty*UnitPrice) >70000

--2)	Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia có mã vùng là US 
--		(lấy thông tin từ các bảng Sales.SalesTerritory, Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail).
--		 Thông tin bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
--Cách 1:
		SELECT st.[TerritoryID], COUNT(sc.[CustomerID]) AS CountOfCust, SUM(sd.OrderQty*sd.UnitPrice) AS SubTotal
		FROM [Sales].[SalesOrderHeader] sh JOIN [Sales].[SalesOrderDetail] sd 
			ON sh.[SalesOrderID] = sd.[SalesOrderID] JOIN [Sales].[SalesTerritory] st
			ON sh.[TerritoryID] = st.[TerritoryID] JOIN [Sales].[Customer] sc
			ON sc.[CustomerID] = sh.[CustomerID]
		WHERE st.[CountryRegionCode] = 'US'
		GROUP BY st.[TerritoryID], st.[CountryRegionCode]
--Cách 2:
		SELECT st.[TerritoryID], COUNT(sc.[CustomerID]) AS CountOfCust, SUM(sd.OrderQty*sd.UnitPrice) AS SubTotal
		FROM [Sales].[SalesOrderHeader] sh, [Sales].[SalesOrderDetail] sd, [Sales].[SalesTerritory] st, [Sales].[Customer] sc
		WHERE st.[CountryRegionCode] = 'US' AND sh.[SalesOrderID] = sd.[SalesOrderID] AND sh.[TerritoryID] = st.[TerritoryID] AND sc.[CustomerID] = sh.[CustomerID]
		GROUP BY st.[TerritoryID], st.[CountryRegionCode]

--3)	Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng (CarrierTrackingNumber) có 3 ký tự đầu là 4BD,
--		thông tin bao gồm SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
		SELECT sd.[SalesOrderID], sd.[CarrierTrackingNumber], SUM(OrderQty*UnitPrice) AS SubTotal
		FROM [Sales].[SalesOrderDetail] sd 
		WHERE sd.[CarrierTrackingNumber] LIKE '4BD%'
		GROUP BY sd.[SalesOrderID], sd.[CarrierTrackingNumber]
--4)	Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán trung bình >5, thông tin gồm ProductID, Name, 
--		AverageOfQty.
--Cách 1:
		SELECT p.[ProductID], p.Name, AVG(sd.OrderQty) AS AverageOfQty
		FROM [Production].[Product] p JOIN [Sales].[SalesOrderDetail] sd
			ON p.[ProductID] = sd.[ProductID]
		WHERE sd.[UnitPrice] <25
		GROUP BY p.[ProductID], p.Name
		HAVING AVG(sd.OrderQty)  >5
--Cách 2:
			SELECT p.[ProductID], p.Name, AVG(sd.OrderQty) AS AverageOfQty
		FROM [Production].[Product] p, [Sales].[SalesOrderDetail] sd
		WHERE sd.[UnitPrice] <25 AND p.[ProductID] = sd.[ProductID]
		GROUP BY p.[ProductID], p.Name
		HAVING AVG(sd.OrderQty)  >5
--5)	Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm JobTitle, CountOfPerson=Count(*)
	
		SELECT Count([BusinessEntityID]) AS CountOfPerson, JobTitle
		FROM [HumanResources].[Employee]
		GROUP BY JobTitle
		HAVING Count([BusinessEntityID]) > 20

--6)	Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên kết thúc bằng ‘Bicycles’ và
--		tổng trị giá > 800000, thông tin gồm BusinessEntityID, Vendor_Name, ProductID, SumOfQty , SubTotal
--		(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và [Purchasing].[PurchaseOrderDetail])
--Cách 1:
		SELECT pv.BusinessEntityID, pv.[Name], pd.[ProductID], SUM(pd.[OrderQty]) AS SumOfQty, SUM(pd.[OrderQty]*pd.[UnitPrice]) AS SubTotal
		FROM  [Purchasing].[PurchaseOrderHeader] ph JOIN [Purchasing].[PurchaseOrderDetail] pd
		ON pd.[PurchaseOrderID] = ph.[PurchaseOrderID] JOIN [Purchasing].[Vendor] pv
		ON pv.[BusinessEntityID] = ph.[VendorID]
		WHERE pv.[Name] LIKE '%Bicycles'
		GROUP BY pv.BusinessEntityID, pv.[Name], pd.[ProductID]
		HAVING SUM(pd.[OrderQty]*pd.[UnitPrice]) >800000
-- Cách 2:
				SELECT pv.BusinessEntityID, pv.[Name], pd.[ProductID], SUM(pd.[OrderQty]) AS SumOfQty, SUM(pd.[OrderQty]*pd.[UnitPrice]) AS SubTotal
		FROM  [Purchasing].[PurchaseOrderHeader] ph, [Purchasing].[PurchaseOrderDetail] pd, [Purchasing].[Vendor] pv
		WHERE pv.[Name] LIKE '%Bicycles' AND pv.[BusinessEntityID] = ph.[VendorID] AND pd.[PurchaseOrderID] = ph.[PurchaseOrderID]
		GROUP BY pv.BusinessEntityID, pv.[Name], pd.[ProductID]
		HAVING SUM(pd.[OrderQty]*pd.[UnitPrice]) >800000
		


--7)	Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng trị giá >10000, 
--		thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal
-- Cách 1:
		SELECT p.[ProductID], p.[Name], COUNT(sd.[SalesOrderID]) AS CountOfOrderID, SUM(sd.[OrderQty]*sd.[UnitPrice]) AS SubTotal
		FROM [Production].[Product] p JOIN [Sales].[SalesOrderDetail] sd ON p.[ProductID] = sd.[ProductID]
			JOIN [Sales].[SalesOrderHeader] sh ON sd.[SalesOrderID] = sh.[SalesOrderID]
		WHERE MONTH(sh.[OrderDate]) in (1, 2, 3) AND YEAR(sh.[OrderDate]) = 2008
		GROUP BY p.[ProductID], p.[Name]
		HAVING SUM(sd.[OrderQty]*sd.[UnitPrice]) >10000 AND COUNT(sd.[SalesOrderID]) >500
-- Cách 2:
		SELECT p.[ProductID], p.[Name], COUNT(sd.[SalesOrderID]) AS CountOfOrderID, SUM(sd.[OrderQty]*sd.[UnitPrice]) AS SubTotal
		FROM [Production].[Product] p, [Sales].[SalesOrderDetail] sd, [Sales].[SalesOrderHeader] sh
		WHERE MONTH(sh.[OrderDate]) in (1, 2, 3) AND YEAR(sh.[OrderDate]) = 2008 AND sd.[SalesOrderID] = sh.[SalesOrderID]
			  AND p.[ProductID] = sd.[ProductID]
		GROUP BY p.[ProductID], p.[Name]
		HAVING SUM(sd.[OrderQty]*sd.[UnitPrice]) >10000 AND COUNT(sd.[SalesOrderID]) >500
--8)	Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID),
--		họ tên (FirstName +'   '+ LastName as FullName), Số hóa đơn (CountOfOrders).
--Cách 1:
		SELECT sc.PersonID, FULLNAME = FirstName +' '+ LastName, COUNT(sh.[SalesOrderID]) AS CountOfOrders
		FROM [Sales].[Customer] sc JOIN [Sales].[SalesOrderHeader] sh 
			ON sc.[CustomerID] = sh.[CustomerID] JOIN [Person].[Person] p 
			ON sc.[PersonID] = p.[BusinessEntityID]
		WHERE YEAR([OrderDate]) BETWEEN 2007 AND 2008
		GROUP BY sc.[PersonID], [FirstName], [LastName]
		HAVING COUNT(sh.[SalesOrderID]) >25
--Cách 2:
		SELECT sc.PersonID, FULLNAME = FirstName +' '+ LastName, COUNT(sh.[SalesOrderID]) AS CountOfOrders
		FROM [Sales].[Customer] sc,  [Sales].[SalesOrderHeader] sh, [Person].[Person] p 
		WHERE YEAR([OrderDate]) BETWEEN 2007 AND 2008 AND sc.[PersonID] = p.[BusinessEntityID] AND sc.[CustomerID] = sh.[CustomerID]  
		GROUP BY sc.[PersonID], [FirstName], [LastName]
		HAVING COUNT(sh.[SalesOrderID]) >25
--9)	Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 500 sản phẩm,
--		thông tin gồm ProductID, Name, CountOfOrderQty, Year.
--     (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader, Sales.SalesOrderDetail  và Production.Product)
--Cách 1:
		SELECT p.ProductID, p.Name, COUNT([OrderQty]) AS CountOfOrderQty, YEAR([OrderDate]) AS year
		FROM [Sales].[SalesOrderDetail] sd JOIN [Sales].[SalesOrderHeader] sh
			ON sd.[SalesOrderID] = sh.[SalesOrderID] JOIN [Production].[Product] p
			ON p.[ProductID] = sd.[ProductID]
		WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'
		GROUP BY p.ProductID, p.Name, YEAR(OrderDate)
		HAVING COUNT([OrderQty])>500
		--Nếu ký tự bắt đầu % ở cuối
		--Nếu ký tự ở cuối thì % ở đầu
--Cách 2:
		SELECT p.ProductID, p.Name, COUNT([OrderQty]) AS CountOfOrderQty, YEAR([OrderDate]) AS year
		FROM [Sales].[SalesOrderDetail] sd, [Sales].[SalesOrderHeader] sh, [Production].[Product] p
		WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%' AND p.[ProductID] = sd.[ProductID] AND sd.[SalesOrderID] = sh.[SalesOrderID]
		GROUP BY p.ProductID, p.Name, YEAR(OrderDate)
		HAVING COUNT([OrderQty])>500
--10)	Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--		tên phòng ban (Name), Lương trung bình (AvgofRate).	Dữ	liệu từ	các	bảng HumanResources].[Department],
--		[HumanResources].[EmployeeDepartmentHistory], [HumanResources].[EmployeePayHistory].
--Cách 1:
		SELECT d.[DepartmentID], d.[Name], AVG(ep.[Rate]) AS AvgofRate
		FROM [HumanResources].[Department] d JOIN [HumanResources].[EmployeeDepartmentHistory] ed
			ON d.[DepartmentID] = ed.[DepartmentID] JOIN [HumanResources].[EmployeePayHistory] ep
			ON ed.[BusinessEntityID] = ep.[BusinessEntityID]
		GROUP BY d.[DepartmentID], d.[Name]
		HAVING AVG(ep.[Rate]) >30
--Cách 2:
		SELECT d.[DepartmentID], d.[Name], AVG(ep.[Rate]) AS AvgofRate
		FROM [HumanResources].[Department] d, [HumanResources].[EmployeeDepartmentHistory] ed, [HumanResources].[EmployeePayHistory] ep
		WHERE ed.[BusinessEntityID] = ep.[BusinessEntityID] AND d.[DepartmentID] = ed.[DepartmentID] 
		GROUP BY d.[DepartmentID], d.[Name]
		HAVING AVG(ep.[Rate]) >30