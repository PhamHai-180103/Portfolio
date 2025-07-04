--q1: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
SELECT distinct format_date ('%Y%m',PARSE_DATE('%Y%m%d', date)) as month 
    , sum (totals.visits) as visits
    , sum (totals.pageviews) as pageviews
    , sum (totals.transactions) as transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
     GROUP BY month
     ORDER BY month;
--q2: Bounce rate per traffic source in July 2017
SELECT
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;
--q3: Revenue by traffic source by week, by month in June 2017
WITH MonthlyRevenue AS (
  SELECT
    'Month' AS time_type,
    format_date ('%Y%m',PARSE_DATE('%Y%m%d', date)) as time,
    trafficSource.source AS source,
    SUM(product.productRevenue) / 1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      , UNNEST (hits) hit
      , UNNEST (product) product
  WHERE
     _table_suffix between '0601' and '0701'
     AND productRevenue IS NOT NULL
  GROUP BY
    time_type, time, source
),
WeeklyRevenue AS (
  SELECT
    'Week' AS time_type,
    format_date ('%Y%W',PARSE_DATE('%Y%m%d', date)) as time,
    trafficSource.source  AS source,
    SUM(product.productRevenue) / 1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
   , UNNEST (hits) hit
    , UNNEST (product) product
  WHERE
    _table_suffix between '0601' and '0701'
    AND productRevenue IS NOT NULL
  GROUP BY
    time_type, time, source
)
SELECT time_type, time, source, revenue    
 FROM MonthlyRevenue
UNION ALL
SELECT time_type, time, source, revenue
FROM WeeklyRevenue
ORDER BY revenue desc;
--q4: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;
--q5: Average number of transactions per user that made a purchase in July 2017
WITH 
  purchasers AS (
    SELECT
      format_date ('%Y%m',PARSE_DATE('%Y%m%d', date)) as month,
      fullVisitorId,
      SUM(totals.transactions) AS total_transactions
    FROM
      `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,UNNEST(hits) AS hit
      ,UNNEST(hit.product) AS product
    WHERE 
      _table_suffix between '0701' and '0731'
      AND totals.transactions >= 1
      AND productRevenue IS NOT NULL
    GROUP BY
      month, fullVisitorId
  )
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;
--q6: Average amount of money spent per session. Only include purchaser data in July 2017
WITH purchaser_sessions AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
    SUM(totals.visits) AS total_visit,
    SUM(product.productRevenue) AS total_revenue
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST(hits) AS hit,
    UNNEST(hit.product) AS product
  WHERE
    _TABLE_SUFFIX BETWEEN '0701' AND '0731'
    AND totals.transactions IS NOT NULL
    AND product.productRevenue IS NOT NULL
  GROUP BY
    date, fullVisitorId
)
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    ((sum(product.productRevenue)/sum(totals.visits))/power(10,6)) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
and totals.transactions>=1
group by month;
--q7: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. 
with buyer_list as(
    SELECT
        distinct fullVisitorId  
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) as product
    WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
    AND totals.transactions>=1
    AND product.productRevenue is not null
)

SELECT
  product.v2ProductName AS other_purchased_products,
  SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) AS hits
, UNNEST(hits.product) as product
JOIN buyer_list using(fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley"
 and product.productRevenue is not null
GROUP BY other_purchased_products
ORDER BY quantity DESC;
--q8: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. 
with
product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null   
  group by 1
)

select
    pv.*,
    num_addtocart,
    num_purchase,
    round(num_addtocart*100/num_product_view,2) as add_to_cart_rate,
    round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;
