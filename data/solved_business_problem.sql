-- Used Indexes 

-- project data base
use medipulse;


create index idx_fact_patient
on fact_admission(patient_key);

create index idx_fact_hospital
on fact_admission(hospital_key);

create index idx_fact_condition
on fact_admission(condition_key);

create index idx_fact_insurance
on fact_admission(insurance_key);

create index idx_fact_medication
on fact_admission(medication_key);

create index idx_fact_admission_type
on fact_admission(admission_type_key);

create index idx_fact_test_result
on fact_admission(test_result_key);

create index idx_fact_date
on fact_admission(date_key);

-- Index of Dimension tables with business columms

create index idx_hospital_name
on dim_hospital(hospital_name);

create index idx_condition_name
on dim_medical_condition(medical_condition);

CREATE INDEX idx_insurance_provider
ON dim_insurance(insurance_provider);

CREATE INDEX idx_medication_name
ON dim_medication(medication_name);

CREATE INDEX idx_admission_type
ON dim_admission_type(admission_type);

CREATE INDEX idx_test_result
ON dim_test_result(test_result);

-- Check indexes
SHOW INDEX FROM fact_admission;

SHOW INDEX FROM dim_hospital;

-- 	DATA ANALYST PHASE TASK

SELECT
    COUNT(*) AS total_admissions,
    COUNT(DISTINCT patient_key) AS total_patients,
    COUNT(DISTINCT hospital_key) AS total_hospitals,
    ROUND(SUM(billing_amount), 2) AS total_revenue,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay,
    MAX(length_of_stay) AS max_length_of_stay,
    ROUND(AVG(revenue_per_stay_day), 2) AS avg_revenue_per_stay_day
FROM fact_admission;

-- Business Problem

-- Identify hospital-wise admission volume, 
-- total revenue, average billing, and average length of stay.

SELECT
    h.hospital_name,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key
GROUP BY h.hospital_key, h.hospital_name
ORDER BY total_revenue DESC;

-- Business Problem: Analyze admission volume, total revenue, average billing,
--  and average length of stay for each medical condition.
SELECT
    c.medical_condition,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_medical_condition c
    ON f.condition_key = c.condition_key
GROUP BY
    c.condition_key,
    c.medical_condition
ORDER BY total_revenue DESC;


-- Business Problem: Identify hospitals with more
--  than 5 admissions and total revenue above ₹250,000.
SELECT
    h.hospital_name,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue
FROM fact_admission f
JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key
GROUP BY
    h.hospital_key,
    h.hospital_name
HAVING
    COUNT(*) > 5
    AND SUM(f.billing_amount) > 250000
ORDER BY total_revenue DESC;

-- Business Problem: Compare admission volume, revenue, average billing, 
-- and average length of stay across different admission types.
SELECT
    a.admission_type,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_admission_type a
    ON f.admission_type_key = a.admission_type_key
GROUP BY
    a.admission_type_key,
    a.admission_type
ORDER BY total_admissions DESC;

-- Business Problem: Analyze admission volume, total revenue, 
-- average billing, and average length of stay for each insurance provider.
SELECT
    i.insurance_provider,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_insurance i
    ON f.insurance_key = i.insurance_key
GROUP BY
    i.insurance_key,
    i.insurance_provider
ORDER BY total_revenue DESC;

SELECT
    h.hospital_name,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key
GROUP BY
    h.hospital_key,
    h.hospital_name
HAVING COUNT(*) >= 20
ORDER BY
    total_revenue DESC,
    total_admissions DESC;
    
-- Hospital Performance

-- Business Problem:

-- Hospital management wants to identify hospitals that handle high patient volume while generating high total revenue.

SELECT
    h.hospital_name,
    COUNT(*) AS total_admissions,
    ROUND(SUM(f.billing_amount), 2) AS total_revenue,
    ROUND(AVG(f.billing_amount), 2) AS avg_billing,
    ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay
FROM fact_admission f
JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key
GROUP BY
    h.hospital_key,
    h.hospital_name
HAVING COUNT(*) >= 20
ORDER BY
    total_revenue DESC,
    total_admissions DESC;
    
-- Hospital Operational Efficiency

-- Business Problem:

-- Hospital management wants to identify hospitals that have high patient volume but
--  need to evaluate whether their revenue and length-of-stay performance are efficient.
-- Business Problem:
-- Identify hospitals with high patient volume and evaluate
-- their revenue and length-of-stay efficiency.

WITH hospital_metrics AS (
    
    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue,

        ROUND(AVG(f.billing_amount), 2) AS avg_billing,

        ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay,

        ROUND(
            SUM(f.billing_amount) / COUNT(*),
            2
        ) AS revenue_per_admission

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
)

SELECT
    hospital_name,
    total_admissions,
    total_revenue,
    avg_billing,
    avg_length_of_stay,
    revenue_per_admission,

    CASE
        WHEN revenue_per_admission >= 27000
             AND avg_length_of_stay <= 16
            THEN 'HIGH EFFICIENCY'

        WHEN revenue_per_admission >= 24000
             AND avg_length_of_stay <= 18
            THEN 'MODERATE EFFICIENCY'

        ELSE 'REVIEW REQUIRED'
    END AS efficiency_status

FROM hospital_metrics

ORDER BY
    revenue_per_admission DESC;
    
-- Business Problem

