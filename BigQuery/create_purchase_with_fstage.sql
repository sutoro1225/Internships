WITH orders_grouped AS (
SELECT
appsflyer_id,
customer_user_id,
af_receipt_id,
MIN(PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', event_time)) AS purchased_at,
SUM(SAFE_CAST(af_revenue AS FLOAT64)) AS total_revenue,
ANY_VALUE(af_currency) AS af_currency,
ANY_VALUE(af_coupon_id) AS af_coupon_id,
ANY_VALUE(media_source) AS media_source
FROM `project-dataset.client_project.client_purchase`
GROUP BY appsflyer_id, customer_user_id, af_receipt_id
)
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY appsflyer_id ORDER BY purchased_at) AS f_stage
FROM orders_grouped
ORDER BY
appsflyer_id,
purchased_at
