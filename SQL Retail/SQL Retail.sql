
-- Создание таблиц:

-- Таблица заказов:
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate NCHAR(8) NOT NULL,
    OrderState NVARCHAR(9) CHECK (OrderState IN ('Fulfilled', 'Cancelled')) NOT NULL,
    DeliveryDays TINYINT CHECK (DeliveryDays IS NULL OR DeliveryDays >= 0)
);

-- Таблица состава заказов:
CREATE TABLE Order_List (
    OrderID INT,
    SKU INT,
    Quantity TINYINT NOT NULL,
    Price INT NOT NULL,
    PRIMARY KEY (OrderID, SKU),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- Таблица клиентов:
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CityID INT DEFAULT 1
);

-- Таблица регионов:
CREATE TABLE City_Region (
    CityID INT PRIMARY KEY,
    Region NVARCHAR(7) CHECK (Region IN ('Central', 'North', 'South', 'East', 'West')) NOT NULL
);

-----------------------------------
DELETE FROM Order_List;
DELETE FROM Orders;
DELETE FROM Customers;
DELETE FROM City_Region;
-----------------------------------
-- Наполнение таблиц данными
INSERT INTO City_Region (CityID, Region) VALUES
    (1, 'Central'),
    (2, 'North'),
    (3, 'South'),
    (4, 'East'),
    (5, 'West'),
    (6, 'Central'),
    (7, 'Central'),
    (8, 'Central');

INSERT INTO Customers (CustomerID, CityID) VALUES
    (101, 2), (102, 3), (103, 1), (104, 5), (105, 1), (106, 4), (107, 2), (108, 3),
    (109, 6), (110, 7), (111, 1), (112, 8), (113, 6), (114, 7), (115, 1);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, OrderState, DeliveryDays) VALUES
    (1, 101, '20180101', 'Fulfilled', 2), (2, 102, '20180115', 'Cancelled', NULL),
    (3, 103, '20180203', 'Fulfilled', 1), (4, 104, '20180204', 'Fulfilled', 0),
    (5, 105, '20180305', 'Fulfilled', 3), (6, 106, '20180306', 'Cancelled', NULL),
    (7, 107, '20180407', 'Fulfilled', 2), (8, 108, '20180408', 'Fulfilled', 1),
    (9, 110, '20180131', 'Fulfilled', 2), (10, 111, '20180108', 'Fulfilled', 1),
    (11, 109, '20180109', 'Fulfilled', 1), (12, 112, '20180112', 'Cancelled', 1),
    (13, 113, '20180205', 'Fulfilled', 2), (14, 114, '20180218', 'Fulfilled', 3),
    (15, 115, '20180302', 'Fulfilled', 1), (16, 101, '20180412', 'Fulfilled', 2),
    (17, 102, '20180515', 'Fulfilled', 1), (18, 103, '20180520', 'Fulfilled', 2),  
    (19, 101, '20180302', 'Fulfilled', 1), (20, 101, '20180412', 'Fulfilled', 2),
    (21, 103, '20180515', 'Fulfilled', 1), (22, 115, '20180520', 'Fulfilled', 2),
    (23, 113, '20180206', 'Fulfilled', 2), (24, 114, '20180219', 'Fulfilled', 1),
    (25, 115, '20180309', 'Fulfilled', 5), (26, 101, '20180418', 'Fulfilled', 7),
    (27, 116, '20180105', 'Fulfilled', 3), (28, 117, '20180120', 'Fulfilled', 2),
    (29, 118, '20180202', 'Fulfilled', 1), (30, 119, '20180210', 'Fulfilled', 3),
    (31, 120, '20180215', 'Fulfilled', 1), (32, 121, '20180222', 'Fulfilled', 2),
    (33, 122, '20180227', 'Fulfilled', 2), (34, 123, '20180305', 'Cancelled', 2), 
    (35, 124, '20180310', 'Fulfilled', 1),
    (36, 125, '20180318', 'Fulfilled', 3), (37, 126, '20180322', 'Fulfilled', 2),
    (38, 127, '20180328', 'Fulfilled', 1),
    (39, 128, '20180407', 'Fulfilled', 3), (40, 129, '20180414', 'Cancelled', 2),
    (41, 130, '20180421', 'Fulfilled', 1),
    (42, 131, '20181202', 'Fulfilled', 1), (43, 132, '20181210', 'Fulfilled', 2),
    (44, 133, '20181215', 'Fulfilled', 3), (45, 134, '20181220', 'Fulfilled', 2),
    (46, 135, '20181225', 'Fulfilled', 1), (47, 136, '20181228', 'Fulfilled', 2),
    (48, 137, '20181230', 'Fulfilled', 1),
    (49, 101, '20180105', 'Fulfilled', 2), (50, 103, '20180107', 'Fulfilled', 1),
    (51, 104, '20180110', 'Fulfilled', 3), (52, 105, '20180112', 'Fulfilled', 2),
    (53, 106, '20180114', 'Fulfilled', 1), (54, 107, '20180116', 'Cancelled', NULL),
    (55, 108, '20180120', 'Fulfilled', 1), (56, 109, '20180123', 'Fulfilled', 2),
    (57, 110, '20180125', 'Fulfilled', 3), (58, 111, '20180127', 'Fulfilled', 1),
    (59, 112, '20180202', 'Fulfilled', 2), (60, 113, '20180204', 'Fulfilled', 1),
    (61, 114, '20180206', 'Fulfilled', 3), (62, 115, '20180208', 'Cancelled', NULL),
    (63, 116, '20180210', 'Fulfilled', 2), (64, 117, '20180212', 'Fulfilled', 1),
    (65, 118, '20180214', 'Fulfilled', 3), (66, 119, '20180216', 'Fulfilled', 1),
    (67, 120, '20180218', 'Fulfilled', 2), (68, 121, '20180220', 'Fulfilled', 2),
	(69, 113, '20180304', 'Fulfilled', 1), (70, 117, '20180312', 'Fulfilled', 1),
	(71, 103, '20180307', 'Fulfilled', 1), (72, 120, '20180315', 'Fulfilled', 1), 
	(73, 121, '20180322', 'Fulfilled', 2);