-- Healthcare management wants to compare insurance providers based on patient volume, revenue, 
-- average billing, emergency utilization, and average length 
-- of stay to understand differences in insurance utilization.

WITH insurance_metrics AS (

    SELECT
        i.insurance_key,
        i.insurance_provider,

        COUNT(*) AS total_admissions,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue,

        ROUND(AVG(f.billing_amount), 2) AS avg_billing,

        ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions

    FROM fact_admission f

    JOIN dim_insurance i
        ON f.insurance_key = i.insurance_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        i.insurance_key,
        i.insurance_provider
)

SELECT
    insurance_provider,
    total_admissions,
    total_revenue,
    avg_billing,
    avg_length_of_stay,
    emergency_admissions,

    ROUND(
        emergency_admissions * 100.0 / total_admissions,
        2
    ) AS emergency_percentage,

    ROUND(
        total_revenue / total_admissions,
        2
    ) AS revenue_per_admission

FROM insurance_metrics

ORDER BY
    total_revenue DESC;
    
-- Hospital Revenue Ranking
-- 🏆 Business Problem

-- Hospital management wants to rank hospitals based on their total revenue to understand each hospital's position within the healthcare network.

-- Business Problem:
-- Rank hospitals based on total revenue and identify
-- their position within the healthcare network.

WITH hospital_revenue AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
)

SELECT
    hospital_name,
    total_admissions,
    total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS dense_revenue_rank,

    ROW_NUMBER() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_row_number

FROM hospital_revenue

ORDER BY total_revenue DESC;

-- Healthcare Operations
-- Business Problem

-- Hospital management wants to identify hospitals where high patient volume is combined with longer stays, so operational 
-- teams can prioritize hospitals that may require capacity and workflow review.
-- Business Problem:
-- Identify hospitals with high patient volume and longer stays
-- for operational and capacity review.

WITH hospital_operations AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20 THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20 THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
)

SELECT
    hospital_name,
    total_admissions,
    avg_length_of_stay,
    long_stay_admissions,
    long_stay_percentage,
    total_revenue,

    CASE
        WHEN total_admissions >= 30
             AND long_stay_percentage >= 30
            THEN 'HIGH OPERATIONAL REVIEW'

        WHEN total_admissions >= 25
             OR long_stay_percentage >= 25
            THEN 'MODERATE REVIEW'

        ELSE 'NORMAL'
    END AS operational_status

FROM hospital_operations

ORDER BY
    long_stay_percentage DESC,
    total_admissions DESC;
--     
-- Healthcare Cost & Financial Burden
-- Business Problem

-- Hospital management wants to identify hospitals where patient billing is high compared with the healthcare network average, 
-- so that high-cost areas can be prioritized for financial review.

-- Business Problem:
-- Identify hospitals with high average patient billing
-- compared with the overall healthcare network.

WITH hospital_financials AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue,

        ROUND(AVG(f.billing_amount), 2) AS avg_billing,

        ROUND(
            SUM(f.billing_amount) / COUNT(*),
            2
        ) AS revenue_per_admission

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
),

benchmarked AS (

    SELECT
        hospital_name,
        total_admissions,
        total_revenue,
        avg_billing,
        revenue_per_admission,

        ROUND(
            AVG(avg_billing) OVER (),
            2
        ) AS network_avg_billing

    FROM hospital_financials
)

SELECT
    hospital_name,
    total_admissions,
    total_revenue,
    avg_billing,
    revenue_per_admission,
    network_avg_billing,

    ROUND(
        avg_billing - network_avg_billing,
        2
    ) AS billing_gap,

    ROUND(
        (avg_billing - network_avg_billing)
        * 100.0 / network_avg_billing,
        2
    ) AS billing_gap_percentage,

    CASE
        WHEN avg_billing > network_avg_billing * 1.15
            THEN 'HIGH COST REVIEW'

        WHEN avg_billing > network_avg_billing
            THEN 'ABOVE NETWORK AVERAGE'

        ELSE 'WITHIN / BELOW NETWORK AVERAGE'
    END AS financial_status

FROM benchmarked

ORDER BY
    billing_gap_percentage DESC;
    
-- Hospital Capacity Pressure
-- Business Problem

-- Hospital management wants to identify hospitals experiencing potential capacity pressure due to
--  high admission volume, emergency demand, and a high proportion of long-stay patients.
-- Business Problem:
-- Identify hospitals showing potential capacity pressure
-- based on admission volume, emergency demand,
-- and long-stay patients.

WITH hospital_capacity AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(AVG(f.length_of_stay), 2) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS emergency_percentage,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage,

        ROUND(SUM(f.billing_amount), 2) AS total_revenue

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
),

network_benchmark AS (

    SELECT
        ROUND(AVG(total_admissions), 2) AS avg_hospital_admissions,
        ROUND(AVG(emergency_percentage), 2) AS avg_emergency_percentage,
        ROUND(AVG(long_stay_percentage), 2) AS avg_long_stay_percentage

    FROM hospital_capacity
)

