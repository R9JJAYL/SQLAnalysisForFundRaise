/* 
SITUATION AT HAND : HELP THE BUSINESS SECURE A FUNDING ROUND BY TELLING THE GROWTH STORY!
EXTRACT THE DATA AND TELL THE STORY SO WE CAN HELP ADVISE THE C-SUITE HOW THEY CAN USE THE DATA


Query 1 : 
- GATHER SESSION AND ORDER VOLUME TRENDED BY QUARTER FOR THE LIFE OF THE BUISNESS
- ALONG WITH CONVERSION RATE, REVENUE PER ORDER AND REVENUE PER SESSION
*/

SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
    COUNT(DISTINCT ws.website_session_id) AS num_sessions,
    COUNT(DISTINCT o.order_id) AS num_orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS cvr_rt,
    SUM(price_usd) / COUNT(DISTINCT o.order_id) AS rev_per_order,
    SUM(price_usd) / COUNT(DISTINCT ws.website_session_id) AS rev_per_session
FROM
    website_sessions ws
-- bringing is website_sessions for access to session level data
    LEFT JOIN orders o
	USING(website_session_id)
-- joining to the orders table so we can create the conversion rates and bring in revenue figures 
WHERE 
	ws.created_at <= '2014-12-31'
GROUP BY 
-- grouping by year and quarter to create the trending analysis possible 
    1,2
ORDER BY 
    1,2	;

/* 
- Ordering by year and quarter to make align with the desired trend pattern
- You can see clear trend here, record quarters consistently for 3 years. 
- Not only that, during that time the conversion rate from sessions to orders has increased around 2.5x from a low of 3% to 7.8%
from 60 orders to 5420 in 3 years, almost 100x increase 
- Revenue per session has increased from 1.6 to 5.3 (over 200%)
- Revenue per order has increase from 50 to 62, through increasing product vareity with huge success 
NOTE : the recent quarter is incomplete, I have decided to leave this out to maintain consistency in the data, alternatively we could have predicted the outcome.

Query 2: GATHER QUARTERLY VIEWS OF ORDERS THAT CAME FROM GSEARCH NONBRAND, BSEARCH NONBRAND, BRAND SEARCH OVERALL, ORGANIC SEARCH AND DIRECT TYPE IN
SO WE CAN ASSESS HOW THE BRAND IS GAINING STRENGTH AND TRAFFIC IS COMING TO OUR WEBSITE 
*/

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand, 
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS total_brand_search,
-- creating the buckets for each traffic type, to assess and analyse their performance 
-- the below could be done as a seperate query for readablity of the query and results, or could be presented side by side, whichever is preferred by end user
-- using the previous buckets to understand what % of the orders are coming from each traffic type
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS gsearch_nonbrand_pct,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS bsearch_nonbrand_pct, 
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS organic_search_pct,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS direct_type_in_pct,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS total_brand_search_pct
FROM 
    website_sessions ws
    LEFT JOIN orders o
  	USING(website_session_id)
GROUP BY
    YEAR(ws.created_at),
    QUARTER(ws.created_at)
;

/*
Direct type in numbers has increase 25 x per quarter over the 3 years, organic search has increased by even more than that
Paid channels are taking up less and less of the share of orders, which has better margain and less dependency on paid traffic, shows brand that our health is getting stronger
and customers are coming through favourable channels such as organic or direct type in 

Query 3 : GATHERING QUARTERLY SESSION TO ORDER FROM EACH GSEARCH NONBRAND, BSEARCH NONBRAND, BRAND SEARCH OVERALL, ORGANIC SEARCH AND DIRECT TYPE IN?
*/

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
-- now creating the formula to calulate what percentage of the orders came from each type of traffic below
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand, 
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN ws.website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN ws.website_session_id ELSE NULL END)AS direct_type_in,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS total_brand_search
FROM 
    website_sessions ws
	LEFT JOIN orders o
		USING(website_session_id)
-- bringing in website sessions to create the groups of each traffic type, and orders to figure out which resulted in completing orders 
WHERE 
    ws.created_at <= '2014-12-31'
-- limiting the date range to only complete time frames 
GROUP BY 
    1,2 ;

