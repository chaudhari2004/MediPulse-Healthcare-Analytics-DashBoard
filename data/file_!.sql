-- SELECT * FROM medipulse.staging_admissions;

-- select count(*) from medipulse.staging_admissions;


-- SELECT
--     COUNT(*) AS total_rows,
--     MIN(`Date of Admission`) AS min_admission_date,
--     MAX(`Date of Admission`) AS max_admission_date
-- FROM medipulse.staging_admissions;

-- SELECT COUNT(*) AS total_records
-- FROM medipulse.staging_admissions;

-- USE medipulse;

-- TRUNCATE TABLE staging_admissions;

-- SHOW VARIABLES LIKE 'local_infile';
-- SET GLOBAL local_infile = 1;
-- SHOW VARIABLES LIKE 'local_infile';


-- LOAD DATA LOCAL INFILE 'C:/Users/Vivek Chaudhari/OneDrive/Desktop/MediPulse project/data/medipulse_cleaned.csv'
-- INTO TABLE medipulse.staging_admissions
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;


-- SHOW VARIABLES LIKE 'local_infile';

-- LOAD DATA LOCAL INFILE 'C:/Users/Vivek Chaudhari/OneDrive/Desktop/MediPulse project/data/medipulse_cleaned.csv'
-- INTO TABLE medipulse.staging_admissions
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;

-- SELECT COUNT(*) AS total_rows
-- FROM medipulse.staging_admissions;

use medipulse;
show tables;

select * from staging_admissions;

select count(*) from staging_admissions;

DESCRIBE staging_admissions;

CREATE TABLE dim_patient (
    patient_key INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(150),
    age INT,
    gender VARCHAR(20),
    blood_type VARCHAR(10)
);

INSERT INTO dim_patient (
    patient_name,
    age,
    gender,
    blood_type
)
SELECT DISTINCT
    Name,
    Age,
    Gender,
    `Blood Type`
FROM staging_admissions;


USE medipulse;

TRUNCATE TABLE dim_patient;
SELECT COUNT(*) AS total_patients
FROM dim_patient;

INSERT INTO dim_patient (
    patient_name,
    age,
    gender,
    blood_type
)
SELECT DISTINCT
    Name,
    Age,
    Gender,
    `Blood Type`
FROM staging_admissions;

SELECT *
FROM dim_patient
LIMIT 10;


DESCRIBE dim_patient;

CREATE TABLE dim_hospital (
    hospital_key INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(150)
);

INSERT INTO dim_hospital (hospital_name)
SELECT DISTINCT
    Hospital
FROM staging_admissions;

SELECT COUNT(*) AS total_hospitals
FROM dim_hospital;

SELECT *
FROM dim_hospital
LIMIT 10;

CREATE TABLE dim_medical_condition (
    condition_key INT AUTO_INCREMENT PRIMARY KEY,
    medical_condition VARCHAR(100)
);

INSERT INTO dim_medical_condition (medical_condition)
SELECT DISTINCT
    `Medical Condition`
FROM staging_admissions;

SELECT COUNT(*) AS total_conditions
FROM dim_medical_condition;

SELECT *
FROM dim_medical_condition;

CREATE TABLE dim_insurance (
    insurance_key INT AUTO_INCREMENT PRIMARY KEY,
    insurance_provider VARCHAR(100)
);

INSERT INTO dim_insurance (insurance_provider)
SELECT DISTINCT
    `Insurance Provider`
FROM staging_admissions;

SELECT COUNT(*) AS total_insurance_providers
FROM dim_insurance;

SELECT *
FROM dim_insurance;

CREATE TABLE dim_medication (
    medication_key INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(100)
);

INSERT INTO dim_medication (medication_name)
SELECT DISTINCT
    Medication
FROM staging_admissions;

SELECT COUNT(*) AS total_medications
FROM dim_medication;

SELECT *
FROM dim_medication;

CREATE TABLE dim_admission_type (
    admission_type_key INT AUTO_INCREMENT PRIMARY KEY,
    admission_type VARCHAR(50)
);