SELECT
    hc.hospital_name,
    hc.total_admissions,
    hc.avg_length_of_stay,
    hc.emergency_admissions,
    hc.emergency_percentage,
    hc.long_stay_admissions,
    hc.long_stay_percentage,
    hc.total_revenue,

    nb.avg_hospital_admissions,
    nb.avg_emergency_percentage,
    nb.avg_long_stay_percentage,

    CASE
        WHEN hc.total_admissions > nb.avg_hospital_admissions
             AND hc.emergency_percentage > nb.avg_emergency_percentage
             AND hc.long_stay_percentage > nb.avg_long_stay_percentage
            THEN 'HIGH CAPACITY PRESSURE'

        WHEN hc.total_admissions > nb.avg_hospital_admissions
             AND (
                 hc.emergency_percentage > nb.avg_emergency_percentage
                 OR hc.long_stay_percentage > nb.avg_long_stay_percentage
             )
            THEN 'MODERATE CAPACITY PRESSURE'

        ELSE 'NORMAL'
    END AS capacity_status

FROM hospital_capacity hc

CROSS JOIN network_benchmark nb

ORDER BY
    capacity_status DESC,
    hc.long_stay_percentage DESC,
    hc.emergency_percentage DESC;
    
-- Emergency Service Pressure
-- Business Problem

-- Hospital management wants to identify hospitals where emergency admissions form a high share of total admissions and emergency patients
--  also have longer stays,so emergency-service workload can be prioritized for operational review.

-- Business Problem:
-- Identify hospitals with relatively high emergency admission
-- share and longer stays among emergency patients.

WITH emergency_analysis AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS emergency_percentage,

        ROUND(
            AVG(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.length_of_stay
                END
            ),
            2
        ) AS emergency_avg_los,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS overall_avg_los,

        ROUND(
            SUM(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.billing_amount
                    ELSE 0
                END
            ),
            2
        ) AS emergency_revenue

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        h.hospital_key,
        h.hospital_name

    HAVING COUNT(*) >= 20
),

benchmarked AS (

    SELECT
        ea.*,

        ROUND(
            AVG(ea.emergency_percentage) OVER (),
            2
        ) AS network_avg_emergency_percentage,

        ROUND(
            AVG(ea.emergency_avg_los) OVER (),
            2
        ) AS network_avg_emergency_los

    FROM emergency_analysis ea
)

SELECT
    hospital_name,
    total_admissions,
    emergency_admissions,
    emergency_percentage,
    emergency_avg_los,
    overall_avg_los,
    emergency_revenue,
    network_avg_emergency_percentage,
    network_avg_emergency_los,

    CASE
        WHEN emergency_percentage > network_avg_emergency_percentage
             AND emergency_avg_los > network_avg_emergency_los
            THEN 'HIGH EMERGENCY PRESSURE'

        WHEN emergency_percentage > network_avg_emergency_percentage
             OR emergency_avg_los > network_avg_emergency_los
            THEN 'MODERATE EMERGENCY PRESSURE'

        ELSE 'NORMAL'
    END AS emergency_status

FROM benchmarked

ORDER BY
    emergency_percentage DESC,
    emergency_avg_los DESC;
    

-- Patient Condition Intelligence

-- Business Problem:

-- Identify medical conditions with higher abnormal-test rates, emergency utilization, longer stays, and billing impact so that 
-- condition-specific areas can be prioritized for management review.

-- Business Problem:
-- Identify medical conditions with higher clinical,
-- operational and financial impact for management review.

WITH condition_metrics AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        -- Emergency admissions
        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions,

        -- Abnormal test results
        SUM(
            CASE
                WHEN t.test_result = 'Abnormal'
                THEN 1
                ELSE 0
            END
        ) AS abnormal_test_cases,

        -- Long-stay admissions
        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_cases,

        -- Average length of stay
        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        -- Average billing
        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        -- Total revenue
        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    JOIN dim_test_result t
        ON f.test_result_key = t.test_result_key

    GROUP BY
        c.condition_key,
        c.medical_condition
),

condition_analysis AS (

    SELECT
        cm.*,

        -- Emergency percentage
        ROUND(
            emergency_admissions * 100.0
            / total_admissions,
            2
        ) AS emergency_percentage,

        -- Abnormal test percentage
        ROUND(
            abnormal_test_cases * 100.0
            / total_admissions,
            2
        ) AS abnormal_test_percentage,

        -- Long-stay percentage
        ROUND(
            long_stay_cases * 100.0
            / total_admissions,
            2
        ) AS long_stay_percentage,

        -- Network average billing
        ROUND(
            AVG(avg_billing) OVER (),
            2
        ) AS network_avg_billing,

        -- Network average LOS
        ROUND(
            AVG(avg_length_of_stay) OVER (),
            2
        ) AS network_avg_los,

        -- Network average abnormal-test %
        ROUND(
            AVG(
                abnormal_test_cases * 100.0
                / total_admissions
            ) OVER (),
            2
        ) AS network_avg_abnormal_percentage

    FROM condition_metrics cm
)

SELECT
    medical_condition,

    total_admissions,

    emergency_admissions,
    emergency_percentage,

    abnormal_test_cases,
    abnormal_test_percentage,

    long_stay_cases,
    long_stay_percentage,

    avg_length_of_stay,
    avg_billing,
    total_revenue,

    network_avg_billing,
    network_avg_los,
    network_avg_abnormal_percentage,

    CASE
        WHEN
            abnormal_test_percentage > network_avg_abnormal_percentage
            AND avg_length_of_stay > network_avg_los
            AND avg_billing > network_avg_billing
        THEN 'HIGH PRIORITY REVIEW'

        WHEN
            abnormal_test_percentage > network_avg_abnormal_percentage
            OR avg_length_of_stay > network_avg_los
            OR avg_billing > network_avg_billing
        THEN 'MONITOR'

        ELSE 'NORMAL'
    END AS condition_status

