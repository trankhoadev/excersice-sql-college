USE AdventureWorks2008R2
GO
--1)	Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm có ProductID=’778’;
--		nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có trên 500 đơn hàng”, ngược lại thì in ra chuỗi
--		“Sản phẩm 778 có ít đơn đặt hàng”
		SELECT ProductID, COUNT(SalesOrderID) AS CountOfID
		FROM Sales.SalesOrderDetail
		GROUP BY ProductID
--CACH 1:
		DECLARE @tongsoHD INT
		SELECT @tongsoHD = COUNT(SalesOrderID)
		FROM Sales.SalesOrderDetail
		WHERE ProductID = 707
		IF(@tongsoHD > 500)
			PRINT(N'Sản phẩm 778 có trên 500 đơn hàng')
		ELSE
			PRINT(N'Sản phẩm 778 có ít hơn 500 đơn hàng')
--CACH 2
		DECLARE @tongsoHD_1 INT
		DECLARE @productID INT
		SET		@productID = 707
		SET		@tongsoHD_1 = (SELECT COUNT(SalesOrderID) FROM Sales.SalesOrderDetail WHERE ProductID = @productID)
		IF(@tongsoHD_1 > 500)
			PRINT(N'Sản phẩm '+ CONVERT(VARCHAR(10), @productID) + N' có trên ' + CONVERT(VARCHAR(10), @tongsoHD_1))
		ELSE
			PRINT(N'Sản phẩm '+ CONVERT(VARCHAR(10), @productID) + N' có ít hơn ' + CONVERT(VARCHAR(10), @tongsoHD_1))
--2)	Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách hàng @makh, tham số @nam
--		chứa năm lập hóa đơn (ví dụ @nam=2008),   nếu @n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn
--		trong năm 2008” ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào trong năm
--		2008”
		SELECT sc.CustomerID, YEAR(sh.OrderDate) AS Year
		FROM Sales.Customer sc JOIN Sales.SalesOrderHeader sh ON sc.CustomerID = sh.CustomerID
		WHERE YEAR(sh.OrderDate) = 2008 
		GROUP BY sc.CustomerID, YEAR(sh.OrderDate)
--CACH 1:
		DECLARE @makh INT, @nam INT, @n INT
		SET @nam  = 2008
		SET @makh = 30039
		SELECT @n = COUNT(SalesOrderID)
		FROM Sales.SalesOrderHeader
		WHERE YEAR(OrderDate) = @nam AND CustomerID = @makh
		IF(@n > 0)
			PRINT(N'Khách hàng '+ CONVERT(VARCHAR(10),@makh) + ' có ' +CONVERT(VARCHAR(10),@n) + ' hoá đơn nào trong năm ' + CONVERT(VARCHAR(10),@nam))
		ELSE
			PRINT(N'Khách hàng '+ CONVERT(VARCHAR(10),@makh) + ' không có hoá đơn nào trong năm ' + CONVERT(VARCHAR(10),@nam))
--CACH 2:
		DECLARE @makh1 INT, @n1 INT, @nam1 INT
		SET @makh1 = 300392
		SET @nam1  = 2008
		SET @n1	   = (SELECT COUNT(CustomerID) FROM Sales.SalesOrderHeader sh WHERE CustomerID = @makh1 AND YEAR(OrderDate) = @nam1)
		IF(@n1 > 0)	
			PRINT(N'Khách hàng ' + CONVERT(VARCHAR(10), @makh1) + N' có ' + CONVERT(VARCHAR(10), @n1) + N' hoá đơn trong năm ' + CONVERT(VARCHAR(10), @nam1))
		ELSE
			PRINT(N'Khách hàng ' + CONVERT(VARCHAR(10), @makh1) + N' không có hoá đơn nào trong năm ' + CONVERT(VARCHAR(10), @nam1))
--3)	Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng tiền>100000, thông tin
--		gồm [SalesOrderID], SubTotal=SUM([LineTotal]), Discount (tiền giảm), với Discount được tính như sau:
--		•	Những hóa đơn có SubTotal<100000 thì không giảm,
--		•	SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
--		•	SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
--		•	SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
--		(Gợi ý: Dùng cấu trúc Case… When …Then …)
--CACH 1:
		SELECT  SalesOrderID, SUM(LineTotal) AS SumTotal,
				DISCOUNT = CASE
								WHEN SUM(LineTotal) < 100000 THEN 0
								WHEN SUM(LineTotal) BETWEEN 100000 AND 120000 THEN SUM(LineTotal)*0.05
								WHEN SUM(LineTotal) BETWEEN 120000 AND 150000 THEN SUM(LineTotal)*0.1
								WHEN SUM(LineTotal) > 150000 THEN SUM(LineTotal)*0.15
							END
		FROM Sales.SalesOrderDetail
		GROUP BY SalesOrderID
		HAVING SUM(LineTotal) > 100000
--CACH 2:
		
--4)	Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của các field [ProductID],
--		[BusinessEntityID],[OnOrderQty], với giá trị truyền cho các biến @mancc, @masp (vd: @mancc=1650, @masp=4),
--		thì chương trình sẽ gán  giá  trị  tương  ứng  của  field  [OnOrderQty]  cho  biến  @soluongcc,  nếu
--		@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung cấp sản phẩm 4”, ngược lại
--		(vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 cung cấp sản phẩm 4 với số lượng là 5”
--		(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
--CACH 1:
		DECLARE @macc		INT,
				@masp		INT, 
				@soluongcc	INT
		SET @macc		= 1650
		SET @masp		= 4
		SELECT @soluongcc = OnOrderQty
		FROM Purchasing.ProductVendor p
		WHERE BusinessEntityID = @macc AND ProductID = @masp
			IF(@soluongcc IS NULL)
				PRINT(N'Nhà cung cấp ' + CONVERT(VARCHAR(10), @macc) +  N' không cung cấp sản phẩm ' + CONVERT(VARCHAR(10), @masp) )
			ELSE
				PRINT(N' Nhà cung cấp ' + CONVERT(VARCHAR(10), @macc) + N' cunng cấp sản phẩm '+ CONVERT(VARCHAR(10), @masp) + N' với số lượng là ' + CONVERT(VARCHAR(10), @soluongcc)) 
--CACH 2:
		DECLARE @macc1 INT,
				@masp1 INT
				@soluongcc INT

--5)	Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong [HumanResources].[EmployeePayHistory]
--		theo điều kiện sau: Khi tổng lương giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.
		WHILE (SELECT SUM(rate) FROM
		[HumanResources].[EmployeePayHistory])<6000 BEGIN
		UPDATE [HumanResources].[EmployeePayHistory] SET rate = rate*1.1
		IF (SELECT MAX(rate)FROM
		[HumanResources].[EmployeePayHistory]) > 150 BREAK
		ELSE
		CONTINUE
		END
