

select * from [dbo].[driver]
select * from [dbo].[driver_order]
select * from [dbo].[ingredients]
select * from [dbo].[rolls]
select * from [dbo].[rolls_recipes]
select * from [dbo].[customer_orders]

--for unique customer orders
select count(distinct customer_id) from customer_orders

--succesful order delivered by each driver
select driver_id,count(distinct order_id)from driver_order where cancellation not in ('cancellation','customer cancellation')group by driver_id

--each type of roll delivered
select roll_id,count(roll_id)from customer_orders where order_id in(select order_id from(select *,case when cancellation in ('cancellation','customer cancellation')then 'c'else 'nc' end as order_cancel_details from driver_order)a 
where order_cancel_details ='nc')group by roll_id

--veg and nonveg roll ordered by each customer
select a.*,b.roll_name from(select customer_id,roll_id,count(roll_id)cnt from customer_orders
group by customer_id,roll_id)a inner join rolls b on a.roll_id=b.roll_id 

--maximum rolls delivered in a single order
select *,rank()over(order by cnt desc)rnk from (select order_id,count(roll_id)cnt from(select * from customer_orders where order_id in
(select order_id from (select *,case when cancellation in ('cancellation','customer cancellation')then 'c'else 'nc' end as order_cancel_details from driver_order)a 
where order_cancel_details ='nc'))b group by order_id)c

--for each customer,how many delivered rolls had atleast 1 changes and how many had no changes?
with temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)as  (select order_id,customer_id,roll_id,case when 
not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included=' ' or extra_items_included='NaN' or extra_items_included='NULL'
then '0' else extra_items_included end as new_extra_items_included,order_date from customer_orders)

,temp_driver_order(order_id,driver_id,pickup_time,distance,duration,new_cancellation)as (select order_id,driver_id,pickup_time,distance,duration,
 case when cancellation in ('cancellation','customer cancellation')then 0 else 1 end as new_cancellation from driver_order)

 select customer_id,chg_no_chg,count(order_id)at_least_1_change from
 (
 select *,case when not_include_items='0' and extra_items_included='0' then 'no change' else 'change' end as chg_no_chg from temp_customer_orders where order_id in
 (select order_id from temp_driver_order where new_cancellation !=0))a group by customer_id,chg_no_chg;

 --how many rolls were delivered that had both exclusions and extras
 with temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)as  (select order_id,customer_id,roll_id,case when 
not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included=' ' or extra_items_included='NaN' or extra_items_included='NULL'
then '0' else extra_items_included end as new_extra_items_included,order_date from customer_orders)

,temp_driver_order(order_id,driver_id,pickup_time,distance,duration,new_cancellation)as (select order_id,driver_id,pickup_time,distance,duration,
 case when cancellation in ('cancellation','customer cancellation')then 0 else 1 end as new_cancellation from driver_order)

 
 select chg_no_chg,count(chg_no_chg)from
 (select *,case when not_include_items!='0' and extra_items_included!='0' then 'both inc exc' else 'either 1 inc or exc' end as chg_no_chg from temp_customer_orders where order_id in
 (select order_id from temp_driver_order where new_cancellation !=0))a group by chg_no_chg 

 --total rolls ordered for each hour of the day
 select hours_bucket,count(hours_bucket)occurance from
 (select *,concat(cast(datepart(hour,order_date)as varchar),'-',cast(datepart(hour,order_date)+1 as varchar))hours_bucket  from customer_orders)a
 group by hours_bucket