FROM condition_analysis

ORDER BY
    CASE
        WHEN condition_status = 'HIGH PRIORITY REVIEW' THEN 1
        WHEN condition_status = 'MONITOR' THEN 2
        ELSE 3
    END,
    total_revenue DESC;
    
-- Condition Burden Analysis
-- Business Problem

-- Hospital management wants to identify which medical conditions contribute the most to overall patient admissions 
-- and healthcare revenue, so resources and management attention can be prioritized accordingly.

-- Business Problem:
-- Identify medical conditions contributing the most
-- to patient admissions and healthcare revenue.

WITH condition_metrics AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    GROUP BY
        c.condition_key,
        c.medical_condition
),

condition_analysis AS (

    SELECT
        medical_condition,
        total_admissions,
        total_revenue,

        -- Admission contribution %
        ROUND(
            total_admissions * 100.0
            / SUM(total_admissions) OVER (),
            2
        ) AS admission_contribution_percentage,

        -- Revenue contribution %
        ROUND(
            total_revenue * 100.0
            / SUM(total_revenue) OVER (),
            2
        ) AS revenue_contribution_percentage,

        -- Revenue ranking
        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        -- Admission volume ranking
        RANK() OVER (
            ORDER BY total_admissions DESC
        ) AS admission_rank

    FROM condition_metrics
)

SELECT
    medical_condition,
    total_admissions,
    admission_contribution_percentage,
    total_revenue,
    revenue_contribution_percentage,
    admission_rank,
    revenue_rank

FROM condition_analysis

ORDER BY
    revenue_rank;
    
-- Patient Condition Trend Analysis
-- Business Problem

-- Hospital management wants to identify how demand for each medical condition changes over time and detect
--  significant year-over-year increases or decreases in admissions.

-- Business Problem:
-- Identify year-over-year changes in admissions for each
-- medical condition to detect increasing or decreasing demand.

WITH yearly_condition_admissions AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        YEAR(d.full_date) AS admission_year,

        COUNT(*) AS total_admissions

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        c.condition_key,
        c.medical_condition,
        YEAR(d.full_date)
),

condition_growth AS (

    SELECT
        condition_key,
        medical_condition,
        admission_year,
        total_admissions,

        LAG(total_admissions) OVER (
            PARTITION BY condition_key
            ORDER BY admission_year
        ) AS previous_year_admissions

    FROM yearly_condition_admissions
)

SELECT
    medical_condition,
    admission_year,
    total_admissions,
    previous_year_admissions,

    ROUND(
        total_admissions - previous_year_admissions,
        0
    ) AS admission_change,

    ROUND(
        (total_admissions - previous_year_admissions)
        * 100.0
        / NULLIF(previous_year_admissions, 0),
        2
    ) AS yoy_growth_percentage,

    CASE
        WHEN previous_year_admissions IS NULL
            THEN 'NO PREVIOUS YEAR'

        WHEN total_admissions > previous_year_admissions
            THEN 'INCREASING'

        WHEN total_admissions < previous_year_admissions
            THEN 'DECREASING'

        ELSE 'STABLE'
    END AS trend_status

FROM condition_growth

ORDER BY
    medical_condition,
    admission_year;
    
 --    Abnormal Test Result Monitoring

-- Business Problem

-- Hospital management wants to identify which medical conditions have a higher proportion of abnormal test results, so those condition groups 
-- can be prioritized for further clinical and operational review.

-- Business Problem:
-- Identify medical conditions with a higher proportion
-- of abnormal test results for further review.

