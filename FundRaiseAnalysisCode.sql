/* 

Situation At Hand : Help The Business Secure A Funding Round By Telling The Growth Story!
Extract The Data And Tell The Story So We Can Help Advise The C-Suite How They Can Use The Data To Persuade Potential Investors 



Query 1 : 
- Gather Session And Order Volume Trended By Quarter For The Life Of The Business
- Check The Conversion Rate, Revenue Per Order And Revenue Per Session

*/

SELECT
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
    COUNT(DISTINCT ws.website_session_id) AS num_sessions,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id),3) AS cvr_rt,
    ROUND(SUM(price_usd) / COUNT(DISTINCT o.order_id),2) AS rev_per_order,
	ROUND(SUM(price_usd) / COUNT(DISTINCT ws.website_session_id),2) AS rev_per_session
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
-- ordering by year and quarter to ensure it is in chronological order ;

/* 
ANALYSIS OF QUERY 1:
- Ordering by year and quarter to make align with the desired trend pattern
- You can see a clear trend here, record quarters consistently for 3 years. 
- Not only that, during that time the conversion rate from sessions to orders has increased around 2.5x from a low of 3% to 7.8%
from 60 orders to 5420 in 3 years, almost 100x increase 
- Revenue per session has increased from 1.6 to 5.3 (over 200%)
- Revenue per order has increase from 50 to 62, through increasing product variety with huge success 
NOTE : the recent quarter is incomplete, I have decided to leave this out to maintain consistency in the data, alternatively we could have predicted the outcome.

Query 2: 
- Gather Trended Views Of Orders That Came From Gsearch Nonbrand, Bsearch Nonbrand, Brand Search Overall, Organic Search And Direct Type In
  So We Can Assess How The Brand Is Gaining Strength And Traffic Is Coming To Our Website 

*/

SELECT 
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand, 
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END) AS organic_search,
	COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS total_brand_search
-- creating the buckets for each traffic type, to assess and analyse their performance 
FROM 
	website_sessions ws
	LEFT JOIN orders o
		USING(website_session_id)
WHERE 
	ws.created_at <= '2014-12-31'
GROUP BY
	YEAR(ws.created_at),
    QUARTER(ws.created_at)
ORDER BY
	YEAR(ws.created_at),
    QUARTER(ws.created_at)
;

-- using the previous query to translate into what % of the orders are coming from each traffic type

SELECT 
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
    ROUND(COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id),2) AS gsearch_nonbrand_pct,
	ROUND(COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id),2) AS bsearch_nonbrand_pct, 
	ROUND(COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id),2) AS organic_search_pct,
	ROUND(COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id),2) AS direct_type_in_pct,
	ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id),2) AS total_brand_search_pct
-- rounded to 2 decimals for easier readability on the end user 
FROM 
	website_sessions ws
	LEFT JOIN orders o
		USING(website_session_id)
WHERE 
	ws.created_at <= '2014-12-31'
GROUP BY
	YEAR(ws.created_at),
    QUARTER(ws.created_at)
ORDER BY
	YEAR(ws.created_at),
    QUARTER(ws.created_at)
;

/*
ANALYSIS OF QUERY 2:
Direct type in numbers has increase 25 x per quarter over the 3 years, organic search has increased by even more than that
Paid channels are taking up less and less of the share of orders, which has better margain and less dependency on paid traffic, shows brand that our health is getting stronger
and customers are coming through favorable channels such as organic or direct type in 

Query 3 
- Gathering Quarterly Session To Order From Each Gsearch Nonbrand, Bsearch Nonbrand, Brand Search Overall, Organic Search And Direct Type In?

*/

SELECT 
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS q,
-- now creating the formula to calculate what percentage of the orders came from each type of traffic below
	ROUND(COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN o.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign= 'nonbrand' THEN ws.website_session_id ELSE NULL END),3) AS gsearch_nonbrand,
	ROUND(COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END),3) AS bsearch_nonbrand, 
    ROUND(COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN ws.website_session_id ELSE NULL END),3) AS organic_search,
	ROUND(COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN ws.website_session_id ELSE NULL END),3) AS direct_type_in,
	ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END),3) AS total_brand_search
FROM 
	website_sessions ws
	LEFT JOIN orders o
		USING(website_session_id)
-- bringing in website sessions to create the groups of each traffic type, and orders to figure out which resulted in completing orders 
WHERE 
	ws.created_at <= '2014-12-31'
-- limiting the date range to only completed quarters
GROUP BY 1,2 ;

