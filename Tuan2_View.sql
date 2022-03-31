--1)	Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng Production.Product và bảng Production.ProductCostHistory.
--		Thông tin bao gồm ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
		CREATE VIEW dbo.vw_Products
		AS
		(
			SELECT p.[ProductID], [Name], [Color], [Size], [Style], p.[StandardCost], [EndDate], [StartDate]
			FROM [Production].[Product] p JOIN [Production].[ProductCostHistory] pp ON p.[ProductID]=pp.[ProductID]
		)
		SELECT * FROM dbo.vw_Products
--2)	Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng trị giá >10000,
--		thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal.
		CREATE VIEW List_Product_View
		AS
		(
			SELECT p.[ProductID], p.[Name], COUNT(sd.[SalesOrderID]) AS CountOfOrderID, SUM(sd.[OrderQty]*[UnitPrice]) AS SubTotal
			FROM [Production].[Product] p JOIN [Sales].[SalesOrderDetail] sd ON p.[ProductID] = sd.[ProductID]
			JOIN [Sales].[SalesOrderHeader] sh ON sd.[SalesOrderID] = sh.[SalesOrderID]
			WHERE MONTH([OrderDate]) in (1, 2, 3) AND YEAR([OrderDate]) = 2008
			GROUP BY p.[ProductID], p.[Name]
			HAVING SUM(sd.[OrderQty]*[UnitPrice]) > 10000 AND COUNT(sd.[SalesOrderID])  > 500
		)
		SELECT * FROM List_Product_View
--3)	Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột TotalDue của mỗi khách hàng (customer) 
--		theo tháng và theo năm. Thông tin gồm CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue).
		CREATE VIEW dbo.vw_CustomerTotals
		AS
		(
			SELECT sc.[CustomerID], MONTH([OrderDate]) AS OrderMonth, YEAR([OrderDate]) AS OrderYear, SUM([TotalDue]) AS TotalSales
			FROM [Sales].[Customer] sc JOIN [Sales].[SalesOrderHeader] sh ON sc.[CustomerID] = sh.[CustomerID]
			GROUP BY sc.[CustomerID], MONTH([OrderDate]), YEAR([OrderDate])
			
		)
		SELECT * FROM dbo.vw_CustomerTotals
--4)	Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân viên theo từng năm. Thông tin gồm SalesPersonID,
--		OrderYear, sumOfOrderQty
		CREATE VIEW dbo.vw_TotalQuantity
		AS
		(
			SELECT sh.[SalesPersonID], YEAR([OrderDate]) AS OrderYear, SUM([OrderQty]) AS sumOfOrderQty
			FROM [Sales].[SalesOrderDetail] sd JOIN [Sales].[SalesOrderHeader] sh ON sd.[SalesOrderID] = sh.[SalesOrderID]
			GROUP BY sh.[SalesPersonID], YEAR([OrderDate])
		)
		SELECT * FROM dbo.vw_TotalQuantity

--5)	Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 2008, thông tin gồm mã
		khách
--		(PersonID) , họ tên (FirstName +'  '+ LastName as FullName), Số hóa đơn (CountOfOrders).
		CREATE VIEW ListCustomer_view
		AS
		(
		SELECT sc.[PersonID], FULLNAME = FirstName +'  '+ LastName, COUNT([SalesOrderID]) AS CountOfOrders
		FROM [Sales].[Customer] sc JOIN [Sales].[SalesOrderHeader] sh ON sc.[CustomerID] = sh.[CustomerID]
		JOIN [Person].[Person] p ON p.[BusinessEntityID] = sc.[PersonID]
		WHERE YEAR(sh.[OrderDate]) BETWEEN 2007 AND 2008
		GROUP BY sc.[PersonID], FirstName, LastName
		HAVING	COUNT([SalesOrderID])>25
		)
		SELECT * FROM ListCustomer_view