WITH condition_test_analysis AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        SUM(
            CASE
                WHEN t.test_result = 'Abnormal'
                THEN 1
                ELSE 0
            END
        ) AS abnormal_tests,

        ROUND(
            SUM(
                CASE
                    WHEN t.test_result = 'Abnormal'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS abnormal_test_percentage

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_test_result t
        ON f.test_result_key = t.test_result_key

    GROUP BY
        c.condition_key,
        c.medical_condition
),

network_benchmark AS (

    SELECT
        ROUND(
            SUM(
                CASE
                    WHEN t.test_result = 'Abnormal'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS network_abnormal_percentage

    FROM fact_admission f

    JOIN dim_test_result t
        ON f.test_result_key = t.test_result_key
)

SELECT
    cta.medical_condition,
    cta.total_admissions,
    cta.abnormal_tests,
    cta.abnormal_test_percentage,
    nb.network_abnormal_percentage,

    ROUND(
        cta.abnormal_test_percentage
        - nb.network_abnormal_percentage,
        2
    ) AS difference_from_network,

    CASE
        WHEN cta.abnormal_test_percentage
             > nb.network_abnormal_percentage
        THEN 'ABOVE NETWORK AVERAGE'

        WHEN cta.abnormal_test_percentage
             < nb.network_abnormal_percentage
        THEN 'BELOW NETWORK AVERAGE'

        ELSE 'AT NETWORK AVERAGE'
    END AS monitoring_status

FROM condition_test_analysis cta
CROSS JOIN network_benchmark nb

ORDER BY
    abnormal_test_percentage DESC;
    
-- Condition–Medication Pattern Analysis

-- Business Problem

-- Hospital management wants to understand which medications are most frequently associated with each medical condition, so medication 
-- utilization patterns can be monitored and healthcare resources can be planned accordingly.
WITH condition_medication AS (

    SELECT
        c.condition_key,
        c.medical_condition,
        m.medication_name,

        COUNT(*) AS medication_usage,

        ROUND(
            COUNT(*) * 100.0
            / SUM(COUNT(*)) OVER (
                PARTITION BY c.condition_key
            ),
            2
        ) AS usage_percentage

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_medication m
        ON f.medication_key = m.medication_key

    GROUP BY
        c.condition_key,
        c.medical_condition,
        m.medication_name
),

ranked_medications AS (

    SELECT
        medical_condition,
        medication_name,
        medication_usage,
        usage_percentage,

        RANK() OVER (
            PARTITION BY medical_condition
            ORDER BY medication_usage DESC
        ) AS medication_rank

    FROM condition_medication
)

SELECT
    medical_condition,
    medication_name,
    medication_usage,
    usage_percentage,
    medication_rank

FROM ranked_medications

ORDER BY
    medical_condition,
    medication_rank;

-- Condition-wise Financial & Hospitalization Burden
-- Hospital management wants to identify medical conditions that create a high overall healthcare burden by combining admission volume,
--  revenue generated, average length of stay, and long-stay admissions.
-- Business Problem:
-- Identify medical conditions creating the highest
-- operational and financial burden for the hospital network.

WITH condition_metrics AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    GROUP BY
        c.condition_key,
        c.medical_condition
),

condition_analysis AS (

    SELECT
        medical_condition,
        total_admissions,
        total_revenue,
        avg_billing,
        avg_length_of_stay,
        long_stay_admissions,
        long_stay_percentage,

        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        RANK() OVER (
            ORDER BY long_stay_percentage DESC
        ) AS long_stay_rank

    FROM condition_metrics
)

SELECT
    medical_condition,
    total_admissions,
    total_revenue,
    avg_billing,
    avg_length_of_stay,
    long_stay_admissions,
    long_stay_percentage,
    revenue_rank,
    long_stay_rank,

    CASE
        WHEN revenue_rank <= 2
             AND long_stay_rank <= 2
        THEN 'HIGH OVERALL BURDEN'

        WHEN revenue_rank <= 2
        THEN 'HIGH FINANCIAL BURDEN'

        WHEN long_stay_rank <= 2
        THEN 'HIGH OPERATIONAL BURDEN'

        ELSE 'NORMAL MONITORING'
    END AS burden_category

FROM condition_analysis

ORDER BY
    revenue_rank;
    
-- Emergency Admission Pressure

-- Business Problem

-- Hospital management wants to identify which medical conditions generate the highest emergency-admission pressure and 
-- whether those conditions also have longer hospital stays and higher billing.

-- Business Problem:
-- Identify medical conditions creating the highest
-- emergency admission pressure and compare their
-- operational and financial impact.

WITH condition_emergency_analysis AS (

    SELECT
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS emergency_percentage,

        ROUND(
            AVG(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.length_of_stay
                END
            ),
            2
        ) AS emergency_avg_los,

        ROUND(
            AVG(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.billing_amount
                END
            ),
            2
        ) AS emergency_avg_billing

    FROM fact_admission f

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        c.condition_key,
        c.medical_condition
)

SELECT
    medical_condition,
    total_admissions,
    emergency_admissions,
    emergency_percentage,
    emergency_avg_los,
    emergency_avg_billing,

    RANK() OVER (
        ORDER BY emergency_percentage DESC
    ) AS emergency_pressure_rank,

    CASE
        WHEN emergency_percentage >= 34
             AND emergency_avg_los >= 15
        THEN 'HIGH EMERGENCY PRESSURE'

        WHEN emergency_percentage >= 34
        THEN 'HIGH EMERGENCY VOLUME'

        WHEN emergency_avg_los >= 15
        THEN 'LONG STAY - MONITOR'

        ELSE 'NORMAL MONITORING'
    END AS operational_status

FROM condition_emergency_analysis

ORDER BY
    emergency_pressure_rank;
    
-- Insurance Utilization & Financial Burden
-- Hospital management wants to compare insurance providers based on patient utilization, total billing, average billing, and average length of stay 
-- to understand insurance-wise financial exposure.

-- Business Problem:
-- Compare insurance providers based on patient utilization,
-- revenue contribution, billing and hospitalization burden.

WITH insurance_metrics AS (

    SELECT
        i.insurance_key,
        i.insurance_provider,

        COUNT(*) AS total_admissions,

        COUNT(DISTINCT f.patient_key) AS total_patients,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions

    FROM fact_admission f

    JOIN dim_insurance i
        ON f.insurance_key = i.insurance_key

    GROUP BY
        i.insurance_key,
        i.insurance_provider
),

insurance_analysis AS (

    SELECT
        insurance_provider,
        total_admissions,
        total_patients,
        total_revenue,
        avg_billing,
        avg_length_of_stay,
        long_stay_admissions,

        ROUND(
            total_admissions * 100.0
            / SUM(total_admissions) OVER (),
            2
        ) AS admission_share_percentage,

        ROUND(
            total_revenue * 100.0
            / SUM(total_revenue) OVER (),
            2
        ) AS revenue_share_percentage,

        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank

    FROM insurance_metrics
)

SELECT
    insurance_provider,
    total_admissions,
    total_patients,
    admission_share_percentage,
    total_revenue,
    revenue_share_percentage,
    avg_billing,
    avg_length_of_stay,
    long_stay_admissions,
    revenue_rank,

    CASE
        WHEN revenue_share_percentage >= 20
             AND avg_billing > 25594.63
        THEN 'HIGH FINANCIAL EXPOSURE'

        WHEN revenue_share_percentage >= 20
        THEN 'HIGH UTILIZATION'

        ELSE 'NORMAL MONITORING'
    END AS insurance_status

FROM insurance_analysis

ORDER BY
    total_revenue DESC;
--     
-- Hospital × Condition Performance

-- Business Problem

-- Hospital management wants to identify the medical conditions that create the highest operational and financial burden within each hospital, 
-- so hospital-specific resources and management attention can be focused on the most significant condition groups.

-- Business Problem:
-- Identify the highest-impact medical conditions
-- within each hospital.

WITH hospital_condition_metrics AS (

    SELECT
        h.hospital_key,
        h.hospital_name,
        c.condition_key,
        c.medical_condition,

        COUNT(*) AS total_admissions,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    GROUP BY
        h.hospital_key,
        h.hospital_name,
        c.condition_key,
        c.medical_condition
),

ranked_conditions AS (

    SELECT
        hospital_name,
        medical_condition,
        total_admissions,
        total_revenue,
        avg_billing,
        avg_length_of_stay,
        long_stay_admissions,

        RANK() OVER (
            PARTITION BY hospital_name
            ORDER BY total_revenue DESC
        ) AS condition_revenue_rank,

        RANK() OVER (
            PARTITION BY hospital_name
            ORDER BY total_admissions DESC
        ) AS condition_admission_rank

    FROM hospital_condition_metrics
)

SELECT
    hospital_name,
    medical_condition,
    total_admissions,
    total_revenue,
    avg_billing,
    avg_length_of_stay,
    long_stay_admissions,
    condition_admission_rank,
    condition_revenue_rank,

    CASE
        WHEN condition_revenue_rank = 1
             AND condition_admission_rank = 1
        THEN 'TOP HOSPITAL CONDITION'

        WHEN condition_revenue_rank = 1
        THEN 'TOP REVENUE CONDITION'

        WHEN condition_admission_rank = 1
        THEN 'TOP VOLUME CONDITION'

        ELSE 'OTHER'
    END AS condition_status

FROM ranked_conditions

WHERE total_admissions >= 2

ORDER BY
    hospital_name,
    condition_revenue_rank;
    
-- Hospital Performance Benchmarking
-- Business Problem

-- Hospital management wants to compare each hospital's operational and financial performance against the overall hospital-network averages 
-- to identify hospitals that differ significantly from network benchmarks.

-- Business Problem:
-- Benchmark each hospital against overall network performance
-- using operational and financial KPIs.

WITH hospital_metrics AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name
),

network_benchmark AS (

    SELECT
        ROUND(AVG(avg_billing), 2) AS network_avg_billing,
        ROUND(AVG(avg_length_of_stay), 2) AS network_avg_los,
        ROUND(AVG(long_stay_percentage), 2) AS network_avg_long_stay_percentage

    FROM hospital_metrics
)

SELECT
    hm.hospital_name,
    hm.total_admissions,
    hm.total_revenue,
    hm.avg_billing,
    hm.avg_length_of_stay,
    hm.long_stay_percentage,

    nb.network_avg_billing,
    nb.network_avg_los,
    nb.network_avg_long_stay_percentage,

    ROUND(
        hm.avg_billing - nb.network_avg_billing,
        2
    ) AS billing_gap,

    ROUND(
        hm.avg_length_of_stay - nb.network_avg_los,
        2
    ) AS los_gap,

    ROUND(
        hm.long_stay_percentage
        - nb.network_avg_long_stay_percentage,
        2
    ) AS long_stay_gap

FROM hospital_metrics hm

CROSS JOIN network_benchmark nb

WHERE hm.total_admissions >= 5

ORDER BY
    billing_gap DESC;
--     
-- Hospital Resource Pressure by Admission Type

-- Business Problem

-- Hospital management wants to identify hospitals where emergency admissions represent a significant share of total workload and 
-- are associated with longer stays or higher billing.

-- Business Problem:
-- Identify hospitals with high emergency-admission pressure
-- and compare their operational and financial impact.

WITH hospital_admission_analysis AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        SUM(
            CASE
                WHEN a.admission_type = 'Emergency'
                THEN 1
                ELSE 0
            END
        ) AS emergency_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS emergency_percentage,

        ROUND(
            AVG(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.length_of_stay
                END
            ),
            2
        ) AS emergency_avg_los,

        ROUND(
            AVG(
                CASE
                    WHEN a.admission_type = 'Emergency'
                    THEN f.billing_amount
                END
            ),
            2
        ) AS emergency_avg_billing

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        h.hospital_key,
        h.hospital_name
)

