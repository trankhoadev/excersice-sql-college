USE AdventureWorks2008R2
GO
----1)	Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID 
--		có trên 100 đơn đặt hàng trong tháng 7 năm 2008 
--CACH 1:
		SELECT  p.ProductID, p.Name
		FROM Production.Product p
		WHERE ProductID in
		(
			SELECT sd.[ProductID]
			FROM Sales.SalesOrderDetail sd JOIN Sales.SalesOrderHeader sh ON sd.SalesOrderID = sh.SalesOrderID
			WHERE YEAR(sh.OrderDate) = 2008 AND MONTH(sh.OrderDate) = 7
			GROUP BY sd.ProductID
			HAVING COUNT(sd.ProductID) >100
		)
--CACH 2:
		SELECT  p.ProductID, p.Name
		FROM Production.Product p
		WHERE ProductID in
		(
			SELECT sd.[ProductID]
			FROM Sales.SalesOrderDetail sd, Sales.SalesOrderHeader sh
			WHERE YEAR(sh.OrderDate) = 2008 AND MONTH(sh.OrderDate) = 7 AND sd.SalesOrderID = sh.SalesOrderID
			GROUP BY sd.ProductID
			HAVING COUNT(sd.ProductID) >100
		)
----2)	Liệt kê các sản phẩm (ProductID, Name) 
--		có số hóa đơn đặt hàng nhiều nhất trong tháng 7/2008 
--CACH 1: 
		SELECT p.ProductID, p.Name
		FROM Production.Product p
		WHERE p.ProductID in
		(
			SELECT top 1  sd.ProductID 
			FROM Sales.SalesOrderDetail sd JOIN Sales.SalesOrderHeader sh ON sd.SalesOrderID = sh.SalesOrderID
			WHERE MONTH(sh.OrderDate) = 7 AND YEAR(sh.OrderDate) = 2008
			GROUP BY sd.ProductID
			ORDER BY COUNT(sd.ProductID) desc
		)
--CACH 2:
		SELECT p.ProductID, p.Name
		FROM Production.Product p
		WHERE p.ProductID in
		(
			SELECT top 1  sd.ProductID 
			FROM Sales.SalesOrderDetail sd, Sales.SalesOrderHeader sh
			WHERE MONTH(sh.OrderDate) = 7 AND YEAR(sh.OrderDate) = 2008 AND sd.SalesOrderID = sh.SalesOrderID
			GROUP BY sd.ProductID
			ORDER BY COUNT(sd.ProductID) desc
		)
----3)	Hiển thị thông tin của khách hàng
--		có số đơn đặt hàng nhiều nhất, thông tin gồm: CustomerID, Name, CountOfOrder 
--CACH 1:
		SELECT sc.CustomerID, FULLNAME = FirstName+''+LastName
		FROM Person.Person p JOIN Sales.Customer sc ON p.BusinessEntityID = sc.PersonID
		WHERE sc.CustomerID in
		(
			SELECT TOP 1 WITH TIES sc.CustomerID
			FROM Sales.SalesOrderHeader sh JOIN Sales.Customer sc ON sh.CustomerID = sc.CustomerID
			GROUP BY sc.CustomerID
			ORDER BY COUNT(sh.[SalesOrderID]) desc
		)
		GROUP BY sc.CustomerID, FirstName, LastName
--CACH 2:
		SELECT sc.CustomerID, FULLNAME = FirstName+''+LastName
		FROM Person.Person p JOIN Sales.Customer sc ON p.BusinessEntityID = sc.PersonID
		WHERE sc.CustomerID in
		(
			SELECT TOP 1 WITH TIES sc.CustomerID
			FROM Sales.SalesOrderHeader sh, Sales.Customer sc
			WHERE sh.CustomerID = sc.CustomerID
			GROUP BY sc.CustomerID
			ORDER BY COUNT(sh.[SalesOrderID]) desc
		)
		GROUP BY sc.CustomerID, FirstName, LastName
--CACH 3:
		SELECT CustomerID, name = (SELECT FirstName+' '+LastName from Person.Person
		WHERE BusinessEntityID=c.PersonID), countID = (SELECT count(SalesOrderID) 
		FROM Sales.SalesOrderHeader WHERE CustomerID=c.CustomerID)
		FROM Sales.Customer c
		WHERE CustomerID in (SELECT top 1 with ties CustomerID FROM Sales.SalesOrderHeader
		GROUP BY  CustomerID ORDER BY count(SalesOrderID) desc)


----4)	Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với tên bắt đầu với
--		“Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, 
--		(sử dụng bảng Production.Product và Production.ProductModel)
		SELECT p.ProductID, p.Name
		FROM Production.Product p 
		WHERE ProductModelID IN
		(
			SELECT pm.ProductModelID
			FROM Production.ProductModel pm
			WHERE pm.Name LIKE 'Long-Sleeve Logo Jersey%'
		)

		SELECT p.ProductID, p.Name
		FROM Production.Product p
		WHERE
		EXISTS
		(
			SELECT pm.ProductModelID
			FROM Production.ProductModel pm JOIN Production.Product ON pm.ProductModelID = p.ProductModelID
			WHERE pm.Name LIKE 'Long-Sleeve Logo Jersey%' 
		)