--6)	Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm
--		trên 50 sản phẩm, thông tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng	Sales.SalesOrderHeader,
--		Sales.SalesOrderDetail, và Production.Product)
		
		CREATE VIEW ListProduct_view1
		AS
		(
			SELECT p.[ProductID], p.[Name], COUNT([OrderQty]) AS CountOfOrderQty, YEAR([OrderDate]) AS Year
			FROM [Production].[Product] p JOIN [Sales].[SalesOrderDetail] sd ON p.[ProductID] = sd.[ProductID]
			JOIN [Sales].[SalesOrderHeader] sh ON sh.[SalesOrderID] = sd.[SalesOrderID]
			WHERE Name LIKE 'Bike%' OR Name LIKE 'Sport%' 
			GROUP BY p.[ProductID], p.[Name], YEAR([OrderDate])
			HAVING COUNT([OrderQty]) > 500
		)
		SELECT * FROM ListProduct_view1
		--DROP VIEW List_Product_view
--7)	Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông tin gồm Mã
--		phòng ban (DepartmentID), tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng [HumanResources].[Department],
--		[HumanResources].[EmployeeDepartmentHistory], [HumanResources].[EmployeePayHistory].

		CREATE VIEW List_department_View
		AS
		(
			SELECT a.DepartmentID, Name, AVG([Rate]) AS AvgOfRate
			FROM [HumanResources].[Department] a JOIN [HumanResources].[EmployeeDepartmentHistory] b 
			ON a.[DepartmentID] = b.[DepartmentID] JOIN [HumanResources].[EmployeePayHistory] c
			ON b.[BusinessEntityID] = c.[BusinessEntityID]
			GROUP BY a.DepartmentID, Name
			HAVING AVG([Rate])  > 30
		)
		SELECT * FROM List_department_View

--8)	Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập),
--		OrderTotal (tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
		CREATE VIEW Sales.vw_OrderSummary
		WITH ENCRYPTION -- Không thể xem được cái loại view này
		AS
		(
			SELECT MONTH([OrderDate]) AS OrderYear, YEAR([OrderDate]) AS OrderMonth, SUM([TotalDue]) AS OrderTotal
			FROM [Sales].[SalesOrderHeader]
			GROUP BY MONTH([OrderDate]), YEAR([OrderDate])
		)
		SELECT * FROM Sales.vw_OrderSummary
		-- OrderTotal là lấy Sum(TotalDue)
		-- SubTotal là lấy SUM(UnitPrice*OrderQty)
--9)	Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product
--		và bảng ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng Product. Có xóa được không? Vì sao?
	
		CREATE VIEW Production.vwProducts
		WITH SCHEMABINDING
		AS
		(
			SELECT p.[ProductID], p.[Name], [StartDate], [EndDate], [ListPrice]
			FROM [Production].[Product] p JOIN [Production].[ProductCostHistory] ph
			ON p.[ProductID] = ph.[ProductID]
			GROUP BY p.[ProductID], p.[Name], [StartDate], [EndDate], [ListPrice]
		)
		SELECT * FROM Production.vwProducts
		DROP VIEW Production.vwProducts
		-- Không cho thay đổi cấu trúc trong bảng
--10)	Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và
--		“Quality Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
--		a.	Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm “Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--		chèn được không? Giải thích.
--		b.	Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một phòng thuộc nhóm “Quality Assurance”.
--		c.	Dùng câu lệnh Select xem kết quả trong bảng Department.
		CREATE VIEW view_Department
		
		AS
		(
			SELECT DepartmentID, Name, GroupName
			FROM [HumanResources].[Department]
			WHERE GroupName = 'Manufacturing' OR GroupName = 'Quality Assurance'
--			GROUP BY DepartmentID, Name, GroupName
		)
		WITH CHECK OPTION
--a. -> Không chèn được vì điều kiện để thêm là phải thuộc 1 trong 2 nhóm kia
		
		INSERT view_Department (Name,GroupName) VALUES('trung','Manufacturing')
		SELECT * FROM [HumanResources].[Department]