INSERT INTO dim_admission_type (admission_type)
SELECT DISTINCT
    `Admission Type`
FROM staging_admissions;

SELECT COUNT(*) AS total_admission_types
FROM dim_admission_type;

SELECT *
FROM dim_admission_type;

CREATE TABLE dim_test_result (
    test_result_key INT AUTO_INCREMENT PRIMARY KEY,
    test_result VARCHAR(50)
);

INSERT INTO dim_test_result (test_result)
SELECT DISTINCT
    `Test Results`
FROM staging_admissions;

SELECT COUNT(*) AS total_test_results
FROM dim_test_result;

SELECT *
FROM dim_test_result;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    day INT,
    weekday VARCHAR(20),
    weekend_flag VARCHAR(10)
);

INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    month,
    month_name,
    quarter,
    day,
    weekday,
    weekend_flag
)
SELECT DISTINCT
    CAST(DATE_FORMAT(`Date of Admission`, '%Y%m%d') AS UNSIGNED) AS date_key,
    DATE(`Date of Admission`) AS full_date,
    YEAR(`Date of Admission`) AS year,
    MONTH(`Date of Admission`) AS month,
    MONTHNAME(`Date of Admission`) AS month_name,
    QUARTER(`Date of Admission`) AS quarter,
    DAY(`Date of Admission`) AS day,
    DAYNAME(`Date of Admission`) AS weekday,
    CASE
        WHEN DAYOFWEEK(`Date of Admission`) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS weekend_flag
FROM staging_admissions;

SELECT COUNT(*) AS total_dates
FROM dim_date;

SELECT *
FROM dim_date
ORDER BY full_date
limit 10;



USE medipulse;

CREATE TABLE fact_admission (
    admission_key INT AUTO_INCREMENT PRIMARY KEY,

    patient_key INT,
    hospital_key INT,
    condition_key INT,
    insurance_key INT,
    medication_key INT,
    admission_type_key INT,
    test_result_key INT,
    date_key INT,

    billing_amount DECIMAL(12,2),
    room_number INT,
    length_of_stay INT,
    revenue_per_stay_day DECIMAL(12,2)
);

DESCRIBE fact_admission;




SELECT
    p.patient_key,
    h.hospital_key,
    c.condition_key,
    i.insurance_key,
    m.medication_key,
    a.admission_type_key,
    t.test_result_key,
    d.date_key,
    s.`Billing Amount`,
    s.`Room Number`,
    s.`Length of Stay`,
    s.`Revenue Per Stay Day`
FROM staging_admissions s

JOIN dim_patient p
    ON p.patient_name = s.Name
    AND p.age = s.Age
    AND p.gender = s.Gender
    AND p.blood_type = s.`Blood Type`

JOIN dim_hospital h
    ON h.hospital_name = s.Hospital

JOIN dim_medical_condition c
    ON c.medical_condition = s.`Medical Condition`

JOIN dim_insurance i
    ON i.insurance_provider = s.`Insurance Provider`

JOIN dim_medication m
    ON m.medication_name = s.Medication

JOIN dim_admission_type a
    ON a.admission_type = s.`Admission Type`

JOIN dim_test_result t
    ON t.test_result = s.`Test Results`

JOIN dim_date d
    ON d.full_date = DATE(s.`Date of Admission`)

LIMIT 10;


SELECT COUNT(*) AS fact_records_to_insert
FROM staging_admissions s

JOIN dim_patient p
    ON p.patient_name = s.Name
    AND p.age = s.Age
    AND p.gender = s.Gender
    AND p.blood_type = s.`Blood Type`

JOIN dim_hospital h
    ON h.hospital_name = s.Hospital

JOIN dim_medical_condition c
    ON c.medical_condition = s.`Medical Condition`

JOIN dim_insurance i
    ON i.insurance_provider = s.`Insurance Provider`

JOIN dim_medication m
    ON m.medication_name = s.Medication

JOIN dim_admission_type a
    ON a.admission_type = s.`Admission Type`

JOIN dim_test_result t
    ON t.test_result = s.`Test Results`