----5)	Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối đa cao hơn giá trung
--		bình của tất cả các mô hình. 
		SELECT pm.ProductModelID, MAX(ListPrice) AS N'Gianiemyet' , AVG(p.ListPrice) AS 'Giatrungbinh'
		FROM Production.Product p JOIN Production.ProductModel pm ON p.ProductModelID = pm.ProductModelID
		WHERE pm.ProductModelID IN
		(
			SELECT pm.ProductModelID
			FROM Production.Product p JOIN Production.ProductModel pm ON p.ProductModelID = pm.ProductModelID
			GROUP BY pm.ProductModelID
			HAVING MAX(p.ListPrice) > AVG(p.ListPrice)
		)
		GROUP BY pm.ProductModelID


----6)	Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng đặt hàng > 5000 
--		(dùng IN, EXISTS) 
		SELECT p.ProductID, p.Name
		FROM Production.Product p
		WHERE p.ProductID in (
							SELECT ProductID
							FROM Sales.SalesOrderDetail sd
							GROUP BY sd.ProductID
							HAVING Sum(OrderQty) >5000
							)

				SELECT p.ProductID, p.Name
		FROM Production.Product p
		WHERE EXISTS (
							SELECT ProductID
							FROM Sales.SalesOrderDetail sd
							WHERE sd.ProductID = p.ProductID
							GROUP BY sd.ProductID
							HAVING Sum(OrderQty) >5000
							)


----7)	Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất trong bảng 
--		Sales.SalesOrderDetail 
		SELECT  ProductID, UnitPrice
		FROM Sales.SalesOrderDetail
		WHERE UnitPrice in
		(
			SELECT TOP 1 WITH TIES UnitPrice 
			FROM Sales.SalesOrderDetail
			GROUP BY UnitPrice
			ORDER BY UnitPrice desc
		)

		SELECT DISTINCT ProductID, UnitPrice
		FROM Sales.SalesOrderDetail
		WHERE UnitPrice in
		(
					SELECT TOP 1 WITH TIES sd.UnitPrice
		FROM Sales.SalesOrderDetail sd
		GROUP BY UnitPrice
		ORDER BY UnitPrice desc
		)

		SELECT DISTINCT ProductID = (SELECT p.ProductID FROM Production.Product p WHERE p.ProductID = sd.ProductID ), UnitPrice
		FROM Sales.SalesOrderDetail sd
		WHERE UnitPrice in (SELECT  TOP 1 WITH TIES UnitPrice FROM Sales.SalesOrderDetail sd 		GROUP BY UnitPrice
		ORDER BY UnitPrice desc )




----8)	Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, Nam; dùng 3 cách Not in,
--		Not exists và Left join.
		SELECT p.ProductID, Name
		FROM Production.Product p LEFT JOIN Sales.SalesOrderDetail sd ON p.ProductID = sd.ProductID
		WHERE SalesOrderID IS NULL



--CACH 1: NOT IN
		SELECT ProductID, Name
		FROM Production.Product
		WHERE ProductID NOT IN(SELECT ProductID FROM Sales.SalesOrderDetail GROUP BY ProductID)
--CACH 2: NOT EXISTS
		SELECT ProductID, Name
		FROM Production.Product p
		WHERE NOT EXISTS
		(
			SELECT ProductID 
			FROM Sales.SalesOrderDetail sd 
			WHERE p.ProductID=sd.ProductID
		)
--CACH 3:
		SELECT p.ProductID, p.Name
		FROM Production.Product p LEFT JOIN Sales.SalesOrderDetail sd 
			ON p.ProductID = sd.ProductID
		WHERE sd.SalesOrderID IS NULL
----9)	Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm EmployeeID, FirstName,
--      LastName (dữ liệu từ 2 bảng HumanResources.Employees và Sales.SalesOrdersHeader)



		SELECT
		FROM HumanResources.Employee e JOIN Sales.SalesOrderHeader sh ON  
		WHERE e.BusinessEntityID = sh.SalesOrderID


		SET DATEFORMAT dmy
		SELECT e.BusinessEntityID AS EmployeeID, FULLNAME = FirstName + ' ' + LastName
FROM HumanResources.Employee e JOIN Person.Person p ON e.BusinessEntityID = p.[BusinessEntityID]
		WHERE e.BusinessEntityID NOT IN
		(
			SELECT sh.SalesOrderID
			FROM Sales.SalesOrderHeader sh
WHERE OrderDate BETWEEN '01/05/2008' AND GETDATE()
		)
		ORDER BY EmployeeID desc

----10)	Liệt kê danh sách các khách hàng (CustomerID(custom, header), Name(Person)) có hóa đơn dặt hàng trong năm()sh 2007 nhưng 
--		không có hóa đơn đặt hàng trong năm 2008. 
		SELECT DISTINCT 
		CustomerID ,
		Name = (SELECT FirstName+' '+LastName FROM Person.Person WHERE BusinessEntityID = CustomerID)
		FROM Sales.SalesOrderHeader sh
		WHERE  
		CustomerID NOT in (SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2008) AND
		CustomerID in (SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2007)