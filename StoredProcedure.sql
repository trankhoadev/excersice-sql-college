USE AdventureWorks2008R2
GO
----------------------------------------------------------------------------------------------------------------------------
--1)	Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một tháng bất kỳ của một năm bất kỳ 
--		(tham số tháng và năm) được nhập từ bàn phím, thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
		CREATE PROCEDURE TINHTIEN @thang INT,
								  @nam   INT
		AS
		BEGIN
			SELECT CustomerID, SUM(TotalDue) AS SumOfTotalDue
			FROM Sales.SalesOrderHeader 
			WHERE @thang = MONTH(OrderDate) AND @nam  = YEAR(OrderDate)
			GROUP BY CustomerID
		END

		exec TINHTIEN 7,2008

--2)	Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của một nhân viên bất kỳ, với một tham
--		số đầu vào và một tham số đầu ra. Tham số @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
--		@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
		SET dateformat dmy
		GO
		CREATE PROCEDURE XEMDOANHTHU @SalesPerson INT
		AS
		BEGIN
			DECLARE @SalesYTD MONEY
			SELECT @SalesYTD = SUM(SubTotal)
			FROM Sales.SalesOrderHeader
			WHERE SalesPersonID = @SalesPerson AND OrderDate BETWEEN 1/1/YEAR(GETDATE()) AND GETDATE()
			RETURN @SalesYTD
		END

		@SalesYTD MONEY
		exec @SalesYTD = XEMDOANHTHU 279 
		print @SalesYTD

		SELECT SalesPersonID, SUM(SubTotal) AS TONG
		FROM Sales.SalesOrderHeader
		WHERE SalesPersonID = 279
		GROUP BY SalesPersonID
--3)	Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có giá bán không vượt quá một giá trị
--		chỉ định (tham số input @MaxPrice). 
		CREATE PROCEDURE List_Product (@MaxPrice MONEY)
		AS
			BEGIN
				DECLARE @danhsach TABLE (ProductID INT, ListPrice MONEY)
				INSERT @danhsach
					SELECT ProductID, ListPrice
					FROM Production.Product 
					WHERE ListPrice <= @MaxPrice
			END
			--
					SELECT ProductID, ListPrice
					FROM Production.Product 
					WHERE ListPrice = 500 
			exec List_Product 1

