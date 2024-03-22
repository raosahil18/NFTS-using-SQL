-- MYSQL WEEK 4 CAPSTONE PROJECT (8 HOURS)

USE cryptopunk;
SELECT * FROM pricedata;

-- 1. How many sales occurred during this time period?
SELECT count(*) AS total_sales FROM pricedata
WHERE event_date >= "2018-01-01"
and
event_date <= "2021-12-31";


-- 2. Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date
SELECT name,eth_price,usd_price,event_date FROM pricedata
ORDER BY usd_price DESC  LIMIT 5;

-- 3.  Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
SELECT cast(event_date as date) as date,
USD_price,
AVG(USD_price) OVER (ORDER BY transaction_hash ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_average
FROM pricedata
ORDER BY transaction_hash;

-- 4.  Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
SELECT name , avg(usd_price) as average_price FROM pricedata
GROUP BY name
ORDER BY name DESC;


-- 5. Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH.
-- Order by the count of transactions in ascending order
SELECT event_date, weekday(event_date) as weekday ,COUNT(token_id) as number_of_sales,AVG(eth_price)
 FROM pricedata
 GROUP BY event_date
 ORDER BY number_of_sales; 
 
 
 -- 6.  Construct a column that describes each sale and is called summary.
SELECT CONCAT(name," was sold for $",round(usd_price,-3)," to ",buyer_address," from ",seller_address," on ",event_date) as summary
FROM pricedata;

-- 7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
CREATE VIEW 1919_purchases AS
SELECT * FROM pricedata
WHERE buyer_address="0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";


-- 8. Create a histogram of ETH price ranges. Round to the nearest hundred value.
SELECT ROUND(eth_price,-2) AS bucket,
 count(*) as count,
 Rpad(' ' ,count(*),'*') as bar
 from pricedata
 group by bucket
 order by bucket;


 -- 9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with a query that has the lowest price
 -- each NFT was bought for and the status column saying “lowest”. The table should have a name column, a price column called price, and a status column.
 -- Order the result set by the name of the NFT, and the status, in ascending order.
 SELECT name,MAX(usd_price) AS price,'highest' AS status
 FROM pricedata
 GROUP BY name
 UNION ALL
 SELECT name,MIN(usd_price) AS price,'lowest' AS status FROM pricedata
 GROUP BY name;


 -- *** 10. What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format.
 SELECT DATE_FORMAT(event_date,'%Y_%m') AS month_year, name AS NFT_name,MAX(usd_price) AS max_price_in_usd
 FROM pricedata GROUP BY DATE_FORMAT(event_date,'%Y_%m'),
 name ORDER BY month_year,max_price_in_usd DESC;

 -- 11. Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
 SELECT MONTH(event_date) as month,ROUND(SUM(eth_price),-2) as Total_volume_of_eth_price,ROUND(SUM(usd_price),-2) as Total_volume_of_usd_price FROM pricedata
 GROUP BY month
 ORDER BY month ASC;


 -- 12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
  SELECT COUNT(*) AS total_transaction_count
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
AND event_date >= "2018-01-01"
AND event_date <= "2021-12-31";


 -- 13. reate an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 --  Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 --  Take the daily average of remaining transactions
 -- a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function.
 -- Save it as a temporary table.
 -- b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and
 -- return a new estimated value which is just the daily average of the filtered data

WITH DailyAverage AS
(SELECT event_date, usd_price,
AVG(usd_price) OVER (PARTITION BY event_date) AS daily_avg_price
FROM pricedata),


FilteredData AS
(SELECT event_date, usd_price, daily_avg_price
FROM DailyAverage
WHERE usd_price >= 0.1 * daily_avg_price)

SELECT event_date,
AVG(usd_price) AS estimated_value
FROM FilteredData
GROUP BY event_date
ORDER BY event_date;

 -- 14. Give a complete list ordered by wallet profitability (whether people have made or lost money)
SELECT
  buyer_address,
  seller_address,
  transaction_hash,
  usd_price,
  eth_price,
  CASE
    WHEN (usd_price - eth_price) > 0 THEN 'Profit'
    ELSE 'Loss'
  END AS profitability,
  (usd_price - eth_price) AS profit_loss
FROM
  (
    SELECT
      buyer_address,
      seller_address,
      transaction_hash,
      usd_price,
      eth_price,
	
      (usd_price - eth_price) AS profit_loss
    FROM
      pricedata
  ) AS t
ORDER BY
  profitability DESC,
  profit_loss DESC;

