/* The problem:
You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in a marketing
campaign where they see call-to-actions for more in-app purchases. Find the number of users that made additional in-app 
purchases due to the success of the marketing campaign. The marketing campaign doesn't start until one day after the
initial in-app purchase so users that only made one or multiple purchases on the first day do not count, nor do we count 
users that over time purchase only the products they purchased on the first day.
Data source : https://1drv.ms/x/s!AgW96PVgg41GiBOa1vXQDdchGWM6?e=5s5Iz1
*/
/*
To be considered in the marketing campaign, user needs to buy a product that isn't  the same product as what was bought
in their first purchase date.
Product needs to be different
Product needs to be purchased on a different day
*/
/* Scenarios to consider

-- 1 Item, 1 date of purchase (not eligible for marketing campaign)
-- multiple products, 1 date of purchase (not eligible for marketing campaign)
-- 1 product, multiple days (not eligible for marketing campain)
--multiple products, multiple days, but same products as the first day of purchase (not eligible for marketing campain)
-- multiple dates, multiple products (should be in marketing campaign)
*/

SELECT COUNT(DISTINCT USER_ID)
FROM marketing_campaign
WHERE user_id IN (
    select user_id
    from marketing_campaign
    GROUP BY user_id
    HAVING COUNT(DISTINCT Product_id) > 1 -- User must purchase multiple diffrent products
        AND COUNT(DISTINCT created_at)>1) --user must purchase on different dates
AND CONCAT((user_id),'_',(product_id)) NOT IN (
    SELECT user_product --identify user's first products purchased
    FROM (
    SELECT *,
    RANK() OVER (PARTITION BY user_id 
                                ORDER BY created_at ) AS rn,
    CONCAT((user_id),'_',(product_id)) AS user_product
    FROM marketing_campaign) x
    WHERE rn = 1)