SELECT
    hospital_name,
    total_admissions,
    emergency_admissions,
    emergency_percentage,
    emergency_avg_los,
    emergency_avg_billing,

    RANK() OVER (
        ORDER BY emergency_percentage DESC
    ) AS emergency_pressure_rank,

    CASE
        WHEN emergency_percentage >= 40
             AND emergency_avg_los >= 15
        THEN 'HIGH EMERGENCY PRESSURE'

        WHEN emergency_percentage >= 40
        THEN 'HIGH EMERGENCY VOLUME'

        WHEN emergency_avg_los >= 15
        THEN 'LONG EMERGENCY STAY'

        ELSE 'NORMAL MONITORING'
    END AS pressure_status

FROM hospital_admission_analysis

WHERE total_admissions >= 5

ORDER BY
    emergency_pressure_rank;
    
--     
-- Hospital Length-of-Stay Efficiency
-- Business Problem

-- Hospital management wants to identify hospitals and admission types with unusually long patient stays, understand the operational impact, 
-- and identify areas where patient throughput should be reviewed.

-- Business Problem:
-- Identify hospitals and admission types with long patient stays
-- and measure their operational and financial impact.

WITH hospital_los AS (

    SELECT
        h.hospital_key,
        h.hospital_name,
        a.admission_type,

        COUNT(*) AS total_admissions,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.revenue_per_stay_day),
            2
        ) AS avg_revenue_per_stay_day

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        h.hospital_key,
        h.hospital_name,
        a.admission_type

    HAVING COUNT(*) >= 5
),

