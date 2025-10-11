{{
  config(
    materialized='table'
  )
}}

WITH int_cust_sat AS (
    SELECT
        CUST_ID,
        FULL_NAME,
        CUST_TYPE,
        EMAIL_ADDR,
        PHONE_NUM,
        SRC_EFF_FROM_DTTM,
        SRC_EFF_TO_DTTM,
        RDH_EFF_FROM_DTTM,
        RDH_EFF_TO_DTTM,
        SRC_COUNTRY,
        RDH_LOAD_DTTM
    FROM {{ ref('int_cust_sat') }}
),

int_cust_addr_lsat AS (
    SELECT
        CUST_ID,
        ADDR_ID,
        ADDR_TYPE,
        IS_PRIMARY,
        EFFECTIVE_DATE,
        END_DATE
    FROM {{ ref('int_cust_addr_lsat') }}
),

int_addr_sat AS (
    SELECT
        ADDR_ID,
        STREET_NAME,
        CITY_NAME,
        STATE_CODE,
        POSTAL_CODE,
        COUNTRY_NAME
    FROM {{ ref('int_addr_sat') }}
),

final AS (
    SELECT
        ics.cust_id AS CUST_ID,
        ics.full_name AS CUST_NAME,
        ics.cust_type AS CUST_TYPE,
        ics.email_addr AS EMAIL,
        ics.phone_num AS PHONE,
        icals.addr_id AS ADDR_ID,
        icals.addr_type AS ADDR_TYPE,
        ias.street_name AS STREET,
        ias.city_name AS CITY,
        ias.state_code AS STATE,
        ias.postal_code AS POSTCODE,
        ias.country_name AS COUNTRY,
        icals.is_primary AS IS_PRIMARY_ADDR,
        icals.effective_date AS ADDR_EFFECTIVE_DATE,
        icals.end_date AS ADDR_END_DATE,
        'ACCESS_ENRICH_CUST' AS RECORD_SOURCE,
        CURRENT_DATE AS LOAD_DATE,
        ics.src_eff_from_dttm AS SOURCE_EFFECTIVE_FROM_DTTM,
        ics.src_eff_to_dttm AS SOURCE_EFFECTIVE_TO_DTTM,
        ics.rdh_eff_from_dttm AS RDH_EFFECTIVE_FROM_DTTM,
        ics.rdh_eff_to_dttm AS RDH_EFFECTIVE_TO_DTTM,
        ics.src_country AS SOURCE_COUNTRY,
        ics.rdh_load_dttm AS RDH_LOAD_DTTM
    FROM int_cust_sat ics
    JOIN int_cust_addr_lsat icals ON ics.cust_id = icals.cust_id
    JOIN int_addr_sat ias ON icals.addr_id = ias.addr_id
)

SELECT
    CUST_ID,
    CUST_NAME,
    CUST_TYPE,
    EMAIL,
    PHONE,
    ADDR_ID,
    ADDR_TYPE,
    STREET,
    CITY,
    STATE,
    POSTCODE,
    COUNTRY,
    IS_PRIMARY_ADDR,
    ADDR_EFFECTIVE_DATE,
    ADDR_END_DATE,
    RECORD_SOURCE,
    LOAD_DATE,
    SOURCE_EFFECTIVE_FROM_DTTM,
    SOURCE_EFFECTIVE_TO_DTTM,
    RDH_EFFECTIVE_FROM_DTTM,
    RDH_EFFECTIVE_TO_DTTM,
    SOURCE_COUNTRY,
    RDH_LOAD_DTTM
FROM final