INSERT INTO Order_List (OrderID, SKU, Quantity, Price) VALUES
    (1, 1001, 2, 500), (1, 1002, 1, 1500), (1, 1003, 2, 500),
    (3, 1003, 3, 700), (4, 1004, 1, 2000), (4, 1005, 2, 1000),
    (5, 1006, 4, 800), (5, 1007, 1, 1200), (6, 1008, 2, 900),
    (7, 1009, 3, 750), (8, 1010, 5, 650), (9, 1007, 1, 1200),
    (10, 1008, 1, 900), (11, 1009, 1, 750), (11, 1003, 1, 750),
    (12, 1010, 2, 650), (13, 1001, 3, 500), (14, 1002, 1, 1500),
    (15, 1003, 2, 500), (16, 1004, 4, 700), (17, 1005, 2, 1000),
    (18, 1006, 3, 800), (18, 1007, 2, 1200), 
    (19, 1004, 1, 700), (20, 1005, 1, 1000),
    (21, 1006, 1, 800), (22, 1007, 2, 1200),
    (23, 1006, 3, 800), (24, 1007, 2, 1200), 
    (25, 1004, 1, 700), (26, 1005, 1, 1000),
    (27, 1011, 1, 600), (28, 1012, 2, 750),
    (29, 1013, 3, 900), (29, 1012, 3, 900), (29, 1015, 3, 900), 
    (30, 1014, 2, 1200), (31, 1015, 1, 500),
    (32, 1016, 2, 1100), (33, 1017, 1, 1300), (33, 1016, 1, 1300),
    (34, 1018, 2, 1400), (35, 1019, 1, 800), (36, 1020, 3, 950),
    (37, 1021, 2, 700), (38, 1022, 1, 600), 
    (39, 1023, 2, 1500), (40, 1024, 1, 950), (41, 1025, 3, 1100),
    (42, 1026, 5, 700), (42, 1027, 2, 700), (42, 1028, 5, 700),
    (43, 1027, 2, 1250), (44, 1028, 3, 1300), (44, 1029, 2, 1300),
    (45, 1029, 1, 750), (46, 1030, 4, 850), (46, 1029, 2, 850),
    (47, 1031, 3, 900), (47, 1030, 1, 900), (48, 1032, 4, 1000),
    (49, 1011, 1, 600), (49, 1012, 2, 750),
    (50, 1013, 1, 900), (50, 1014, 2, 1000),
    (51, 1015, 1, 800), (51, 1016, 3, 1100),
    (52, 1017, 1, 1300), (52, 1018, 2, 1400),
    (53, 1019, 3, 1500), (53, 1020, 2, 900),
    (54, 1021, 1, 750), (55, 1022, 2, 850),
    (56, 1023, 3, 1000), (57, 1024, 2, 1200),
    (58, 1025, 1, 950), (59, 1026, 4, 1100),
    (60, 1027, 3, 950), (61, 1028, 1, 1250),
    (62, 1029, 2, 1300), (63, 1030, 5, 900),
    (64, 1031, 3, 800), (65, 1032, 1, 1000),
    (66, 1033, 2, 850), (67, 1034, 3, 1100),
    (68, 1035, 2, 900),
    (69, 1011, 1, 600), (69, 1012, 2, 750),
    (70, 1013, 1, 900), (70, 1014, 2, 1000),
    (71, 1015, 1, 800), (71, 1016, 3, 1100),
    (72, 1017, 1, 1300), (72, 1018, 2, 1400),
    (73, 1019, 3, 1500), (73, 1020, 2, 900);

