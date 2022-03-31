USE AdventureWorks2008R2
GO
---------------------------------------------------------------------------------------------------------------------
--			Scalar Function
--1)	Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, giá trị truyền vào lấy từ field
--		[DepartmentID], hàm trả về số nhân viên trong phòng ban tương ứng. 
--		Áp dụng hàm đã viết vào câu truy vấn liệt
--		kê danh sách các phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name,
--		 countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--		(Dữ liệu lấy từ bảng [HumanResources].[EmployeeDepartmentHistory] và [HumanResources].[Department])
		CREATE 
---------
		CREATE FUNCTION CountOfEmployees_3(@mapb SMALLINT)
		RETURNS INT AS
		BEGIN
			DECLARE @count INT
			SELECT @count = COUNT(BusinessEntityID)
			FROM HumanResources.EmployeeDepartmentHistory dh JOIN HumanResources.Department d
			ON dh.DepartmentID = d.DepartmentID
			WHERE @mapb = d.DepartmentID
			GROUP BY dh.DepartmentID	
			RETURN @count
		END
		GO
		DECLARE @mapb SMALLINT
		SET @mapb=10
		SELECT distinct A.DepartmentID, Name, DBO.CountOfEmployees_3(@mapb)
		from HumanResources.EmployeeDepartmentHistory a join HumanResources.Department b
		on A.DepartmentID=B.DepartmentID
		WHERE @mapb=A.DepartmentID
---------
		CREATE FUNCTION CountOfEmployees(@mapb SMALLINT)
		RETURNS TABLE
		AS
				RETURN
				(
					SELECT d.DepartmentID, d.Name, COUNT(dh.DepartmentID) AS CountOfEmployees
					FROM HumanResources.EmployeeDepartmentHistory dh JOIN HumanResources.Department d
					ON dh.DepartmentID = d.DepartmentID
					WHERE dh.DepartmentID like @mapb
					GROUP BY d.DepartmentID, Name
				)

		SELECT * FROM CountOfEmployees(1)


--2)	Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--		@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu vực tương ứng với giá trị của tham số
--		(Dữ liệu lấy từ bảng[Production].[ProductInventory])
		CREATE FUNCTION InventoryProd(@ProductID INT, @LocationID SMALLINT)
		RETURNS INT AS
			BEGIN
				DECLARE @s1 SMALLINT
				SELECT @s1 = Quantity
				FROM Production.ProductInventory
				WHERE ProductID = @ProductID AND LocationID = @LocationID
				RETURN @s1
			END
		DECLARE @ProductID INT, @LocationID SMALLINT
		SET @ProductID = 1
		SET @LocationID =1
		PRINT(N'Số lượng tồn kho: ' + CONVERT(VARCHAR(10), dbo.InventoryProd(@ProductID, @LocationID)))
		
		SELECT dbo.InventoryProd(@ProductID, @LocationID) AS SOLUONG

		SELECT SUM(Quantity)
		FROM Production.ProductInventory
		WHERE ProductID = 1 AND LocationID = 1
		