/* 
across all of our channels our session to order conversion rate is steadily growing, an indication of our previous analysis and website improvements / purchase pathway optimisations 
a clear indicator of that being in january 2013 improvements of our billing page casuing a considerable uplift of around 2-3% to prior quarters 


Query 4 : 
DIVING DEEPER INTO REVENUE BY PRODUCTS, LET'S SEE WHAT THE MONTHLY SALES TRENDS LOOK LIKE AND POTENTIAL HIGH SEASONS 
*/
SELECT 
    YEAR(oi.created_at) as yr,
    MONTH(oi.created_at) as mo,
    SUM(CASE WHEN oi.product_id = '1' THEN oi.price_usd ELSE NULL END) AS p1_revenue,
    SUM(CASE WHEN oi.product_id = '1' THEN oi.price_usd - cogs_usd ELSE NULL END)  AS p1_margain,
    SUM(CASE WHEN oi.product_id = '2' THEN oi.price_usd ELSE NULL END) AS p2_revenue,
    SUM(CASE WHEN oi.product_id = '2' THEN oi.price_usd - cogs_usd ELSE NULL END) AS p2_margain,
    SUM(CASE WHEN oi.product_id = '3' THEN oi.price_usd ELSE NULL END) AS p3_revenue,
    SUM(CASE WHEN oi.product_id = '3' THEN oi.price_usd - cogs_usd ELSE NULL END) AS p3_margain,
    SUM(CASE WHEN oi.product_id = '4' THEN oi.price_usd ELSE NULL END) AS p4_revenue,
    SUM(CASE WHEN oi.product_id = '4' THEN oi.price_usd - cogs_usd ELSE NULL END)AS p4_margain,
-- using case to determine which values to sum for each product, to then assess revenue and margain for each
    COUNT(oi.order_id) AS total_sales,
    SUM(oi.price_usd) AS revenue,
    SUM(oi.price_usd - cogs_usd) AS margain
-- some additional lines to give a higher level view and context of overall sales (not just product level)
FROM 
    order_items oi
WHERE 
    oi.created_at <= '2015-02-28'
GROUP BY 
    1,2
;

/*
- Every year, from start to finsh we see considerable growth of around 200% increase in orders, typically with a large surge around the christmas period and later valentines once the love bear
(product 2) was launched 
- This suggests that we are tapping into the lucrative gifts market
- Overall monthly revenue is up 43x since launch 
NOTE : again capping off at the final month as we don't have a full story of data yet

-- Query 5 : 
- CHECK HOW MONTHLY SESSIONS TO THE PRODUCTS PAGE ARE GROWING AND WHAT % ARE CLICKING THROUGH TO ANOTHER PAGE
- COMBINE THAT WITH A LOOK OF HOW THEY ARE CONVERTING TO ORDERS
- PULL MONTHLY SESSIONS TO THE /PRODUCTS PAGE, SHOW THE % OF THOSE SESSIONS CLICKING THROUGH TO ANOTHER PAGE AND HOW IT'S CHANGED OVER TIME
- ALONG WITH A VIEW OF HOW CONVERSION FROM /PRODUCTS TO PLACING AN ORDER HAS CHANGED OVER TIME 
*/

CREATE TEMPORARY TABLE click_through
-- creating a temporary table to flag those website sessions that clicked through to the next page
SELECT 
    prod_page.website_session_id,
    products_pageview_id,
    prod_created_at,
    MIN(pvs.website_pageview_id) AS clicked_through,
    MIN(pvs.created_at) AS click_through_created_at
FROM
	(
-- first of all creating a subquery in order to select the MIN page_id that is on the product page
-- then we can see if any subsequent pages were clicked in the main query
		SELECT 
		    website_session_id,
 	            MIN(website_pageview_id) AS products_pageview_id,
                    MIN(created_at) AS prod_created_at
		FROM 
		    website_pageviews 
		WHERE 
		    pageview_url = '/products'
-- limiting to products so that we can find out what pageview id each session was on the products page and then grouped by session also
		GROUP BY
		    website_session_id
        ) AS prod_page
LEFT JOIN 
    website_pageviews pvs
    ON pvs.website_session_id = prod_page.website_session_id
    AND pvs.website_pageview_id > prod_page.products_pageview_id
-- left joining to website pageviews again with a condition that only joins with pageview ids that are after the one displayed for the products page,
-- so we can bring in the session that followed the products page with the MIN function
GROUP BY 
    prod_page.website_session_id;

-- using the temporary table we produced above, to aggregate for our click through and conversion rates
SELECT
    YEAR(prod_created_at) AS yr,
    MONTH(prod_created_at) AS mo,
    COUNT(DISTINCT products_pageview_id) AS product_views,
    COUNT(DISTINCT clicked_through) AS clicked_through,
    COUNT(DISTINCT clicked_through) / COUNT(DISTINCT products_pageview_id) AS pct_clicked,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT products_pageview_id) AS product_to_order_cvr_rate
FROM
    click_through ct
	LEFT JOIN
	orders o 
	USING(website_session_id)
