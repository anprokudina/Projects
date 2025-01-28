-- В базе PET выдайте чипы животных и сумму,
-- на которую нужно оштрафовать владельца, если они не
-- сделали вовремя прививку от бешенства (один пропущенный день – 1 рубль).

-- Штрафы формируются за: 
-- 1)дни между окончанием предыдущей и новой прививками;
-- 2)дни после окончания последней прививки и датой формирования штрафа.



-- Временная таблица для хранения данных с необходимой следующей датой вакцинации и фактической:
WITH vaccination_data AS (
    SELECT 
        r.chip,
        vl.vaccination_code,
        r.vaccination_date,
		-- Необходимая дата вакцинации, когда срок вакцины истёк:
        r.vaccination_date + make_interval(months => vl.validity_period_months) AS expiry_date,
		-- Это оконная функция с смещением,
		-- которая возвращает следующую фактическую дату вакцинации из столбца vaccination_date для каждой строки:
		-- секционирование по по каждой группе животных с одинаковым чипом
        LEAD(r.vaccination_date) OVER (PARTITION BY r.chip ORDER BY r.vaccination_date) AS next_vaccination_date
    FROM 
        registry r
    JOIN 
        vaccination_list vl 
    ON 
        r.vaccination_id = vl.vaccination_id
    WHERE 
        REGEXP_LIKE(vl.vaccination_code, 'R') -- Вакцинация от бешенства
		and
		r.chip = 643099183183126                  -- Животное с указанным чипом
)
select * 
from vaccination_data

-- Временная таблица для хранения данных с необходимой следующей датой вакцинации и фактической:
WITH vaccination_data AS (
    SELECT 
        r.chip,
        vl.vaccination_code,
        r.vaccination_date,
		-- Необходимая дата вакцинации, когда срок вакцины истёк:
        r.vaccination_date + make_interval(months => vl.validity_period_months) AS expiry_date,
		-- Это оконная функция с смещением,
		-- которая возвращает следующую фактическую дату вакцинации из столбца vaccination_date для каждой строки:
		-- секционирование по по каждой группе животных с одинаковым чипом
        LEAD(r.vaccination_date) OVER (PARTITION BY r.chip ORDER BY r.vaccination_date) AS next_vaccination_date
    FROM 
        registry r
    JOIN 
        vaccination_list vl 
    ON 
        r.vaccination_id = vl.vaccination_id
    WHERE 
        REGEXP_LIKE(vl.vaccination_code, 'R') -- Вакцинация от бешенства
		and
		r.chip = 643099183183126                  -- Животное с указанным чипом
),
-- Временная таблица для хранения штрафов за каждую просроченную вакцинацию:
fines AS (
    SELECT 
        chip,
        -- Штраф за разрыв между прививками 0 или больше если разрыв есть:
        GREATEST(0, EXTRACT(DAY FROM next_vaccination_date - expiry_date)) AS gap_fine,
        -- Штраф за дни после истечения последней прививки:
        CASE 
            WHEN next_vaccination_date IS NULL THEN 
                GREATEST(0, EXTRACT(DAY FROM CURRENT_DATE - expiry_date))
            ELSE 0
        END AS overdue_fine
    FROM 
        vaccination_data
	WHERE 
		-- Исключаем разрывы без штрафа
        GREATEST(0, EXTRACT(DAY FROM next_vaccination_date - expiry_date)) > 0 
		-- Исключаем просрочки без штрафа
        OR (next_vaccination_date IS NULL AND GREATEST(0, EXTRACT(DAY FROM CURRENT_DATE - expiry_date)) > 0) 
)
select *
from fines


-- Финальный запрос:
-- Временная таблица для хранения данных с необходимой следующей датой вакцинации и фактической:
WITH vaccination_data AS (
    SELECT 
        r.chip,
        vl.vaccination_code,
        r.vaccination_date,
		-- Необходимая дата вакцинации, когда срок вакцины истёк:
        r.vaccination_date + make_interval(months => vl.validity_period_months) AS expiry_date,
		-- Это оконная функция с смещением,
		-- которая возвращает следующую фактическую дату вакцинации из столбца vaccination_date для каждой строки:
		-- секционирование по по каждой группе животных с одинаковым чипом
        LEAD(r.vaccination_date) OVER (PARTITION BY r.chip ORDER BY r.vaccination_date) AS next_vaccination_date
    FROM 
        registry r
    JOIN 
        vaccination_list vl 
    ON 
        r.vaccination_id = vl.vaccination_id
    WHERE 
        REGEXP_LIKE(vl.vaccination_code, 'R') -- Вакцинация от бешенства
),

-- Временная таблица для хранения штрафов за каждую просроченную вакцинацию:
fines AS (
    SELECT 
        chip,
        -- Штраф за разрыв между прививками 0 или больше если разрыв есть:
        GREATEST(0, EXTRACT(DAY FROM next_vaccination_date - expiry_date)) AS gap_fine,
        -- Штраф за дни после истечения последней прививки:
        CASE 
            WHEN next_vaccination_date IS NULL THEN 
                GREATEST(0, EXTRACT(DAY FROM CURRENT_DATE - expiry_date))
            ELSE 0
        END AS overdue_fine
    FROM 
        vaccination_data
	WHERE 
		-- Исключаем разрывы без штрафа
        GREATEST(0, EXTRACT(DAY FROM next_vaccination_date - expiry_date)) > 0 
		-- Исключаем просрочки без штрафа
        OR (next_vaccination_date IS NULL AND GREATEST(0, EXTRACT(DAY FROM CURRENT_DATE - expiry_date)) > 0) 
)
SELECT 
    chip,
    SUM(gap_fine) AS total_gap_fine, -- Суммарные штрафы за разрывы
    SUM(overdue_fine) AS total_overdue_fine, -- Суммарные штрафы за просрочку
    SUM(gap_fine + overdue_fine) AS total_fine -- Итоговая сумма всех штрафов
FROM 
    fines
GROUP BY 
    chip;