--3)	Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của một nhân viên trong một tháng
--		tùy ý trong một năm tùy ý, với tham số vào
--		@EmplID, @MonthOrder, @YearOrder
--		(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
		CREATE FUNCTION SubTotalOfEmp(@EmplID INT, @MonthOrder INT, @YearOrder INT)
		RETURNS MONEY
		AS
			BEGIN
				DECLARE @doanhthu MONEY
				SELECT @doanhthu = SUM(SubTotal)
				FROM Sales.SalesOrderHeader
				WHERE SalesPersonID = @EmplID AND MONTH(OrderDate) = @MonthOrder AND YEAR(OrderDate) =@YearOrder 
				RETURN @doanhthu
			END
		DECLARE @manv int, @thang int, @nam int
		SET @manv  = 282
		SET @thang = 7
		SET @nam   = 2005
		
		PRINT(N'Nhân viên ' + CONVERT(VARCHAR(10), @manv) + N' có tổng doanh thu trong tháng là ' + CONVERT(VARCHAR(10), @thang))

				SELECT  SalesPersonID, MONTH(OrderDate) AS MonthOrder, YEAR(OrderDate) AS YearOrder, doanhthu = SUM(SubTotal)
				FROM Sales.SalesOrderHeader
				WHERE SalesPersonID = 282 AND MONTH(OrderDate) = 7 AND YEAR(OrderDate) =2005
				GROUP BY SalesPersonID, MONTH(OrderDate), YEAR(OrderDate)
--4)	Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các hóa đơn (SalesOrderID) lập
--		trong tháng và năm được truyền vào từ 2 tham số @thang và @nam, có tổng tiền >70000, thông tin gồm 
--		SalesOrderID, OrderDate, SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
---TEST
		SELECT sd.SalesOrderID, sh.[OrderDate], SubTotal =sum(OrderQty*UnitPrice)
		FROM Sales.SalesOrderDetail sd JOIN Sales.SalesOrderHeader sh ON sd.[SalesOrderID] = sh.[SalesOrderID]
		GROUP BY sd.SalesOrderID, sh.[OrderDate]
		HAVING sum(OrderQty*UnitPrice) >70000

		CREATE FUNCTION SumOfOrder(@thang INT, @nam INT)
		RETURNS TABLE AS
		RETURN
			(
			SELECT sd.SalesOrderID, sh.[OrderDate], SubTotal =sum(OrderQty*UnitPrice)
			FROM Sales.SalesOrderDetail sd JOIN Sales.SalesOrderHeader sh ON sd.[SalesOrderID] = sh.[SalesOrderID]
			WHERE @thang = MONTH(sh.[OrderDate]) AND @nam = YEAR(sh.[OrderDate])
			GROUP BY sd.SalesOrderID, sh.[OrderDate]
			HAVING sum(OrderQty*UnitPrice) >70000
			)
-- Thực thi
		SELECT * FROM SumOfOrder(8, 2005)
--5)	Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng (SalesPerson), dựa trên
--		tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--		SumOfSubTotal =sum(SubTotal),
--		NewBonus = Bonus+ sum(SubTotal)*0.01
		SELECT BusinessEntityID, Bonus, SumOfSubTotal =sum(sh.SubTotal), NewBonus = Bonus+ sum(sh.SubTotal)*0.01
		FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader sh ON sp.BusinessEntityID = sh.[SalesPersonID]
		GROUP BY BusinessEntityID, Bonus

		CREATE FUNCTION NewBonus_12(@manv INT)
		RETURNS TABLE AS
		RETURN
			(
				SELECT BusinessEntityID, Bonus, SumOfSubTotal =sum(sh.SubTotal), NewBonus = Bonus+ sum(sh.SubTotal)*0.01
				FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader sh ON sp.BusinessEntityID = sh.[SalesPersonID]
				WHERE @manv = BusinessEntityID
				GROUP BY BusinessEntityID, Bonus
			)
			SELECT * FROM NewBonus_12(284)
--6)	Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID), hàm dùng để tính tổng
--		số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) của các sản phẩm do nhà cung cấp @MaNCC cung cấp,
--		thông tin gồm ProductID, SumOfProduct, SumOfSubTotal
--		(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
--		và [Purchasing].[PurchaseOrderDetail])
		SELECT pd.ProductID, VendorID, SumOfProduct = SUM([OrderQty]), SumOfSubTotal = SUM([SubTotal])
		FROM Purchasing.PurchaseOrderDetail pd JOIN Purchasing.PurchaseOrderHeader ph ON pd.PurchaseOrderID = ph.PurchaseOrderID
		JOIN Purchasing.Vendor v ON v.[BusinessEntityID] = ph.[VendorID]
		WHERE ProductID = 355
		GROUP BY pd.ProductID, VendorID

		ALTER FUNCTION SumOfProduct(@maNCC INT)
		RETURNS TABLE AS
		RETURN
			(
				SELECT pd.ProductID, VendorID, SumOfProduct = SUM([OrderQty]), SumOfSubTotal = SUM([SubTotal])
				FROM Purchasing.PurchaseOrderDetail pd JOIN Purchasing.PurchaseOrderHeader ph ON pd.PurchaseOrderID = ph.PurchaseOrderID
				JOIN Purchasing.Vendor v ON v.[BusinessEntityID] = ph.[VendorID]
				WHERE @maNCC = VendorID
				GROUP BY pd.ProductID, VendorID
			)
		SELECT * FROM SumOfProduct(1580)