-----------------------------------------------------

select *
from City_Region
  
select *
from Customers

select *
from Orders

select *
from Order_List

-----------------------------------------------------

-- 1. Запрос, который показывает количество выполненных заказов с X SKU в заказе (шт.)
-- Х - число различных (уникальных) SKU в заказе; X принимает значения из множества {1, 2, 3, 4, 5 …}.

with Amount as (
select OrderID, count(DISTINCT(SKU)) as 'Колличесво'
from Order_List
group BY OrderID)
	
select
	Колличесво as 'Колво уникальных SKU',
	count(*) as 'Количество заказов'
from Amount
group by Колличесво
order by Колличесво;


-- Оптимизированный вариант:
SELECT 
    SKU_Count AS "Колво уникальных SKU", 
    COUNT(*) AS "Количество заказов"
FROM (
    SELECT OrderID, COUNT(DISTINCT SKU) AS SKU_Count
    FROM Order_List
    GROUP BY OrderID
) AS OrderSKU
GROUP BY SKU_Count
ORDER BY SKU_Count;
	
-----------------------------------------------------	
	
-- 2 SQL-запрос, выводящий среднюю стоимость покупки (завершенный заказ)
-- за все время клиентов из центрального региона ("Central")
-- совершивших и получивших первую покупку в январе 2018 года.
-- Результаты предоставить в разбивке по городам.


with Prices as (
select
	sum(Quantity * Price) as Total_price, OrderID
from
	Order_List
group by
	OrderID)
select
	City_Region.CityID , avg(Prices.Total_price)
from
	Prices
join orders on
	Orders.OrderID = Prices.OrderID
join Customers on
	Customers.CustomerID = Orders.CustomerID
join City_Region on
	City_Region.CityID = Customers.CityID
where
	OrderState = 'Fulfilled'
	and orderdate like '201801%'
	and (substr(orderdate, 7, 2) + DeliveryDays) <= 31
	and City_Region.Region = 'Central'
group by
	City_Region.CityID;


-- Оптимизация подзапросом без временной таблицы
select
	City_Region.CityID , avg(Prices.Total_price)
from
	(
	select
		sum(Quantity * Price) as Total_price, OrderID
	from
		Order_List
	group by
		OrderID) as Prices
join orders on
	Orders.OrderID = Prices.OrderID
join Customers on
	Customers.CustomerID = Orders.CustomerID
join City_Region on
	City_Region.CityID = Customers.CityID
where
	OrderState = 'Fulfilled'
	and orderdate like '201801%'
	and (substr(orderdate, 7, 2) + DeliveryDays) <= 31
	and City_Region.Region = 'Central'
