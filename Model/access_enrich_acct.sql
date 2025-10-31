{{
  config(
    materialized='table'
  )
}}

WITH source_data AS (
    -- Source table for access events
    SELECT * FROM {{ ref('int_cap_sat') }}
),

final AS (
    SELECT
        s.account_id,
        s.access_time AS access_timestamp,
        -- Map channel_code to a readable channel name
        CASE
            WHEN s.channel_code = '01' THEN 'Web'
            WHEN s.channel_code = '02' THEN 'Mobile'
            ELSE 'Unknown'
        END AS access_channel,
        s.status AS account_status,
        s.customer_id,
        s.segment_code AS customer_segment, -- Direct mapping from source
        s.product_code AS product_type,     -- Direct mapping from source
        -- Logic: Flag as suspicious if login_count > 10 in the last hour
        (s.login_count > 10) AS suspicious_access,
        -- Logic: Flag as high value if balance > 100K and segment is 'HNI'
        (s.balance > 100000 AND s.segment_code = 'HNI') AS high_value_customer,
        s.geo_location
    FROM source_data s
)

SELECT * FROM final