CREATE OR REPLACE TABLE `project-dataset.client_project.notice_user_f2_24h` AS
WITH
params AS (
SELECT
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M', '2024/12/15 19:30') AS start_ts
),
open_events AS (
SELECT
o.appsflyer_id,
o.customer_user_id,
COALESCE(
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', o.notice_time),
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M', o.notice_time)
) AS notice_ts,
COALESCE(
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', o.action_time),
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M', o.action_time)
) AS open_ts,
o.media_source,
o.action,
o.message
FROM `project-dataset.client_project.push_notice_open` o
CROSS JOIN params p
WHERE
(o.action IN ('つうちが開封された', '通知が開封された', '開封') OR o.action LIKE '%開封%')
AND COALESCE(
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', o.notice_time),
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M', o.notice_time)
) >= p.start_ts
),
notif_features AS (
SELECT
COALESCE(
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', n.release_time),
SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M', n.release_time)
) AS release_ts,
n.sku,
n.event_label,
n.target_UU, n.open_cnt, n.detail_cnt,
n.notif_push_type,
n.length, n.length_bin,
n.emoji_count, n.emoji_unique_count, n.symbol_count, n.exclamation_count,
n.has_currency, n.has_discount, n.urgency_count,
n.discount_amount_yen, n.discount_percent, n.discount_type,
n.has_coupon_word, n.has_time_word, n.has_limit_word,
n.question_mark_count, n.has_cta_word, n.content_push_type
FROM `project-dataset.client_project.push_notice_joined` n
),
purchases AS (
SELECT
p.appsflyer_id,
p.purchased_at AS purchase_ts,
p.f_stage,
p.total_revenue,
p.af_currency,
p.af_receipt_id,
p.customer_user_id
FROM `project-dataset.client_project.purchase_with_fstage` p
),
opened_with_feat AS (
SELECT
e.*,
f.sku, f.event_label, f.target_UU, f.open_cnt, f.detail_cnt,
f.notif_push_type, f.length, f.length_bin,
f.emoji_count, f.emoji_unique_count, f.symbol_count, f.exclamation_count,
f.has_currency, f.has_discount, f.urgency_count,
f.discount_amount_yen, f.discount_percent, f.discount_type,
f.has_coupon_word, f.has_time_word, f.has_limit_word,
f.question_mark_count, f.has_cta_word, f.content_push_type
FROM open_events e
LEFT JOIN notif_features f
ON f.release_ts = e.notice_ts
),
prior_status AS (
SELECT
e.appsflyer_id,
e.notice_ts,
COALESCE(MAX(CASE WHEN p.purchase_ts < e.notice_ts THEN p.f_stage END), 0) AS prior_max_stage,
COUNTIF(p.purchase_ts < e.notice_ts AND p.f_stage = 1) AS prior_f1_cnt,
COUNTIF(p.purchase_ts < e.notice_ts AND p.f_stage >= 2) AS prior_f2_cnt
FROM opened_with_feat e
LEFT JOIN purchases p
ON p.appsflyer_id = e.appsflyer_id
GROUP BY e.appsflyer_id, e.notice_ts
),
f2_within_24h AS (
SELECT
e.appsflyer_id,
e.notice_ts,
COUNTIF(p.f_stage = 2
AND p.purchase_ts >= e.notice_ts
AND p.purchase_ts < TIMESTAMP_ADD(e.notice_ts, INTERVAL 24 HOUR)) AS f2_hits_24h
FROM opened_with_feat e
LEFT JOIN purchases p
ON p.appsflyer_id = e.appsflyer_id
GROUP BY e.appsflyer_id, e.notice_ts
)
SELECT
o.appsflyer_id,
o.customer_user_id,
o.media_source,
o.action,
o.message,
o.notice_ts,
o.open_ts,
o.sku, o.event_label,
o.target_UU, o.open_cnt, o.detail_cnt,
o.notif_push_type,
o.length, o.length_bin,
o.emoji_count, o.emoji_unique_count, o.symbol_count, o.exclamation_count,
o.has_currency, o.has_discount, o.urgency_count,
o.discount_amount_yen, o.discount_percent, o.discount_type,
o.has_coupon_word, o.has_time_word, o.has_limit_word,
o.question_mark_count, o.has_cta_word, o.content_push_type,
ps.prior_max_stage,
ps.prior_f1_cnt,
ps.prior_f2_cnt,
f2.f2_hits_24h,
(ps.prior_f1_cnt > 0 AND ps.prior_f2_cnt = 0) AS base_status_f1_only,
(f2.f2_hits_24h > 0) AS f2_within_24h
FROM opened_with_feat o
LEFT JOIN prior_status ps
ON ps.appsflyer_id = o.appsflyer_id AND ps.notice_ts = o.notice_ts
LEFT JOIN f2_within_24h f2
ON f2.appsflyer_id = o.appsflyer_id AND f2.notice_ts = o.notice_ts
ORDER BY o.notice_ts DESC
