CREATE OR REPLACE TABLE `project-dataset.client_project.push_notice_joined` AS
WITH
notif AS (
SELECT
n.*,
TRIM(REGEXP_REPLACE(
REPLACE(TRANSLATE(n.event_label,
'０１２３４５６７８９，．％￥！－〜／：',
'0123456789,.%¥!-~/:'
), '\n', ' '),
r'\s+', ' '
)) AS event_label_norm
FROM `project-dataset.management_database.client_app_notification` n
WHERE n.push_type IN ('セグメント', '全体配信')
AND LOWER(n.sku) = '[SKU_ID]'
),
feat AS (
SELECT
f.*,
TRIM(REGEXP_REPLACE(
REPLACE(TRANSLATE(f.event_label,
'０１２３４５６７８９，．％￥！－〜／：',
'0123456789,.%¥!-~/:'
), '\n', ' '),
r'\s+', ' '
)) AS event_label_norm
FROM `project-dataset.client_project.push_notice_feature` f
)
SELECT
n.sku,
n.notification_id,
n.event_label,
n.release_time,
n.target_UU, n.open_cnt, n.detail_cnt,
n.push_type AS notif_push_type,

f.length, f.length_bin,
f.emoji_count, f.emoji_unique_count, f.symbol_count,
f.exclamation_count,
f.has_currency, f.has_discount, f.urgency_count,
f.discount_amount_yen, f.discount_percent, f.discount_type,
f.has_coupon_word, f.has_time_word, f.has_limit_word,
f.question_mark_count, f.has_cta_word,
f.push_type AS content_push_type
FROM notif n
LEFT JOIN feat f
USING (event_label_norm)
WHERE
f.push_type is not null
ORDER BY n.release_time DESC