group by
	City_Region.CityID;
	
-----------------------------------------------------
	
-- 3. По месяцам вывести топ-3 самых покупаемых (по количеству единиц товаров в выкупленных заказах) SKU. 
-- Если у нескольких товаров одинаковое количество проданных единиц, то выводить все такие товары.
	
With ranked as(
select
	CAST(substr(Orders.OrderDate, 5, 2) as INTEGER) as Month, 
		Order_List.SKU,
	SUM(Order_List.Quantity) as Quantity,
	rank() over ( partition by substr(Orders.OrderDate, 5, 2) order by SUM(Order_List.Quantity) DESC) as rn
from
	Orders
join Order_List on
	Order_List.OrderID = Orders.OrderID
where Orders.OrderState = 'Fulfilled'
group by
	substr(Orders.OrderDate, 5, 2),
	Order_List.SKU
)
select  Month, SKU, Quantity
from ranked
where rn <= 3;

-----------------------------------------------------

-- 4. Проанализировать качество когорт пользователей (когортой считать пользователей, оформивших заказ в одном месяце)
-- по основным маркетинговым метрикам (ARPPU, средний чек, частота, ретеншн в следующий месяц, любые другие метрики на свое усмотрение). 
-- Оформить в виде небольшого отчета в excel.
-- Форма представления данных и визуализации свободная.
-- Предполагаем, что задача звучит следующим образом: проанализировать качество и состав когорт. 
-- Предложить выводы и гипотезы, что могло на это повлиять.

-----------------------------------------------------

--1) Выручка по месяцам:

SELECT
	CAST(substr(O.OrderDate, 5, 2) as INTEGER) as OrderMonth, -- Месяц заказа
	SUM(OL.Quantity * OL.Price) AS MonthlyRevenue -- Сумма всех заказов месяца
FROM
	Orders O
JOIN Order_List OL ON O.OrderID = OL.OrderID	
WHERE 
	O.OrderState = 'Fulfilled'  -- Учитываем только выполненные заказы
GROUP BY
	OrderMonth
ORDER BY 
	MonthlyRevenue DESC;
	
-----------------------------------------------------

-- 1)  ARPPU (Average Revenue Per Paying User): Средний доход на одного платящего пользователя.
-- (Сумма всех покупок для каждого пользователя деленный на число платящих пользователей в пределах когорты (месяца))
 
WITH MonthlyOrders AS (
SELECT
	O.CustomerID,
	CAST(substr(O.OrderDate, 5, 2) as INTEGER) as OrderMonth, -- Месяц заказа
	SUM(OL.Quantity * OL.Price) AS TotalRevenue -- Сумма всех заказов пользователя
FROM
	Orders O
JOIN Order_List OL ON
	O.OrderID = OL.OrderID	
WHERE 
	O.OrderState = 'Fulfilled'  -- Учитываем только выполненные заказы
GROUP BY
	O.CustomerID,
	OrderMonth
)
SELECT
	OrderMonth,
	sum(TotalRevenue) AS TotalRevenue,
	count(distinct CustomerID) AS PayingUsers,
	sum(TotalRevenue) / count(distinct CustomerID) AS ARPPU  -- Средний доход на одного платящего пользователя
from
	MonthlyOrders
group by
	OrderMonth
order by OrderMonth desc

-----------------------------------------------------

-- 2) Средний чек (Average Order Value, AOV): Средняя стоимость заказа для каждого пользователя.
  
WITH MonthlyOrders AS (
SELECT
	O.OrderID,
	O.CustomerID,
	CAST(substr(O.OrderDate, 5, 2) as INTEGER) as OrderMonth,
	-- Месяц заказа
	SUM(OL.Quantity * OL.Price) AS TotalRevenue
	-- Сумма всех заказов пользователя
FROM
	Orders O
JOIN Order_List OL ON
	O.OrderID = OL.OrderID
WHERE 
	O.OrderState = 'Fulfilled'
GROUP BY
	O.CustomerID,
	OrderMonth,
	O.OrderID
)
SELECT
	OrderMonth,
	sum(TotalRevenue) AS TotalRevenue,
	count(distinct CustomerID) AS PayingUsers,
	count(distinct OrderId) as TotalOrders,
	sum(TotalRevenue) / count(distinct CustomerID) AS ARPPU,
	sum(TotalRevenue) / count(distinct OrderId) as AOV
	-- Средний чек