JOIN dim_date d
    ON d.full_date = DATE(s.`Date of Admission`);
    
INSERT INTO fact_admission (
    patient_key,
    hospital_key,
    condition_key,
    insurance_key,
    medication_key,
    admission_type_key,
    test_result_key,
    date_key,
    billing_amount,
    room_number,
    length_of_stay,
    revenue_per_stay_day
)
SELECT
    p.patient_key,
    h.hospital_key,
    c.condition_key,
    i.insurance_key,
    m.medication_key,
    a.admission_type_key,
    t.test_result_key,
    d.date_key,
    s.`Billing Amount`,
    s.`Room Number`,
    s.`Length of Stay`,
    s.`Revenue Per Stay Day`
FROM staging_admissions s
JOIN dim_patient p
    ON p.patient_name = s.Name
    AND p.age = s.Age
    AND p.gender = s.Gender
    AND p.blood_type = s.`Blood Type`
JOIN dim_hospital h
    ON h.hospital_name = s.Hospital
JOIN dim_medical_condition c
    ON c.medical_condition = s.`Medical Condition`
JOIN dim_insurance i
    ON i.insurance_provider = s.`Insurance Provider`
JOIN dim_medication m
    ON m.medication_name = s.Medication
JOIN dim_admission_type a
    ON a.admission_type = s.`Admission Type`
JOIN dim_test_result t
    ON t.test_result = s.`Test Results`
JOIN dim_date d
    ON d.full_date = DATE(s.`Date of Admission`);
    
SELECT COUNT(*) AS total_admissions
FROM fact_admission;

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_patient
FOREIGN KEY (patient_key)
REFERENCES dim_patient(patient_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_hospital
FOREIGN KEY (hospital_key)
REFERENCES dim_hospital(hospital_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_condition
FOREIGN KEY (condition_key)
REFERENCES dim_medical_condition(condition_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_insurance
FOREIGN KEY (insurance_key)
REFERENCES dim_insurance(insurance_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_medication
FOREIGN KEY (medication_key)
REFERENCES dim_medication(medication_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_admission_type
FOREIGN KEY (admission_type_key)
REFERENCES dim_admission_type(admission_type_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_test_result
FOREIGN KEY (test_result_key)
REFERENCES dim_test_result(test_result_key);

ALTER TABLE fact_admission
ADD CONSTRAINT fk_fact_date
FOREIGN KEY (date_key)
REFERENCES dim_date(date_key);


SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'medipulse'
  AND TABLE_NAME = 'fact_admission'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
  
  SELECT COUNT(*) AS orphan_patients
FROM fact_admission f
LEFT JOIN dim_patient p
    ON f.patient_key = p.patient_key
WHERE p.patient_key IS NULL;

SELECT COUNT(*) AS orphan_hospitals
FROM fact_admission f
LEFT JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key
WHERE h.hospital_key IS NULL;

SELECT COUNT(*) AS orphan_conditions
FROM fact_admission f
LEFT JOIN dim_medical_condition c
    ON f.condition_key = c.condition_key
WHERE c.condition_key IS NULL;

SELECT COUNT(*) AS orphan_insurance
FROM fact_admission f
LEFT JOIN dim_insurance i
    ON f.insurance_key = i.insurance_key
WHERE i.insurance_key IS NULL;

SELECT COUNT(*) AS orphan_medications
FROM fact_admission f
LEFT JOIN dim_medication m
    ON f.medication_key = m.medication_key
WHERE m.medication_key IS NULL;

SELECT COUNT(*) AS orphan_admission_types
FROM fact_admission f
LEFT JOIN dim_admission_type a
    ON f.admission_type_key = a.admission_type_key
WHERE a.admission_type_key IS NULL;

SELECT COUNT(*) AS orphan_test_results
FROM fact_admission f
LEFT JOIN dim_test_result t
    ON f.test_result_key = t.test_result_key
WHERE t.test_result_key IS NULL;


SELECT COUNT(*) AS orphan_dates
FROM fact_admission f
LEFT JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;

SELECT *
FROM fact_admission
WHERE hospital_key = 100;
    