--4)	Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán hàng (SalesPerson), dựa trên tổng
--		doanh thu của nhân viên đó. Mức thưởng mới bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
--		[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--		SumOfSubTotal =sum(SubTotal) 
--		NewBonus = Bonus+ sum(SubTotal)*0.01 

/*
		CREATE PROCEDURE NewBonus @manv int
		AS
		BEGIN
			SELECT sh.[SalesPersonID], NewBonus = Bonus+ sum(SubTotal)*0.01, SumOfSubTotal =sum(SubTotal)  
			FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.[SalesPersonID] = sp.BusinessEntityID
			WHERE @manv = sp.BusinessEntityID
			GROUP BY [SalesPersonID], Bonus
		END
		GO
		EXEC NewBonus 275
Xem giá trị ban đầu
		SELECT [SalesPersonID], Bonus
		FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.[SalesPersonID] = sp.BusinessEntityID
		WHERE BusinessEntityID = 275
		GROUP BY [SalesPersonID], Bonus

		SELECT *  FROM Sales.SalesPerson WHERE BusinessEntityID = 275
*/
--------------------------------------------------------------------------------------------------------------------------
		CREATE PROCEDURE NewBonus  
		AS
			BEGIN
				UPDATE Sales.SalesPerson
				SET Bonus = Bonus + SUM(SubTotal)*0.01
				FROM [Sales].[SalesPerson] sp JOIN [Sales].[SalesOrderHeader] sh ON sp.[BusinessEntityID] = sh.[SalesOrderID]
				return
				SELECT SalesPersonID, NewBonus = Bonus
				FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader sh ON sp.[BusinessEntityID] = sh.[SalesOrderID]
			END
		
		SELECT SalesPersonID, Bonus, SUM(sp.Sub)
		FROM [Sales].[SalesPerson] sp JOIN [Sales].[SalesOrderHeader] sh ON sp.[BusinessEntityID] = sh.[SalesOrderID]

		SELECT Sales
		FROM Sales.SalesOrderDetail sd JOIN Sales.SalesPerson sp ON sd.SalesOrderID = sp.BusinessEntityID

		----------------------
		CREATE PROCEDURE NewBonus_1 @manv int
		AS
		BEGIN
			DECLARE @SumOfSubTotal money
			SET @SumOfSubTotal = 
			(
				SELECT SUM([SubTotal])
				FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader sh ON sp.BusinessEntityID = sh.SalesPersonID
				WHERE sp.BusinessEntityID = @manv
				GROUP BY sp.BusinessEntityID
			)

			UPDATE Sales.SalesPerson
			SET Bonus = 
			(
				SELECT Bonus + @SumOfSubTotal*0.01
				FROM Sales.SalesPerson
				WHERE BusinessEntityID = @manv
			)
			WHERE BusinessEntityID = @manv
		END
		GO

		EXEC NewBonus_1 275

		SELECT Bonus
		FROM Sales.SalesPerson
		WHERE BusinessEntityID  =275

		SELECT SUM(SubTotal)
		FROM Sales.SalesOrderHeader
		

				CREATE PROCEDURE NewBonus_2 @manv int
		AS
		BEGIN
			SELECT sh.[SalesPersonID], NewBonus = Bonus+ sum(SubTotal)*0.01, SumOfSubTotal =sum(SubTotal)  
			FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.[SalesPersonID] = sp.BusinessEntityID
			WHERE @manv = sp.BusinessEntityID
			GROUP BY [SalesPersonID], Bonus
		END
		GO
		EXEC NewBonus_2 275

--5)	Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) có tổng số lượng (OrderQty) đặt hàng 
--		cao nhất trong một năm tùy ý (tham số input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
--		ProductCategory, ProductSubCategory, Product(Name) và SalesOrderDetail(Orderqty).
--		(Lưu ý: dùng Sub Query) 
-- Tìm hiểu
--11) TEST
	CREATE PROCEDURE usp_TinhTong
		@a INT,
		@b INT,
	AS
	BEGIN
		DECLARE @result INT
		SET @result = @a + @b
		PRINT 'kq = ' + CAST(@result AS NVARCHAR(10))
	END
	GO
	EXEC usp_TinhTong 2, 3

------------------------
	CREATE PROCEDURE usp_TinhTong_1
		@a INT,
		@b INT,
		@c INT OUTPUT
	AS
	BEGIN
--		DECLARE @result INT -- Trên khai báo rồi nên ở đây không cần khai báo nữa
		SET @c = @a + @b
	END
	GO
	--Bên ngoài phải có 1 cái kq trả về 
	DECLARE @c_1 INT
	EXEC usp_TinhTong_1 2, 3, @c_1 OUTPUT
	PRINT @c_1

----------
	CREATE PROCEDURE usp_TinhTong_2
		@a INT,
		@b INT
	AS
	BEGIN
	DECLARE @c INT
		SET @c = @a + @b
		RETURN @c
	END
	GO
	--Bên ngoài phải có 1 cái kq trả về 
	DECLARE @c INT
	EXEC @c =  usp_TinhTong_2 2, 3
	PRINT @c
-- Test
		SELECT TOP 1 WITH TIES pc.ProductCategoryID, pc.Name,  SumOfQty = SUM(sd.OrderQty), YEAR(OrderDate)
			FROM Production.ProductCategory pc JOIN Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID
			JOIN Production.Product p ON p.ProductSubcategoryID = ps.ProductSubcategoryID JOIN Sales.SalesOrderDetail sd 
			ON p.ProductID = sd.ProductID JOIN Sales.SalesOrderHeader sh ON sh.[SalesOrderID] = sd.[SalesOrderID]
		WHERE YEAR([OrderDate]) = 2007
		GROUP BY pc.ProductCategoryID, pc.Name, OrderDate
		ORDER BY SUM(sd.OrderQty) desc
