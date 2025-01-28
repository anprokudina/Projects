-- Запрос, который в базе PET определит, 
-- сколько дней осталось до окончания срока вакцинации от бешенства (код бешенства - R) 
-- у животного с чипом 643099183183126, которого нашли 2020-08-09.


-- Создаем временную таблицу с вакцинациями от бешенстава для нужного питомца:
WITH vaccinations AS (
    SELECT 
        r.vaccination_id,
        vl.vaccination_code, 
        vl.validity_period_months,
        r.vaccination_date, 
        r.chip,
        -- Рассчитываем дату окончания действия вакцинации:
        r.vaccination_date + make_interval(months => vl.validity_period_months) AS expiry_date
    FROM 
        registry r
    JOIN 
        vaccination_list vl 
    ON 
        r.vaccination_id = vl.vaccination_id
    WHERE 
        r.chip = 643099183183126                  -- Животное с указанным чипом
        AND REGEXP_LIKE(vl.vaccination_code, 'R') -- Регулярное выражение для поиска Вакцинация от бешенства "R" в любом месте строки
		AND r.vaccination_date < '2020-08-09'     -- Вакцинация не раньше дня, когда нашли животное
)
SELECT 
    vaccination_code, 
    validity_period_months, 
    vaccination_date, 
    expiry_date,
    -- Рассчитываем оставшиеся дни до окончания срока:
    (expiry_date - DATE '2020-08-09') AS days_until_expiry
FROM 
    vaccinations
WHERE 
    expiry_date > DATE '2020-08-09' -- Вакцинация должна быть актуальна на момент находки
ORDER BY 
    expiry_date DESC -- Сортировка от самой дальней даты истечения к ближайшей
LIMIT 1; -- Берем только одну запись


-- Другой способ:
WITH valid_vaccinations AS (
    SELECT 
        r.vaccination_id,
        vl.vaccination_code, 
        vl.validity_period_months,
        r.vaccination_date, 
        r.chip,
        r.vaccination_date + make_interval(months => vl.validity_period_months) AS expiry_date,
        -- Присваиваем номер строке с самым дальним сроком действия вакцины:
        ROW_NUMBER() OVER (PARTITION BY r.chip ORDER BY r.vaccination_date + make_interval(months => vl.validity_period_months) DESC) AS rn,
        -- Рассчитываем оставшиеся дни с помощью CASE:
        CASE 
            WHEN (r.vaccination_date + make_interval(months => vl.validity_period_months)) > DATE '2020-08-09'
            THEN (r.vaccination_date + make_interval(months => vl.validity_period_months)) - DATE '2020-08-09'
            ELSE NULL
        END AS days_until_expiry
    FROM 
        registry r
    JOIN 
        vaccination_list vl 
    ON 
        r.vaccination_id = vl.vaccination_id
    WHERE 
        r.chip = 643099183183126
        AND vl.vaccination_code LIKE '%R%'
		AND r.vaccination_date < '2020-08-09'     -- Вакцинация не раньше дня, когда нашли животное
)
SELECT 
	days_until_expiry
FROM 
    valid_vaccinations
WHERE 
    rn = 1; -- Берем строку с самой дальней датой истечения


