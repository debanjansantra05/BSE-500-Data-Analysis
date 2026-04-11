CREATE DATABASE bse500_project;
USE bse500_project;

CREATE TABLE company_yearly_data (
    year INT,
    scrip_code INT,
    company_name VARCHAR(255),
    isin VARCHAR(50),
    corp_address TEXT,
    corp_city VARCHAR(100),
    corp_district VARCHAR(100),
    corp_state VARCHAR(100),
    corp_pincode VARCHAR(20),
    corp_source VARCHAR(100),
    head_address TEXT,
    head_city VARCHAR(100),
    head_district VARCHAR(100),
    head_state VARCHAR(100),
    head_pincode VARCHAR(20),
    head_source VARCHAR(100),
    comments TEXT
);

CREATE TABLE company_summary (
    scrip_code INT PRIMARY KEY,
    company_name VARCHAR(255),
    no_of_years INT,
    years TEXT
);

CREATE TABLE clean_company_yearly_data AS
SELECT * FROM company_yearly_data WHERE 1=0;

INSERT INTO clean_company_yearly_data
SELECT DISTINCT
    CAST(year AS UNSIGNED) AS year,
    CAST(scrip_code AS UNSIGNED) AS scrip_code,
    
    TRIM(company_name) AS company_name,
    TRIM(isin) AS isin,

    COALESCE(NULLIF(TRIM(corp_address), ''), 'UNKNOWN') AS corp_address,
    UPPER(TRIM(corp_city)) AS corp_city,
    UPPER(TRIM(corp_district)) AS corp_district,
    UPPER(TRIM(corp_state)) AS corp_state,
    TRIM(corp_pincode) AS corp_pincode,
    corp_source,

    COALESCE(NULLIF(TRIM(head_address), ''), 'UNKNOWN') AS head_address,
    UPPER(TRIM(head_city)) AS head_city,
    UPPER(TRIM(head_district)) AS head_district,
    UPPER(TRIM(head_state)) AS head_state,
    TRIM(head_pincode) AS head_pincode,
    head_source,

    comments
FROM company_yearly_data;

-- Companies present all 15 years

SELECT scrip_code, company_name
FROM company_summary
WHERE no_of_years = 15;

-- Most common corporate state

SELECT corp_state, COUNT(*) as total
FROM company_yearly_data
GROUP BY corp_state
ORDER BY total DESC;

-- Years of Twitter presence per company

SELECT 
    scrip_code,
    company_name,
    LENGTH(years) - LENGTH(REPLACE(years, ',', '')) + 1 AS twitter_active_years,
    SUBSTRING_INDEX(years, ',', 1) AS first_active_year,
    SUBSTRING_INDEX(years, ',', -1) AS last_active_year,
    years AS years_active
FROM company_summary;

-- Which companies changed location?

SELECT 
    scrip_code,
    company_name,
    COUNT(DISTINCT corp_city) AS city_changes,
    COUNT(DISTINCT corp_state) AS state_changes
FROM clean_company_yearly_data
GROUP BY scrip_code, company_name
HAVING city_changes > 1 OR state_changes > 1
ORDER BY state_changes DESC;

-- Companies with longest continuous presence

SELECT 
    scrip_code,
    company_name,
    MAX(year) - MIN(year) + 1 AS continuous_span
FROM clean_company_yearly_data
GROUP BY scrip_code, company_name
ORDER BY continuous_span DESC;