ranked_los AS (

    SELECT
        hospital_name,
        admission_type,
        total_admissions,
        avg_length_of_stay,
        long_stay_admissions,
        long_stay_percentage,
        total_revenue,
        avg_revenue_per_stay_day,

        RANK() OVER (
            ORDER BY long_stay_percentage DESC
        ) AS long_stay_pressure_rank

    FROM hospital_los
)

SELECT
    hospital_name,
    admission_type,
    total_admissions,
    avg_length_of_stay,
    long_stay_admissions,
    long_stay_percentage,
    total_revenue,
    avg_revenue_per_stay_day,
    long_stay_pressure_rank,

    CASE
        WHEN long_stay_percentage >= 50
             AND avg_length_of_stay >= 20
        THEN 'HIGH LOS PRESSURE'

        WHEN long_stay_percentage >= 50
        THEN 'HIGH LONG-STAY VOLUME'

        WHEN avg_length_of_stay >= 20
        THEN 'HIGH AVERAGE LOS'

        ELSE 'NORMAL MONITORING'
    END AS operational_status

FROM ranked_los

ORDER BY
    long_stay_pressure_rank;
    
-- Hospital Revenue Concentration & Pareto Analysis

-- Business Problem

-- Hospital management wants to determine whether a large share of total network revenue is concentrated among a 
-- relatively small number of hospitals.

-- Business Problem:
-- Identify how hospital revenue is distributed across the network
-- and determine how quickly hospitals contribute to cumulative revenue.

WITH hospital_revenue AS (

    SELECT
        h.hospital_key,
        h.hospital_name,

        COUNT(*) AS total_admissions,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    GROUP BY
        h.hospital_key,
        h.hospital_name
),

revenue_analysis AS (

    SELECT
        hospital_name,
        total_admissions,
        total_revenue,

        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        ROUND(
            total_revenue * 100.0
            / SUM(total_revenue) OVER (),
            2
        ) AS revenue_contribution_percentage,

        ROUND(
            SUM(total_revenue) OVER (
                ORDER BY total_revenue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            ) * 100.0
            / SUM(total_revenue) OVER (),
            2
        ) AS cumulative_revenue_percentage

    FROM hospital_revenue
)

SELECT
    hospital_name,
    total_admissions,
    total_revenue,
    revenue_rank,
    revenue_contribution_percentage,
    cumulative_revenue_percentage,

    CASE
        WHEN cumulative_revenue_percentage <= 80
        THEN 'WITHIN 80% REVENUE GROUP'

        ELSE 'ABOVE 80% REVENUE POINT'
    END AS pareto_group

FROM revenue_analysis

ORDER BY
    revenue_rank;
    
-- Billing vs Length-of-Stay Efficiency
-- Business Problem

-- Hospital management wants to identify admissions where billing is high or low relative to the patient's length of stay, 
-- helping them understand revenue efficiency across different hospitalization durations.

-- Business Problem:
-- Analyze billing efficiency relative to patient length of stay
-- and identify unusually high or low revenue-per-stay-day admissions.

WITH admission_efficiency AS (

    SELECT
        f.admission_key,
        h.hospital_name,
        c.medical_condition,
        a.admission_type,

        f.length_of_stay,
        ROUND(f.billing_amount, 2) AS billing_amount,

        ROUND(
            f.billing_amount / NULLIF(f.length_of_stay, 0),
            2
        ) AS revenue_per_stay_day

    FROM fact_admission f

    JOIN dim_hospital h
        ON f.hospital_key = h.hospital_key

    JOIN dim_medical_condition c
        ON f.condition_key = c.condition_key

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key
),

network_benchmark AS (

    SELECT
        ROUND(
            AVG(revenue_per_stay_day),
            2
        ) AS network_avg_revenue_per_day

    FROM admission_efficiency
)

