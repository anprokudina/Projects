-- Удаляем строки, где нет данных в столбце phone_email
-- Функция TRIM удаляет пробелы в начале и конце строки
DELETE
FROM
	employees
WHERE
	phone_email IS NULL
	OR TRIM(phone_email) = '';
	
-- Удаление всех символов, кроме цифр, запятой, косой черты и пробела:
UPDATE
	employees
SET
	phone_email = REGEXP_REPLACE(phone_email,
	'[^0-9,/\s]',
	'',
	'g');
	
-- Удаляем пробелы с обеих сторон строки:
UPDATE
	employees
SET
	phone_email = BTRIM(phone_email);
-- Заменить все неодинарные пробелы одинарными: 
UPDATE
	employees
SET
	phone_email = REGEXP_REPLACE(phone_email,
	'\s+',
	' ',
	'g');
	
-- Удалить все пробелы, если их количество в строке больше одного:
UPDATE
	employees
SET
	phone_email = REGEXP_REPLACE(phone_email,
	'\s+',
	'',
	'g')
WHERE
	LENGTH(phone_email) - LENGTH(REPLACE(phone_email,
	' ',
	'')) > 1;
	
-- Разница между этими длинами даёт количество пробелов в строке
-- Так как в некоторых значениях два номера, будем переносить номера в 2 новые колонки:
ALTER TABLE employees
ADD COLUMN phone1 TEXT,
ADD COLUMN phone2 TEXT;

-- Разделяем данные из столбца phone_email на два столбца: phone1 и phone2. 
-- где есть разделители: запятая, косая черта или пробел в строках столбца phone_email.
UPDATE
	employees
SET
	phone1 = CASE
		WHEN phone_email LIKE '%,%' THEN SPLIT_PART(phone_email,
		',',
		1)
		WHEN phone_email LIKE '%/%' THEN SPLIT_PART(phone_email,
		'/',
		1)
		WHEN phone_email LIKE '% %' THEN SPLIT_PART(phone_email,
		' ',
		1)
		ELSE phone_email
	END,
	phone2 = CASE
		WHEN phone_email LIKE '%,%' THEN SPLIT_PART(phone_email,
		',',
		2)
		WHEN phone_email LIKE '%/%' THEN SPLIT_PART(phone_email,
		'/',
		2)
		WHEN phone_email LIKE '% %' THEN SPLIT_PART(phone_email,
		' ',
		2)
	END;
	
-- Заменить все номера начинающиемя на 79... на 89...:
UPDATE
	employees
SET
	phone1 = REGEXP_REPLACE(phone1,
	'^7',
	'8',
	'g' ),
	phone2 = REGEXP_REPLACE(phone2,
	'^7',
	'8',
	'g' );
	
-- Заменить все номера начинающиеся с 9... на 89...:
UPDATE
	employees
SET
	phone1 = REGEXP_REPLACE(phone1,
	'^9',
	'89',
	'g' )
WHERE
	regexp_like(phone1,
	'^9')
	AND LENGTH(phone1) = 10;

UPDATE
	employees
SET
	phone2 = REGEXP_REPLACE(phone2,
	'^9',
	'89',
	'g' )
WHERE
	regexp_like(phone2,
	'^9')
	AND LENGTH(phone2) = 10;
	
-- Корректируем начало номеров типа 99194455677 или 7929334456:
UPDATE
	employees
SET
	phone1 = 
    CASE
		-- Если начинается с 9 или 7 и длина равна 11, заменить первую цифру на 8
        WHEN LENGTH(phone1) = 11
		AND phone1 LIKE '9%' THEN REGEXP_REPLACE(phone1,
		'^9',
		'8')
		WHEN LENGTH(phone1) = 11
		AND phone1 LIKE '7%' THEN REGEXP_REPLACE(phone1,
		'^7',
		'8')
		-- Если длина равна 10 и не начинается на 8, добавить 8 в начало
		WHEN LENGTH(phone1) = 10
		AND phone1 NOT LIKE '8%' THEN '8' || phone1
		ELSE phone1
	END
WHERE
	-- Ограничиваем запрос только строками, которые нужно изменить
    (LENGTH(phone1) = 11
		AND (phone1 LIKE '9%'
			OR phone1 LIKE '7%'))
	OR (LENGTH(phone1) = 10
		AND phone1 NOT LIKE '8%');
		
-- Исправляем телефоны из 12 цифр например 989184456767
UPDATE
	employees
SET
	phone1 = REGEXP_REPLACE(phone1,
	'^([97])',
	'')
WHERE
	REGEXP_LIKE(phone1,
	'^[97].{11}$');
	
-- Если phone1 содержит 11 цифр, за которыми идут 89 или 79, то разделяем эти номера
UPDATE
	employees
SET
	phone1 = SUBSTRING(phone1 FROM 1 FOR 11),
	phone2 = SUBSTRING(phone1 FROM 12)
WHERE
	phone1 ~ '^\d{11}(89|79)';

	
-- Находим номера, которые повторяются больше 2 раз
SELECT
	phone,
	COUNT(*) AS repeat_count
FROM
	(
	SELECT
		phone1 AS phone
	FROM
		employees
	WHERE
		phone1 IS NOT NULL
		AND LENGTH(phone1) > 6
UNION ALL
	SELECT
		phone2 AS phone
	FROM
		employees
	WHERE
		phone2 IS NOT NULL
		AND LENGTH(phone2) > 6 
) AS combined_phones
GROUP BY
	phone
HAVING
	COUNT(*) > 1;