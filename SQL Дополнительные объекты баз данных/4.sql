-- Триггеры:

-- Таблица логов:
CREATE TABLE logs (
    log_id SERIAL PRIMARY KEY,
    operation_type VARCHAR(50) NOT NULL,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

SELECT *
FROM logs

-- Функция(записывает команду и описание):
CREATE OR REPLACE FUNCTION log_ddl_operations()
RETURNS event_trigger 
AS $$
DECLARE
    event_details TEXT;
BEGIN
    -- Формируем описание события (успешный запрос)
    event_details := 'Query: ' || current_query();
    
    -- Записываем операцию в таблицу логов
    INSERT INTO logs (operation_type, details)
    VALUES (tg_tag, event_details);
    
    -- Завершаем выполнение
    RETURN;
END;
$$ 
LANGUAGE plpgsql;

--Триггер:
CREATE EVENT TRIGGER log_ddl_trigger
ON ddl_command_end
EXECUTE PROCEDURE log_ddl_operations();

-----------------------------------------------------
-- Таблица сотрудников:
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    position VARCHAR(50) NOT NULL,
    hired_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select *
from employees

-----------------------------------------------------
-- 1. Логирование действий INSERT/UPDATE

-- Функция логирования действий:
CREATE OR REPLACE FUNCTION log_employee_action()
RETURNS TRIGGER 
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO logs(operation_type, details)
        VALUES ('INSERT', 'Добавлен сотрудник с ID = ' || NEW.employee_id);
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO logs(operation_type, details)
        VALUES ('UPDATE', 'Обновлены данные сотрудника с ID = ' || NEW.employee_id);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO logs(operation_type, details)
        VALUES ('DELETE', 'Удалены данные сотрудника с ID = ' || OLD.employee_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для таблицы employee:
CREATE TRIGGER trigger_log_employee_action
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_action();


-- Работа триггера trigger_log_employee_action на INSERT OR UPDATE:
INSERT INTO employees(name, salary, position)
VALUES ('Иван Иванов', 50000, 'Менеджер');

UPDATE employees
SET salary = 60000
WHERE employee_id = 1;

DELETE FROM employees
WHERE employee_id = 1;

select *
from logs

select *
from employees

-----------------------------------------------------

-- 2) Проверка уникальности имени сотрудника:

CREATE OR REPLACE FUNCTION check_unique_name()
RETURNS TRIGGER 
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM employees WHERE name = NEW.name) THEN
        RAISE EXCEPTION 'Имя сотрудника дублируется: %.', NEW.name;
    END IF;

    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER unique_name_trigger
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION check_unique_name();


-- Проверим:
INSERT INTO employees(name, salary, position)
VALUES ('Иван Иванов', 50000, 'Менеджер');

INSERT INTO employees(name, salary, position)
VALUES ('Иван Иванов', 60000, 'Менеджер');

select *
from logs;

select *
from employees;


-----------------------------------------------------
-- 3) Ограничение на размер заработной платы:
CREATE OR REPLACE FUNCTION check_salary_range()
RETURNS TRIGGER 
AS $$
BEGIN
    -- Проверка заработной платы:
    IF NEW.salary < 1000 OR NEW.salary > 100000 THEN
        RAISE EXCEPTION 'Заработная плата не в диапозоне 1000 - 100000 : %', NEW.salary;
    END IF;
    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;


CREATE TRIGGER salary_check_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE PROCEDURE check_salary_range();

-- Проверка триггера:
INSERT INTO employees (name, salary, position) 
VALUES ('Егор Смирнов', 50000, 'Менеджер');

-- Ошибка: зарплата вне диапазона
INSERT INTO employees (name, salary, position) 
VALUES ('Алиса Иванова', 10, 'Разработчик');

UPDATE employees 
SET salary = 70
WHERE name = 'Егор Смирнов';

select *
from logs;

select *
from employees;

-----------------------------------------------------
-- 4) Ограничение на указываемую должность

CREATE TABLE valid_positions (
    position_name VARCHAR(50) PRIMARY KEY
);

INSERT INTO valid_positions (position_name)
VALUES 
    ('Менеджер'),
    ('Разработчик'),
    ('Аналитик'),
    ('HR'),
    ('Продавец');


-- Функция:
CREATE OR REPLACE FUNCTION validate_position()
RETURNS TRIGGER 
AS $$
BEGIN
    -- Проверяем, что должность существует в таблице valid_positions:
    IF NOT EXISTS (
        SELECT 1 
        FROM valid_positions 
        WHERE position_name = NEW.position
    ) THEN
        -- Вызываем ошибку
        RAISE EXCEPTION 'Некорректная должность: %. Допустимые должности указаны в таблице valid_positions.', NEW.position;
    END IF;

    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

-- Триггер:
CREATE TRIGGER validate_position_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION validate_position();

-- Проверяем:
INSERT INTO employees (name, salary, position)
VALUES ('Елизавета Павловна', 70000, 'Менеджер');

INSERT INTO employees (name, salary, position)
VALUES ('Мария Петрова', 15000, 'Стажер');


select *
from logs;

select *
from employees;

-----------------------------------------------------
-- 5) Ограничение на вставку в недопустимое время:

-- Функция:
CREATE OR REPLACE FUNCTION off_hours_operations()
RETURNS TRIGGER 
AS $$
BEGIN
    IF EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 21 OR EXTRACT(HOUR FROM CURRENT_TIMESTAMP) > 22 THEN
    	-- Генерируем исключение, которое отклонит операцию
    	RAISE EXCEPTION 'Действие в недопустимое время: %. Действия разрешены с 21:00 до 22:00.', CURRENT_TIMESTAMP;
	END IF;
    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

-- Триггер:
CREATE TRIGGER off_hours_triggers
BEFORE INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE PROCEDURE off_hours_operations();

-- Проверяем триггер:
INSERT INTO employees (name, salary, position) 
VALUES ('Михаил Воробьев', 50000, 'Менеджер');

DROP TRIGGER IF EXISTS off_hours_triggers ON employees;

select *
from logs;

select *
from employees;