SELECT
    ae.admission_key,
    ae.hospital_name,
    ae.medical_condition,
    ae.admission_type,
    ae.length_of_stay,
    ae.billing_amount,
    ae.revenue_per_stay_day,

    nb.network_avg_revenue_per_day,

    ROUND(
        ae.revenue_per_stay_day
        - nb.network_avg_revenue_per_day,
        2
    ) AS revenue_per_day_gap,

    CASE
        WHEN ae.revenue_per_stay_day
             >= nb.network_avg_revenue_per_day * 1.50
        THEN 'HIGH REVENUE PER DAY'

        WHEN ae.revenue_per_stay_day
             <= nb.network_avg_revenue_per_day * 0.50
        THEN 'LOW REVENUE PER DAY'

        ELSE 'NORMAL'
    END AS efficiency_status

FROM admission_efficiency ae

CROSS JOIN network_benchmark nb

ORDER BY
    ae.revenue_per_stay_day DESC;
    
-- High-Risk Operational Pattern Analysis

-- Business Problem

-- Hospital management wants to identify admission patterns where emergency admission, abnormal test results, and prolonged hospitalization occur together,
--  so these cases can be prioritized for operational review.

-- Business Problem:
-- Identify admissions where emergency admission,
-- abnormal test results and long hospitalization
-- occur together.

SELECT
    f.admission_key,
    h.hospital_name,
    c.medical_condition,
    a.admission_type,
    t.test_result,

    f.length_of_stay,
    ROUND(f.billing_amount, 2) AS billing_amount,

    CASE
        WHEN a.admission_type = 'Emergency'
        THEN 'YES'
        ELSE 'NO'
    END AS emergency_flag,

    CASE
        WHEN t.test_result = 'Abnormal'
        THEN 'YES'
        ELSE 'NO'
    END AS abnormal_test_flag,

    CASE
        WHEN f.length_of_stay > 20
        THEN 'YES'
        ELSE 'NO'
    END AS long_stay_flag,

    (
        CASE
            WHEN a.admission_type = 'Emergency'
            THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN t.test_result = 'Abnormal'
            THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN f.length_of_stay > 20
            THEN 1
            ELSE 0
        END
    ) AS operational_signal_score,

    CASE
        WHEN
            a.admission_type = 'Emergency'
            AND t.test_result = 'Abnormal'
            AND f.length_of_stay > 20
        THEN 'MULTIPLE OPERATIONAL SIGNALS'

        WHEN
            a.admission_type = 'Emergency'
            AND t.test_result = 'Abnormal'
        THEN 'EMERGENCY + ABNORMAL TEST'

        WHEN
            a.admission_type = 'Emergency'
            AND f.length_of_stay > 20
        THEN 'EMERGENCY + LONG STAY'

        WHEN
            t.test_result = 'Abnormal'
            AND f.length_of_stay > 20
        THEN 'ABNORMAL TEST + LONG STAY'

        ELSE 'SINGLE/NO SIGNAL'
    END AS operational_pattern

FROM fact_admission f

JOIN dim_hospital h
    ON f.hospital_key = h.hospital_key

JOIN dim_medical_condition c
    ON f.condition_key = c.condition_key

JOIN dim_admission_type a
    ON f.admission_type_key = a.admission_type_key

JOIN dim_test_result t
    ON f.test_result_key = t.test_result_key

WHERE
    a.admission_type = 'Emergency'
    OR t.test_result = 'Abnormal'
    OR f.length_of_stay > 20

ORDER BY
    operational_signal_score DESC,
    f.length_of_stay DESC;
    
-- Emergency vs Elective Resource Demand
-- Business Problem

-- Hospital management wants to understand how emergency, urgent, and elective admissions differ in patient volume, length of stay, 
-- billing, and long-stay burden to support resource planning.

-- Business Problem:
-- Compare Emergency, Urgent and Elective admissions
-- across volume, hospitalization and financial metrics.

WITH admission_type_metrics AS (

    SELECT
        a.admission_type,

        COUNT(*) AS total_admissions,

        COUNT(DISTINCT f.patient_key) AS total_patients,

        ROUND(
            COUNT(*) * 100.0
            / SUM(COUNT(*)) OVER (),
            2
        ) AS admission_share_percentage,

        ROUND(
            AVG(f.length_of_stay),
            2
        ) AS avg_length_of_stay,

        SUM(
            CASE
                WHEN f.length_of_stay > 20
                THEN 1
                ELSE 0
            END
        ) AS long_stay_admissions,

        ROUND(
            SUM(
                CASE
                    WHEN f.length_of_stay > 20
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS long_stay_percentage,

        ROUND(
            SUM(f.billing_amount),
            2
        ) AS total_revenue,

        ROUND(
            AVG(f.billing_amount),
            2
        ) AS avg_billing,

        ROUND(
            AVG(f.revenue_per_stay_day),
            2
        ) AS avg_revenue_per_stay_day

    FROM fact_admission f

    JOIN dim_admission_type a
        ON f.admission_type_key = a.admission_type_key

    GROUP BY
        a.admission_type
)

SELECT
    admission_type,
    total_admissions,
    total_patients,
    admission_share_percentage,
    avg_length_of_stay,
    long_stay_admissions,
    long_stay_percentage,
    total_revenue,
    avg_billing,
    avg_revenue_per_stay_day,

    RANK() OVER (
        ORDER BY total_admissions DESC
    ) AS volume_rank,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,

    RANK() OVER (
        ORDER BY avg_length_of_stay DESC
    ) AS los_rank

FROM admission_type_metrics

ORDER BY
    volume_rank;