GROUP BY 
	1,2;

/*
- The most notable thing is that our conversion rate to order has doubled from 6-8% to 14%, through our website improvements, and product additions we have been able to 
- translate this into a higher order and click through rate rate 
- bringing in a variety of products, and products at a lower price points are some key highlights, as we've gradually and cleverly 
- introduced said products, the click through and order rate has increased


Query 7 : 
LOOK INTO HOW OUR PROUDCTS ARE CROSS SELLING ON EACH OTHER AND HOW THAT HAS IMPACTED CUSTOMER BEHAVIOR 
*/

-- finding the date of when the final product was introduced
-- so we can have a fair assesment of the cross selling

SELECT 
    MIN(created_at) -- it was '2014-12-05'
FROM 
    website_pageviews
WHERE 
    pageview_url = '/the-hudson-river-mini-bear'

GROUP BY 
    pageview_url
;

-- main query for cross sell data below

SELECT 
   primary_item,
-- using aggregations from the subqueried data, to give us an overview of the cross selling patterns and behaviors of each product
   COUNT(DISTINCT order_id) AS primary_orders,
   COUNT(CASE WHEN not_primary_1 = 1 THEN 1 ELSE NULL END) AS p1_x_sell,
   ROUND(COUNT(CASE WHEN not_primary_1 = 1 THEN 1 ELSE NULL END) 
	/ COUNT(DISTINCT order_id),2) AS p1_x_sell_rt,
   COUNT(CASE WHEN not_primary_2 = 1 THEN 1 ELSE NULL END) AS p2_x_sell,
   ROUND(COUNT(CASE WHEN not_primary_2 = 1 THEN 1 ELSE NULL END) 
	/ COUNT(DISTINCT order_id),2) AS p2_x_sell_rt,
   COUNT(CASE WHEN not_primary_3 = 1 THEN 1 ELSE NULL END) AS p3_x_sell,
   ROUND(COUNT(CASE WHEN not_primary_3 = 1 THEN 1 ELSE NULL END) 
	/ COUNT(DISTINCT order_id),2) AS p3_x_sell_rt,
   COUNT(CASE WHEN not_primary_4 = 1 THEN 1 ELSE NULL END) AS p4_x_sell,
   ROUND(COUNT(CASE WHEN not_primary_4 = 1 THEN 1 ELSE NULL END) 
	/ COUNT(DISTINCT order_id),2) AS p4_x_sell_rt
FROM 
	(
-- creating a query so it's possible to aggregate the cross sell rate using 1s & 0s as flags to decide if the product is the primary purchase or a cross sell
	SELECT 
	   order_id,
	   SUM(CASE WHEN is_primary_item = 1 AND product_id = 1 THEN 1 ELSE 0 END) AS primary_1,
	   SUM(CASE WHEN is_primary_item = 1 AND product_id = 2 THEN 1 ELSE 0 END) AS primary_2,
	   SUM(CASE WHEN is_primary_item = 1 AND product_id = 3 THEN 1 ELSE 0 END) AS primary_3,
	   SUM(CASE WHEN is_primary_item = 1 AND product_id = 4 THEN 1 ELSE 0 END) AS primary_4,
	   SUM(CASE WHEN is_primary_item = 0 AND product_id = 1 THEN 1 ELSE 0 END) AS not_primary_1,
	   SUM(CASE WHEN is_primary_item = 0 AND product_id = 2 THEN 1 ELSE 0 END) AS not_primary_2,
	   SUM(CASE WHEN is_primary_item = 0 AND product_id = 3 THEN 1 ELSE 0 END) AS not_primary_3,
	   SUM(CASE WHEN is_primary_item = 0 AND product_id = 4 THEN 1 ELSE 0 END) AS not_primary_4,
           SUM(CASE WHEN is_primary_item = 1 THEN product_id ELSE 0 END) AS primary_item
	FROM
	   order_items oi
	WHERE 
	   created_at > '2014-12-05'
	-- using this timeframe so all products have been selling for the same time period 
	GROUP BY 
	   order_id ) AS flags
GROUP BY 
    primary_item
ORDER BY  
    primary_item
;

/*
- Product 1 inspires the most primary orders, potentially due to being a longer lasting staple product with more market awareness
however product 4 seems to cause the most cross sales, likely in being a cheaper product it has higher likelihood of an impulse purchase
through introducing cheaper products we have been able to inspire more sales with out customers 

Overall our business has seen great growth as the analysis shows, from our dillgent work at analysing our website and customer behaviour patterns and innovation in bringing in new products
we have shown great entrepreneurial spirit as a business, and our sales trends speak for themselves
*/