/* 
ANALYSIS OF QUERY 3:
across all of our channels our session to order conversion rate is steadily growing, an indication of our previous analysis and website improvements / purchase pathway optimisations 
a clear indicator of that being in january 2013 improvements of our billing page causuing a considerable uplift of around 2-3% to prior quarters 


Query 4 : 
- Diving Deeper Into Revenue By Products, Let's See What The Monthly Sales Trends Look Like And Potential High Seasons 
*/
SELECT 
	YEAR(oi.created_at) as yr,
    MONTH(oi.created_at) as mo,
    SUM(CASE WHEN oi.product_id = '1' THEN oi.price_usd ELSE NULL END) AS p1_revenue,
    SUM(CASE WHEN oi.product_id = '1' THEN oi.price_usd - cogs_usd ELSE NULL END)  AS p1_margin,
	SUM(CASE WHEN oi.product_id = '2' THEN oi.price_usd ELSE NULL END) AS p2_revenue,
    SUM(CASE WHEN oi.product_id = '2' THEN oi.price_usd - cogs_usd ELSE NULL END) AS p2_margin,
    SUM(CASE WHEN oi.product_id = '3' THEN oi.price_usd ELSE NULL END) AS p3_revenue,
    SUM(CASE WHEN oi.product_id = '3' THEN oi.price_usd - cogs_usd ELSE NULL END) AS p3_margin,
    SUM(CASE WHEN oi.product_id = '4' THEN oi.price_usd ELSE NULL END) AS p4_revenue,
    SUM(CASE WHEN oi.product_id = '4' THEN oi.price_usd - cogs_usd ELSE NULL END)AS p4_margin,
-- using case to determine which values to sum for each product, to then assess revenue and margin for each
    COUNT(oi.order_id) AS total_sales,
    SUM(oi.price_usd) AS revenue,
    SUM(oi.price_usd - cogs_usd) AS margain
-- some additional lines to give a higher level view and context of overall sales (not just product level)
FROM 
    order_items oi
WHERE 
	oi.created_at <= '2015-02-28'
GROUP BY 1,2
;

/*
ANALYSIS OF QUERY 4:
- Every year, from start to finish we see considerable growth of around 200% increase in orders, typically with a large surge around the christmas period and later valentines once the love bear
(product 2) was launched 
- This suggests that we are tapping into the lucrative gifts market
- Overall monthly revenue is up 43x since launch 
NOTE : again capping off at the final month as we don't have a full story of data yet

-- Query 5 : 
- Check How Monthly Sessions On The Products Page Are Growing And What % Are Clicking Through To Another Page
  Look How Those Sessions Are Converting To Orders

*/

CREATE TEMPORARY TABLE click_throughs
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
            AND created_at <= '2015-02-28'
-- limiting to products so that we can find out what pageview id each session was on the products page and then grouped by session also
		GROUP BY
			website_session_id
        ) AS prod_page
LEFT JOIN 
	website_pageviews pvs
		ON pvs.website_session_id = prod_page.website_session_id
        AND pvs.website_pageview_id > prod_page.products_pageview_id
-- left joining to website pageviews again, with a condition that only joins with pageview ids that are after the one displayed for the products page,
-- so we can bring in the session that followed the products page with the MIN function
GROUP BY 
	prod_page.website_session_id;

-- using the temporary table we produced above, to aggregate for our click through and conversion rates
SELECT
	YEAR(prod_created_at) AS yr,
    MONTH(prod_created_at) AS mo,
    COUNT(DISTINCT products_pageview_id) AS product_views,
    COUNT(DISTINCT clicked_through) AS clicked_through,
    ROUND(COUNT(DISTINCT clicked_through) / COUNT(DISTINCT products_pageview_id),3) AS click_through_rt,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT products_pageview_id),3) AS product_to_order_cvr_rate
FROM
	click_throughs ct
LEFT JOIN
	orders o 
		USING(website_session_id)
GROUP BY 
	1,2;

/*
ANALYSIS OF QUERY 5:
- The most notable thing is that our conversion rate to order has doubled from 6-8% to 14%, through our website improvements, and product additions we have been able to 
- translate this into a higher order and click through rate rate 
- bringing in a variety of products, and products at a lower price points are some key highlights, as we've gradually and cleverly 
- introduced said products, the click through and order rate has increased


Query 6 : 
- Look Into How Our Products Are Cross Selling On Each Other And How That Has Impacted Customer Behavior 
*/

-- finding the date of when the final product was introduced
-- so we can have a fair assesment of the cross selling stats

SELECT 
	MIN(created_at) -- it was '2014-12-05'
FROM 
	website_pageviews
WHERE 
	pageview_url = '/the-hudson-river-mini-bear' -- the final product introduced
GROUP BY 
	pageview_url
;

-- moving onto the main query to produce the final cross sell data below

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
ANALYSIS OF QUERY 6:
- Product 1 inspires the most primary orders, potentially due to being a longer lasting staple product with more market awareness
however product 4 seems to cause the most cross sales, likely in being a cheaper product it has higher likelihood of an impulse purchase
through introducing cheaper products we have been able to inspire more sales with our customers, going forward if we wanted to experiment or
push for more cross sells, it seems potential discounts/promos, or further cheaper products could aid this mission, specifically around the cheaper options   

SUMMARY OF ANALYSIS:
Overall our business has seen great growth as the analysis shows, from our diligent work at analysing our website and customer behavior patterns and innovation in bringing in new products
we have shown great entrepreneurial spirit as a business, and our sales trends speak for themselves
*/