--7)	Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn (SalesOrderID), thông tin gồm
--		SalesOrderID, [SubTotal], Discount; trong đó Discount được tính như sau:
--			Nếu [SubTotal]<1000 thì Discount=0 
--			Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--			Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--			Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--		Gợi ý: Sử dụng Case.. When … Then …
		SELECT sh.[SalesOrderID], [SubTotal] 
		,Discount = CASE
				WHEN [SubTotal]<1000 THEN 0
				WHEN [SubTotal] BETWEEN 1000 AND 5000 THEN [SubTotal]*5/100
				WHEN [SubTotal] BETWEEN 5000 AND 10000 THEN [SubTotal]*10/100
				WHEN [SubTotal]>=10000  THEN [SubTotal]*15/100
			END
		FROM Sales.SalesOrderHeader sh 
		GROUP BY sh.[SalesOrderID], [SubTotal] 
		--43659	20565.6206	3084.843
		ALTER FUNCTION Discount_Func(@maHD INT)
		RETURNS TABLE AS
		RETURN
			(
		SELECT sh.[SalesOrderID], [SubTotal] 
		,Discount = CASE
				WHEN [SubTotal]<1000 THEN 0
				WHEN [SubTotal] BETWEEN 1000 AND 5000 THEN [SubTotal]*5/100
				WHEN [SubTotal] BETWEEN 5000 AND 10000 THEN [SubTotal]*10/100
				WHEN [SubTotal]>=10000  THEN [SubTotal]*15/100
			END
		FROM Sales.SalesOrderHeader sh 
		WHERE @maHD = [SalesOrderID]
		GROUP BY sh.[SalesOrderID], [SubTotal] 
			)
		SELECT * FROM Discount_Func(43659)
--8)	Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng doanh thu của các nhân viên
--		bán hàng (SalePerson) trong tháng và năm được truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total,
--		với Total=Sum([SubTotal])
		SELECT [SalesPersonID], Total=Sum([SubTotal])
		FROM Sales.SalesOrderHeader sh
		WHERE MONTH([OrderDate]) = 7 AND YEAR([OrderDate]) = 2005
		GROUP BY [SalesPersonID]

		CREATE FUNCTION TotalOfEmp(@thang INT, @nam INT)
		RETURNS TABLE AS
		RETURN
		(
			SELECT [SalesPersonID], Total=Sum([SubTotal])
			FROM Sales.SalesOrderHeader sh
			WHERE MONTH([OrderDate]) = @thang AND YEAR([OrderDate]) = @nam
			GROUP BY [SalesPersonID]
		)
		SELECT * FROM TotalOfEmp(7,2005)



--		Multi-statement Table Valued Functions:
--9)	Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function
--10)	Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham số vào là @MaNV
--		(giá trị của [BusinessEntityID]), thông tin gồm BusinessEntityID, FName, LName, Salary 
--		(giá trị của cột Rate). Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết quả 
--		là bảng lương của nhân viên đó. Ví dụ thực thi hàm: select * from SalaryOfEmp(288)
		SELECT
		FROM [HumanResources].[EmployeePayHistory] ph JOIN [Person].[Person] p ON
		ph.[BusinessEntityID] = p.[BusinessEntityID]
		WHERE
