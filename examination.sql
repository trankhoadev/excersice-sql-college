-- *VIEW

--1)	Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có tổng tiền >70000, thông tin gồm SalesOrderID,
--		Orderdate, SubTotal, trong đó  =SUM(OrderQty*UnitPrice).
SELECT        Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate, SubTotal =  sum(Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty)
FROM          Sales.SalesOrderDetail INNER JOIN
              Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
where         month(Sales.SalesOrderHeader.OrderDate) = 6 and year(Sales.SalesOrderHeader.OrderDate) = 2008
Group by	  Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate


-- *FUNCTION

--1)	Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, giá trị truyền vào lấy từ field
--		[DepartmentID], hàm trả về số nhân viên trong phòng ban tương ứng. 
--		Áp dụng hàm đã viết vào câu truy vấn liệt
--		kê danh sách các phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name,
--		 countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--		(Dữ liệu lấy từ bảng [HumanResources].[EmployeeDepartmentHistory] và [HumanResources].[Department])
SELECT        HumanResources.Department.DepartmentID, HumanResources.Department.Name,count(HumanResources.EmployeeDepartmentHistory.DepartmentID) AS CountOfEmployees
FROM          HumanResources.Department INNER JOIN
              HumanResources.EmployeeDepartmentHistory ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID

group by	HumanResources.Department.DepartmentID, HumanResources.Department.Name

go 
create function CountOfEmployees(@mapb int) 
returns table 
as 
	return 
	(
		SELECT        HumanResources.Department.DepartmentID, HumanResources.Department.Name,count(HumanResources.EmployeeDepartmentHistory.DepartmentID) AS CountOfEmployees
		FROM          HumanResources.Department INNER JOIN
					  HumanResources.EmployeeDepartmentHistory ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID
		group by	HumanResources.Department.DepartmentID, HumanResources.Department.Name
		having      HumanResources.Department.DepartmentID = @mapb
	)

drop function CountOfEmployees

-- Thực thi 
declare @mapb int;
Set @mapb = 12;
select * from CountOfEmployees(@mapb);


-- *PROCEDURE
--1)	Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một tháng bất kỳ của một năm bất kỳ 
--		(tham số tháng và năm) được nhập từ bàn phím, thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
go
create procedure tinhtien
	(@thang int,
	@nam int)
as
begin
		SELECT        CustomerID, SumOfTotalDue = sum(TotalDue)
		FROM            Sales.SalesOrderHeader
		where         month(OrderDate) = @thang and year(OrderDate) = @nam
		group by		CustomerID	
end

-- thực thi
declare @thangTest int;
declare @namTest int;
set @thangTest = 7;
set @namTest = 2005;

if(exists(SELECT OrderDate FROM Sales.SalesOrderHeader where month(OrderDate) = @thangTest and year(OrderDate) = @namTest)) 
	exec tinhtien @thangTest, @namTest
else 
	print('Không tìm thấy thông tin cần tìm')

