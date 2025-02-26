select * 
from farmers_market.datetime_demo;

#'%Y-%m-%d %H:%M:%S'

#-------Extract Function-------

select min(extract(year from market_start_datetime)) as start_year,
		max(extract(year from market_end_datetime)) as end_year
from farmers_market.datetime_demo;

#-- What if you only want to see the hour at which the market started and ended on each date?

select market_date, min(extract(hour from market_start_datetime)) as start_hour,
		  max(extract(hour from market_end_datetime)) as end_hour
from farmers_market.datetime_demo
group by market_date;


#-------Use of %m %h %s-------
#To extract year and month in 2025-02 format
select date_format(market_date, '%Y-%m')
from farmers_market.datetime_demo;

select date_format(market_date, '%W')
from farmers_market.datetime_demo;

-- %y - 19
-- %Y - 2019
-- %m - 02
-- %M - March
-- %d - 26
-- %D - 26th
-- %w - day of the week in integer
-- %W - Day of the week in Monday - Tuesday format

select month, count(*)
from 
(select market_date,
	  date_format(market_date, '%M') as month
from farmers_market.datetime_demo) tbl
group by month
order by month;

select week, count(*)
from (select market_date,
		date_format(market_date, '%W') as week
from farmers_market.datetime_demo) tbl
group by week;

select market_date,
		extract(year from market_date) as year,
        extract(day from market_date) as day,
        extract(month from market_date) as month,
        extract(quarter from market_date) as quarter,
        extract(day from market_date) as date_week,
        extract(week from market_date) as dayofweek
	   #extract(date from market_start_datetime)
from farmers_market.datetime_demo;


#-------date addition-------
select extract(month from market_start_datetime) as month,
	   extract(month from date_add(market_start_datetime, interval 1 month)) as one_month_added
from farmers_market.datetime_demo;

select market_start_datetime,
	   date_sub(market_start_datetime, interval 60 day) as 60_days_before
from farmers_market.datetime_demo;


select extract(day from market_date) as date, sum(cost_to_customer_per_qty*quantity) as total_sales
from farmers_market.customer_purchases
where market_date between date_sub(current_date(), interval 600000000 day) and current_date()
group by 1;


select date_sub(current_date(), interval 600 day);

select datediff(current_date(), '1990-08-13');

-- from farmers_market.customer_purchases
-- (select max(market_date)
-- from farmers_market.customer_purchases);

#-------difference between first and last purchase-------
 #--But what if we want the difference between the first and last market dates in hours instead of days?
select datediff(max(market_start_datetime), min(market_start_datetime))
from farmers_market.datetime_demo;

select timestampdiff(day, max(market_end_datetime), min(market_start_datetime))
from farmers_market.datetime_demo;

#--we wanted to determine for how long customer has been a customer of the farmer’s market
select customer_id,
	   max(extract(year from market_date)) as max_year,
       min(extract(year from market_date)) as min_year
from farmers_market.customer_purchases
group by 1;

select customer_id,
	datediff(max(market_date), min(market_date))
from farmers_market.customer_purchases
group by 1
order by 2 desc;

#--how long it’s been since the customer last made a purchase
select customer_id,
	datediff(current_date(), max(market_date)) as last_purchase_date
from farmers_market.customer_purchases
group by 1
order by 2;

#-- Find the average days between purchase of two orders for each customers
select customer_id, round(avg(datediff(market_date, lead_date)),2) as avg_diff
from 
(select customer_id, market_date,
		lead(market_date, 1) over(partition by customer_id order by market_date desc) as lead_date
from farmers_market.customer_purchases) tbl
group by 1

#--calculate how many sales occurred within the first 30 minutes after the farmer’s market opened