from
	MonthlyOrders
group by
	OrderMonth
order by
	OrderMonth desc
	
-----------------------------------------------------
	
-- 3) Частота покупок (Purchase Frequency): Среднее количество заказов на одного уникального пользователя в месяц:

WITH MonthlyOrders AS (
SELECT
	O.OrderID,
	O.CustomerID,
	CAST(substr(O.OrderDate, 5, 2) as INTEGER) as OrderMonth,
	-- Месяц заказа
	SUM(OL.Quantity * OL.Price) AS TotalRevenue
FROM
	Orders O
JOIN Order_List OL ON
	O.OrderID = OL.OrderID
WHERE 
	O.OrderState = 'Fulfilled'
GROUP BY
	O.CustomerID,
	OrderMonth,
	O.OrderID
ORDER BY
	OrderMonth
)
Select
	OrderMonth,
	sum(TotalRevenue) AS TotalRevenue,
	count(distinct CustomerID) AS PayingUsers,
	count(orderID) as NumberOrders,
	sum(TotalRevenue) / count(distinct CustomerID) AS ARPPU,
	sum(TotalRevenue) / count(distinct OrderId) as AOV,
	CAST(COUNT(OrderID) AS FLOAT) / COUNT(DISTINCT CustomerID) AS Frequency  -- Частота окупок
from
	MonthlyOrders
group by
	OrderMonth

-----------------------------------------------------

-- 4) Ретеншн (Retention): Доля пользователей, которые совершили повторный заказ в следующем месяце после первого заказа.

-- Все пользователи, которые сделали заказ в январе 2018:
SELECT 
    O.CustomerID,
    MIN(substr(O.OrderDate, 5, 2)) AS FirstOrderMonth
FROM Orders O
WHERE O.OrderState = 'Fulfilled'  -- Только выполненные заказы
  AND substr(O.OrderDate, 5, 2) = '02'  -- Только январь
GROUP BY O.CustomerID;

-- Кто из этих пользователей вернулся в феврале 2018:
SELECT 
     O.CustomerID
FROM Orders O
JOIN (  -- Подзапрос для когорт
    SELECT 
        O.CustomerID,
        MIN(substr(O.OrderDate, 5, 2)) AS FirstOrderMonth
    FROM Orders O
    WHERE O.OrderState = 'Fulfilled'  -- Только выполненные заказы
      AND substr(O.OrderDate, 5, 2) = '02'  -- Только январь
    GROUP BY O.CustomerID
) C ON O.CustomerID = C.CustomerID
  AND substr(O.OrderDate, 5, 2) = '03'  -- Только февраль
;

-- Ретеншн для февраля 2018
-- (Количество пользователей, которые вернулись в Феврале, поделеное на общее количество пользователей, кто сделал заказ в Январе)

SELECT 
    COUNT(DISTINCT C.CustomerID) AS TotalUsersInCohort,  -- Все пользователи в когорт
    COUNT(DISTINCT O.CustomerID) AS ReturnedUsers,  -- Вернувшиеся пользователи
    CAST(COUNT(DISTINCT O.CustomerID) AS FLOAT) / COUNT(DISTINCT C.CustomerID) AS RetentionRate
FROM (  -- Когорта (пользователи, заказавшие в январе)
    SELECT 
        O.CustomerID
    FROM Orders O
    WHERE O.OrderState = 'Fulfilled'  
      AND substr(O.OrderDate, 1, 4) = '2018' 
      AND substr(O.OrderDate, 5, 2) = '01'  -- Январь 2018
    GROUP BY O.CustomerID
) C
LEFT JOIN Orders O ON O.CustomerID = C.CustomerID
  AND substr(O.OrderDate, 1, 4) = '2018'  -- Только 2018 год
  AND substr(O.OrderDate, 5, 2) = '02'  -- Только февраль
;



