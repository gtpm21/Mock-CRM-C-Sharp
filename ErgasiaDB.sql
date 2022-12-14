USE [master]
GO
/****** Object:  Database [ErgasiaDB]    Script Date: 22/6/2022 1:07:53 πμ ******/
CREATE DATABASE [ErgasiaDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ErgasiaDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\ErgasiaDB.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ErgasiaDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\ErgasiaDB_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [ErgasiaDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ErgasiaDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ErgasiaDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ErgasiaDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ErgasiaDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ErgasiaDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ErgasiaDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [ErgasiaDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ErgasiaDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [ErgasiaDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ErgasiaDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ErgasiaDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ErgasiaDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ErgasiaDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ErgasiaDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ErgasiaDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ErgasiaDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ErgasiaDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ErgasiaDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ErgasiaDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ErgasiaDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ErgasiaDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ErgasiaDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ErgasiaDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ErgasiaDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ErgasiaDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ErgasiaDB] SET  MULTI_USER 
GO
ALTER DATABASE [ErgasiaDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ErgasiaDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ErgasiaDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ErgasiaDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [ErgasiaDB]
GO
/****** Object:  UserDefinedFunction [dbo].[calc_days_worked]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[calc_days_worked] (@sd date, @ed date)
returns int
as
begin
	declare @result int
	DECLARE @StartDate DATETIME
	DECLARE @EndDate DATETIME
	SET @StartDate = @sd
	SET @EndDate = @ed

	if @EndDate is null
	begin
		set @result = 
	   (DATEDIFF(dd, @StartDate, GETDATE()) + 1)
	  -(DATEDIFF(wk, @StartDate, GETDATE()) * 2)
	  -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
	  -(CASE WHEN DATENAME(dw, GETDATE()) = 'Saturday' THEN 1 ELSE 0 END)
	end
	else
	begin
		set @result = 
	   (DATEDIFF(dd, @StartDate, @EndDate) + 1)
	  -(DATEDIFF(wk, @StartDate, @EndDate) * 2)
	  -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
	  -(CASE WHEN DATENAME(dw, @EndDate) = 'Saturday' THEN 1 ELSE 0 END)
	end

	return @result
end
GO
/****** Object:  UserDefinedFunction [dbo].[calc_net_salary]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[calc_net_salary]
(
	@smm numeric(18,2)
)
RETURNS numeric(18,2)
AS
BEGIN

	DECLARE @ResultVar numeric (18,2), @tax numeric (18,2)

	set @smm = @smm - (@smm *(6.67/100.00))
	set @smm = @smm * 14

	if @smm <= 10000
		begin
			set @tax = @smm * (9.00 / 100.00)
		end
	else if @smm <= 20000
		begin
			set @tax = (((@smm - 10000) * (22.00 / 100.00)) + 900)
		end
	else if @smm <= 30000
		begin
			set @tax = (((@smm - 20000) * (28.00 / 100.00)) + 3100)
		end
	else if @smm <= 40000
		begin
			set @tax = (((@smm - 30000) * (36.00 / 100.00)) + 5900)
		end
	else
		begin
			set @tax = (((@smm - 40000) * (44.00 / 100.00)) + 9500)
		end

	set @smm = @smm - @tax

	set @ResultVar = @smm / 14

	RETURN @ResultVar

END

GO
/****** Object:  UserDefinedFunction [dbo].[calc_tax]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[calc_tax] (@pay numeric)
returns numeric (18,2)
as
begin
	declare @result numeric (18,2)

	set @pay = (@pay - (@pay * (6.67)/(100.00))) * 14

	if @pay <= 10000
		begin
			set @result = @pay * (9.00 / 100.00)
		end
	else if @pay <= 20000
		begin
			set @result = (((@pay - 10000) * (22.00 / 100.00)) + 900)
		end
	else if @pay <= 30000
		begin
			set @result = (((@pay - 20000) * (28.00 / 100.00)) + 3100)
		end
	else if @pay <= 40000
		begin
			set @result = (((@pay - 30000) * (36.00 / 100.00)) + 5900)
		end
	else
		begin
			set @result = (((@pay - 40000) * (44.00 / 100.00)) + 9500)
		end

	return @result
end;


GO
/****** Object:  UserDefinedFunction [dbo].[fnc_calc_staff_num]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnc_calc_staff_num] (@dept_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @result int;
	SELECT @result = COUNT(dept_id) 
	FROM dbo.tbl_employees 
	WHERE @dept_id = tbl_employees.dept_id AND tbl_employees.is_active = 1;
RETURN @result;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[yearly_income_calc]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[yearly_income_calc](@pay DECIMAL, @rate INT, @days INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
	DECLARE @result DECIMAL
IF @rate = 1
	BEGIN
		SET @result = @pay * 8 * 22 * 14
	END
ELSE IF @rate = 2
	BEGIN
		SET @result = @pay * 22 * 14
	END
ELSE IF @rate = 3
	BEGIN
		SET @result = @pay * 14
	END
RETURN @result	
END
GO
/****** Object:  Table [dbo].[tbl_departments]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_departments](
	[dept_id] [int] IDENTITY(1,1) NOT NULL,
	[dept_name] [varchar](50) NOT NULL,
	[manager_id] [int] NOT NULL,
	[staff_num]  AS ([dbo].[fnc_calc_staff_num]([dept_id])),
 CONSTRAINT [PK_tbl_departments] PRIMARY KEY CLUSTERED 
(
	[dept_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_employees]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_employees](
	[employee_id] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[email] [varchar](50) NOT NULL,
	[phone] [int] NOT NULL,
	[DOB] [date] NULL,
	[hire_date] [date] NOT NULL,
	[dept_id] [int] NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [DF_tbl_employees_is_active]  DEFAULT ((1)),
	[date_set_inactive] [datetime] NULL CONSTRAINT [DF__tbl_emplo__date___70A8B9AE]  DEFAULT (NULL),
	[rate] [int] NULL,
	[salary_monthly] [numeric](18, 2) NULL,
 CONSTRAINT [PK_tbl_employees] PRIMARY KEY CLUSTERED 
(
	[employee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_off_history]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_off_history](
	[emp_id] [int] NOT NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[days_worked]  AS ([dbo].[calc_days_worked]([start_date],[end_date])),
	[days_off_with_pay] [int] NOT NULL CONSTRAINT [DF_Table_1_days_off]  DEFAULT ((0)),
	[days_off_without_pay] [int] NOT NULL CONSTRAINT [DF_Payroll_days_off_wthout_pay]  DEFAULT ((0)),
	[parental_leave] [int] NOT NULL CONSTRAINT [DF_Payroll_parental_leave]  DEFAULT ((0)),
	[sick_leave] [int] NOT NULL CONSTRAINT [DF_Payroll_sick_leave]  DEFAULT ((0)),
	[days_off_total]  AS ((([days_off_with_pay]+[days_off_without_pay])+[parental_leave])+[sick_leave]),
 CONSTRAINT [PK_tbl_payroll] PRIMARY KEY CLUSTERED 
(
	[emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_payroll_details]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_payroll_details](
	[id] [int] NOT NULL,
	[rate] [int] NULL,
	[salary_yearly]  AS ([salary_monthly_mixed]*(14)),
	[salary_monthly_mixed] [numeric](18, 2) NULL,
	[insurance_fee]  AS (CONVERT([numeric](18,2),[salary_monthly_mixed]*((6.67)/(100)))),
	[sal_mixed_before_tax]  AS (CONVERT([numeric](18,2),[salary_monthly_mixed]-[salary_monthly_mixed]*((6.67)/(100)))),
	[tax]  AS ([dbo].[calc_tax]([salary_monthly_mixed])),
	[net_salary]  AS ([dbo].[calc_net_salary]([salary_monthly_mixed])),
	[employee_tax]  AS (CONVERT([numeric](18,2),[salary_monthly_mixed]*((13.33)/(100)))),
	[employee_cost_total]  AS (CONVERT([numeric](18,2),[salary_monthly_mixed]+[salary_monthly_mixed]*((13.33)/(100)))),
 CONSTRAINT [PK__tbl_payr__3213E83F4624B970] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_rates]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_rates](
	[rate_id] [int] IDENTITY(1,1) NOT NULL,
	[rate_title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_rates] PRIMARY KEY CLUSTERED 
(
	[rate_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_sysAdmins]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_sysAdmins](
	[admin_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_sysAdmins] PRIMARY KEY CLUSTERED 
(
	[admin_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[v_main_employees]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_main_employees] as
select employee_id ,firstname ,lastname ,email ,phone ,DOB, hire_date, dept_name
from tbl_employees as empl, tbl_departments as depts
where empl.is_active = 1 AND empl.dept_id = depts.dept_id
GO
/****** Object:  View [dbo].[v_main_employees_inactive]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_main_employees_inactive] as
select employee_id ,firstname ,lastname ,email ,phone ,DOB, hire_date, dept_name, date_set_inactive
from tbl_employees as empl, tbl_departments as depts
where empl.is_active = 0 AND empl.dept_id = depts.dept_id
GO
/****** Object:  View [dbo].[v_sal_b4_tax]    Script Date: 22/6/2022 1:07:53 πμ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_sal_b4_tax] as
select sal_mixed_before_tax
from tbl_payroll_details
GO
SET IDENTITY_INSERT [dbo].[tbl_departments] ON 

INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (1, N'Management', 3)
INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (2, N'Accounting', 2)
INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (3, N'Sales', 1008)
INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (4, N'Marketing', 14)
INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (5, N'IT', 1018)
INSERT [dbo].[tbl_departments] ([dept_id], [dept_name], [manager_id]) VALUES (6, N'HR', 1030)
SET IDENTITY_INSERT [dbo].[tbl_departments] OFF
SET IDENTITY_INSERT [dbo].[tbl_employees] ON 

INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1, N'John', N'Smith', N'smith@gmail.com', 12345, CAST(N'1990-03-15' AS Date), CAST(N'2020-03-03' AS Date), 2, 0, CAST(N'2022-06-13 23:32:50.807' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (2, N'Jack', N'Black', N'black@hotmail.com', 987676, CAST(N'1994-12-05' AS Date), CAST(N'2019-09-05' AS Date), 3, 1, NULL, 3, CAST(1800.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (3, N'Homer', N'Simpson', N'simp@yahoo.com', 1234566, CAST(N'1960-06-06' AS Date), CAST(N'2016-06-25' AS Date), 1, 1, NULL, NULL, CAST(1700.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (4, N'Rose', N'Wallas', N'wallas@trimail.net', 12345, CAST(N'2000-04-07' AS Date), CAST(N'2021-01-04' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (14, N'dwe', N'fwefw', N'sdffs', 324324, CAST(N'1990-05-01' AS Date), CAST(N'2020-01-04' AS Date), 6, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (15, N'edgf', N'gersg', N'segrsg', 35356, CAST(N'1200-02-02' AS Date), CAST(N'1699-05-05' AS Date), 4, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1004, N'btrs', N'gstr', N'ggst', 453, CAST(N'1999-01-01' AS Date), CAST(N'2000-02-02' AS Date), 4, 0, CAST(N'2022-06-19 21:07:51.483' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1005, N'vdrfv', N'vsdf', N'vsdf', 4455, CAST(N'1000-01-01' AS Date), CAST(N'2000-02-02' AS Date), 6, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1006, N'geg', N'gerw', N'regedg', 5467, CAST(N'1900-05-05' AS Date), CAST(N'2000-05-05' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1008, N'fdv', N'sdvf', N'sfvd', 234, CAST(N'1995-09-09' AS Date), CAST(N'2005-08-08' AS Date), 3, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1010, N'vgbsd', N'dfgsgsdf', N'sdg', 435, CAST(N'1990-05-05' AS Date), CAST(N'2020-05-05' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1013, N'er', N'reg', N'er', 43, CAST(N'1999-05-05' AS Date), CAST(N'2020-05-05' AS Date), 3, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1014, N'twre', N'wtr', N'wert', 456, CAST(N'1999-05-05' AS Date), CAST(N'2000-09-09' AS Date), 2, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1017, N'dbsfr', N'sdgf', N'gst54t', 54, CAST(N'1999-09-09' AS Date), CAST(N'2000-05-05' AS Date), 3, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1018, N'eh', N'ehye', N'eyh', 553453, CAST(N'2000-05-05' AS Date), CAST(N'2000-05-05' AS Date), 5, 0, CAST(N'2022-06-13 22:56:31.983' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1019, N'dfbgdbfg', N'bdgfbdfgb', N'gfbdb', 456345, CAST(N'2000-05-05' AS Date), CAST(N'2000-05-05' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1021, N'csd', N'cds', N'dcs', 32, CAST(N'2000-09-09' AS Date), CAST(N'2000-09-09' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1022, N'gfdb', N'dbgf', N'dbfg', 453, CAST(N'1990-05-05' AS Date), CAST(N'1990-05-05' AS Date), 3, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1023, N'yuj', N'nh', N'fgnh', 456, CAST(N'2000-05-05' AS Date), CAST(N'2000-05-05' AS Date), 1, 1, NULL, NULL, CAST(900.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1025, N'fv', N'sdf', N'hfdhdf', 456, CAST(N'2000-09-09' AS Date), CAST(N'2000-09-09' AS Date), 1, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1027, N'fv', N'sdf', N'hfdhdf', 456, CAST(N'2000-09-09' AS Date), CAST(N'2000-09-09' AS Date), 5, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1028, N'bfxbfg', N'gfxbfx', N'xdfbdzb', 3464535, CAST(N'1990-05-05' AS Date), CAST(N'2018-02-03' AS Date), 1, 1, NULL, NULL, CAST(1200.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1029, N'bfxbfg', N'gfxbfx', N'xdfbdzb', 3464535, CAST(N'1990-05-05' AS Date), CAST(N'2018-02-03' AS Date), 4, 0, CAST(N'2022-06-13 22:58:10.480' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1030, N'bfxbfg', N'gfxbfx', N'xdfbdzb', 3464535, CAST(N'1990-05-05' AS Date), CAST(N'2018-02-03' AS Date), 4, 0, CAST(N'2022-06-13 23:07:56.490' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1031, N'bfxbfg', N'gfxbfx', N'xdfbdzb', 3464535, CAST(N'1990-05-05' AS Date), CAST(N'2018-02-03' AS Date), 1, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1032, N'bfxbfg', N'gfxbfx', N'xdfbdzb', 3464535, CAST(N'1990-05-05' AS Date), CAST(N'2018-02-03' AS Date), 1, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1033, N'hdf', N'rth', N'hdtyhd', 3456, CAST(N'2000-05-05' AS Date), CAST(N'2019-05-09' AS Date), 3, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1034, N'hdf', N'rth', N'hdtyhd', 3456, CAST(N'2000-05-05' AS Date), CAST(N'2019-05-09' AS Date), 5, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1035, N'hdf', N'rth', N'hdtyhd', 3456, CAST(N'2000-05-05' AS Date), CAST(N'2019-05-09' AS Date), 6, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1036, N'hdf', N'rth', N'hdtyhd', 3456, CAST(N'2000-05-05' AS Date), CAST(N'2019-05-09' AS Date), 6, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1037, N'frr', N'dw', N'ewfef', 4534646, CAST(N'2000-03-03' AS Date), CAST(N'2019-05-05' AS Date), 2, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1038, N'bdbdb', N'fbdffbdf', N'fbdfbfbf', 4435, CAST(N'2000-03-03' AS Date), CAST(N'2018-06-06' AS Date), 1, 0, CAST(N'2022-06-13 22:53:04.360' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1040, N'ebrtr', N'gtwgt', N'gwtgtr3435', 345345, CAST(N'2000-08-08' AS Date), CAST(N'2020-09-09' AS Date), 2, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1042, N'gdfgd', N'fnhgfn', N'dgdfsdfgdg', 3453464, CAST(N'1998-07-06' AS Date), CAST(N'2019-02-13' AS Date), 4, 0, CAST(N'2022-06-18 20:34:38.227' AS DateTime), NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1043, N'dgdfgd', N'fnfgjfg', N'fhdfhfjf', 4565475, CAST(N'2000-08-09' AS Date), CAST(N'2015-08-07' AS Date), 3, 1, NULL, NULL, NULL)
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1044, N'ghbgcfbd', N'gdfgdgdsfh', N'ghfdsdgfhf', 467367473, CAST(N'1980-07-06' AS Date), CAST(N'2017-06-07' AS Date), 1, 1, NULL, 3, CAST(1000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1046, N'wrewg', N'gerger', N'gewrger', 53453, CAST(N'2000-09-09' AS Date), CAST(N'2015-09-09' AS Date), 2, 1, NULL, 2, CAST(500.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1047, N'fgndbd', N'hgjfyg', N'jghngcf', 46764, CAST(N'1995-09-09' AS Date), CAST(N'1999-09-09' AS Date), 6, 1, NULL, 1, CAST(800.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1051, N'David ', N'Jones', N'jones@yahoo.com', 123123123, CAST(N'1999-01-12' AS Date), CAST(N'2006-05-05' AS Date), 6, 1, NULL, 3, CAST(1000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1052, N'bbbbbbb', N'vdfsdvsdfv', N'vsdfvsdf', 344664535, CAST(N'1990-08-08' AS Date), CAST(N'2021-05-05' AS Date), 5, 1, NULL, 2, CAST(1100.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1053, N'lolol', N'lolol', N'lolololo', 1234145, CAST(N'1995-08-08' AS Date), CAST(N'2019-09-24' AS Date), 5, 1, NULL, 3, CAST(2000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1056, N'zzzzzzz', N'zzzzz', N'zzzzz', 234514, CAST(N'2000-09-09' AS Date), CAST(N'2020-09-09' AS Date), 4, 0, CAST(N'2022-06-22 00:27:12.677' AS DateTime), 1, CAST(13200.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_employees] ([employee_id], [firstname], [lastname], [email], [phone], [DOB], [hire_date], [dept_id], [is_active], [date_set_inactive], [rate], [salary_monthly]) VALUES (1057, N'xxxx', N'xxxxx', N'xxxxxx', 123123123, CAST(N'1990-08-08' AS Date), CAST(N'2021-06-06' AS Date), 4, 1, NULL, 2, CAST(1056.00 AS Numeric(18, 2)))
SET IDENTITY_INSERT [dbo].[tbl_employees] OFF
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1, CAST(N'2020-03-05' AS Date), CAST(N'2022-06-13' AS Date), 5, 0, 2, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1004, CAST(N'2000-05-05' AS Date), CAST(N'2022-06-19' AS Date), 0, 3, 0, 3)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1042, CAST(N'2015-05-13' AS Date), CAST(N'2022-06-18' AS Date), 0, 0, 0, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1043, CAST(N'2015-08-07' AS Date), NULL, 0, 0, 0, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1044, CAST(N'2017-06-07' AS Date), NULL, 0, 0, 0, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1046, CAST(N'2015-09-09' AS Date), NULL, 0, 0, 0, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1047, CAST(N'1999-09-09' AS Date), NULL, 3, 0, 3, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1051, CAST(N'2006-05-05' AS Date), NULL, 0, 5, 0, 2)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1052, CAST(N'2021-05-05' AS Date), NULL, 2, 1, 1, 1)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1053, CAST(N'2019-09-24' AS Date), NULL, 1, 2, 0, 8)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1056, CAST(N'2020-09-09' AS Date), CAST(N'2022-06-22' AS Date), 0, 0, 0, 0)
INSERT [dbo].[tbl_off_history] ([emp_id], [start_date], [end_date], [days_off_with_pay], [days_off_without_pay], [parental_leave], [sick_leave]) VALUES (1057, CAST(N'2021-06-06' AS Date), NULL, 0, 0, 0, 0)
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1004, 2, CAST(1000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1046, 1, CAST(1200.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1047, 2, CAST(800.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1048, 1, CAST(1000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1049, 3, CAST(1400.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1051, 3, CAST(1000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1052, 2, CAST(1100.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1053, 3, CAST(2000.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1056, 1, CAST(13200.00 AS Numeric(18, 2)))
INSERT [dbo].[tbl_payroll_details] ([id], [rate], [salary_monthly_mixed]) VALUES (1057, 2, CAST(1056.00 AS Numeric(18, 2)))
SET IDENTITY_INSERT [dbo].[tbl_rates] ON 

INSERT [dbo].[tbl_rates] ([rate_id], [rate_title]) VALUES (1, N'hourly')
INSERT [dbo].[tbl_rates] ([rate_id], [rate_title]) VALUES (2, N'daily')
INSERT [dbo].[tbl_rates] ([rate_id], [rate_title]) VALUES (3, N'indefinite')
SET IDENTITY_INSERT [dbo].[tbl_rates] OFF
SET IDENTITY_INSERT [dbo].[tbl_sysAdmins] ON 

INSERT [dbo].[tbl_sysAdmins] ([admin_id], [username], [password]) VALUES (1, N'admin', N'admin')
SET IDENTITY_INSERT [dbo].[tbl_sysAdmins] OFF
ALTER TABLE [dbo].[tbl_employees]  WITH CHECK ADD  CONSTRAINT [FK_tbl_employees_tbl_departments] FOREIGN KEY([dept_id])
REFERENCES [dbo].[tbl_departments] ([dept_id])
GO
ALTER TABLE [dbo].[tbl_employees] CHECK CONSTRAINT [FK_tbl_employees_tbl_departments]
GO
ALTER TABLE [dbo].[tbl_employees]  WITH CHECK ADD  CONSTRAINT [FK_tbl_employees_tbl_rates] FOREIGN KEY([rate])
REFERENCES [dbo].[tbl_rates] ([rate_id])
GO
ALTER TABLE [dbo].[tbl_employees] CHECK CONSTRAINT [FK_tbl_employees_tbl_rates]
GO
ALTER TABLE [dbo].[tbl_off_history]  WITH CHECK ADD  CONSTRAINT [FK_tbl_payroll_history_tbl_employees] FOREIGN KEY([emp_id])
REFERENCES [dbo].[tbl_employees] ([employee_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbl_off_history] CHECK CONSTRAINT [FK_tbl_payroll_history_tbl_employees]
GO
ALTER TABLE [dbo].[tbl_payroll_details]  WITH CHECK ADD  CONSTRAINT [FK__tbl_payrol__rate__1D7B6025] FOREIGN KEY([rate])
REFERENCES [dbo].[tbl_rates] ([rate_id])
GO
ALTER TABLE [dbo].[tbl_payroll_details] CHECK CONSTRAINT [FK__tbl_payrol__rate__1D7B6025]
GO
USE [master]
GO
ALTER DATABASE [ErgasiaDB] SET  READ_WRITE 
GO