---------
		CREATE PROCEDURE nhomSP @nam int
		AS
		BEGIN
			SELECT TOP 1 WITH TIES pc.ProductCategoryID, pc.Name,  SumOfQty = SUM(sd.OrderQty), YEAR(OrderDate)
			FROM Production.ProductCategory pc JOIN Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID
			JOIN Production.Product p ON p.ProductSubcategoryID = ps.ProductSubcategoryID JOIN Sales.SalesOrderDetail sd 
			ON p.ProductID = sd.ProductID JOIN Sales.SalesOrderHeader sh ON sh.[SalesOrderID] = sd.[SalesOrderID]
		WHERE YEAR([OrderDate]) = @nam
		GROUP BY pc.ProductCategoryID, pc.Name, OrderDate
		ORDER BY SUM(sd.OrderQty) desc
		END
		GO
--------Thực thi
		EXEC nhomSP 2007
		go
--------Subquery
		SELECT TOP 1 WITH TIES pc.ProductCategoryID = 
		(
			SELECT ps.ProductCategoryID, ps.Name
			FROM Production.ProductCategory pc JOIN Production.ProductSubcategory ps
			ON pc.[ProductCategoryID] = ps.[ProductCategoryID]
			GROUP BY ps.ProductCategoryID, ps.Name
		)
		, pc.Name,
		SUM(sd.OrderQty) = 
		(
			SELECT
			FROM 
			WHERE
		)
		FROM Production.ProductCategory pc JOIN Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID
		JOIN Production.Product p ON p.ProductSubcategoryID = ps.ProductSubcategoryID JOIN Sales.SalesOrderDetail sd 
		ON p.ProductID = sd.ProductID JOIN Sales.SalesOrderHeader sh ON sh.[SalesOrderID] = sd.[SalesOrderID]
		WHERE YEAR([OrderDate]) = 2007
		GROUP BY pc.ProductCategoryID, pc.Name, OrderDate
		ORDER BY SUM(sd.OrderQty) desc
--6)	Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra là tổng trị giá các hóa đơn nhân viên
--		đó bán được. Sử dụng lệnh RETURN để trả về trạng thái thành công hay thất bại của thủ tục.
		SELECT BusinessEntityID, SUM(sh.[TotalDue])
		FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.[SalesPersonID] = sp.BusinessEntityID
		WHERE sp.BusinessEntityID = 279
		GROUP BY BusinessEntityID

		---
		SELECT BusinessEntityID, sh.[TotalDue],sh.[SalesPersonID]
		FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.[SalesPersonID] = sp.BusinessEntityID
-------------
		CREATE PROCEDURE TongThu @manv INT, @tongtrigia MONEY OUTPUT
		AS
		BEGIN
			SET @tongtrigia =
			(
				SELECT SUM(sh.TotalDue)
				FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.SalesPersonID = sp.[BusinessEntityID]
				WHERE @manv = BusinessEntityID					
			)
		END
		GO
		DECLARE @tongtrigiaa MONEY
		EXEC TongThu 279, @tongtrigiaa OUTPUT
		PRINT @tongtrigiaa
--------------
		ALTER PROCEDURE TongThu @manv INT, @tongtrigia MONEY OUTPUT
		AS
		BEGIN
			SET @tongtrigia =
			(
				SELECT SUM(sh.TotalDue)
				FROM Sales.SalesOrderHeader sh JOIN Sales.SalesPerson sp ON sh.SalesPersonID = sp.[BusinessEntityID]
				WHERE @manv = BusinessEntityID					
			)
		END
		GO
		DECLARE @tongtrigiaa MONEY
		EXEC TongThu 279, @tongtrigiaa OUTPUT
		PRINT @tongtrigiaa
--7)	Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo năm đã cho.
		
--8)	Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin vào bảng Production.Product. 
--		Yêu cầu: chỉ thêm vào các trường có giá trị not null và các field là khóa ngoại.

--9)	Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader khi biết SalesOrderID. Lưu ý : trước khi
--		xóa mẫu tin trong Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong Sales.SalesOrderDetail.
 
--10)	Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên 10% nếu sản phẩm này tồn tại, ngược lại
--		hiện thông báo không có sản phẩm này.

