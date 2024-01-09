--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends

with cte as (
select sum(cast(amount as bigint))total_spend from credit_card_transcations)

select top 5 city, sum(amount) total_sepnd_city,total_spend,sum(amount)*1.0/ total_spend *100 as '%contribution'
from credit_card_transcations,cte
group by city,total_spend
order by total_sepnd_city desc

--2- write a query to print highest spend month and amount spent in that month for each card type


with cte as (
select card_type, DATEPART(year,transaction_date)yo,datename(month,transaction_date)mo,sum(amount) total_spend
from credit_card_transcations
group by card_type, DATEPART(year,transaction_date),DATEname(month,transaction_date)),
cte1 as (
select * , rank() over(partition by card_type order by total_spend desc) rn from cte)

select * from cte1
where rn=1;


--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)


select * from (
select *, rank() over(partition by card_type order by cum_sum) rnk from (
select *,sum(amount) over(partition by card_type order by transaction_date,transaction_id)cum_sum
from credit_card_transcations)a
where cum_sum>1000000)b
where rnk=1;


--4- write a query to find city which had lowest percentage spend for gold card type
with cte as (
select city, sum(amount) total_sum_card from credit_card_transcations
group by city),
cte1 as (
select city ,card_type , sum(amount) gold_spend
from credit_card_transcations
group by card_type,city
having card_type='gold'
)
select top 1 *,(gold_spend *1.0/total_sum_card)*100 '%spend' 
from cte inner join
cte1 on cte.city=cte1.city
order by '%spend' 

--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)


with cte as (
select city ,exp_type,sum(amount) total_spend
from credit_card_transcations
group by city,exp_type 
--order by total_spend desc
)
select city,
max (case when highest_rn=1 then exp_type end) as highest_expense_type ,
min(case when lowest_rn=1 then exp_type end) as lowest_expense_type
from(
select city,exp_type,total_spend,
rank() over (partition by city order by total_spend desc) highest_rn ,
rank() over (partition by city order by total_spend asc) lowest_rn 
from cte)a
where highest_rn=1 or lowest_rn=1
group by city;


--6- write a query to find percentage contribution of spends by females for each expense type


with cte as (
select exp_type, sum(amount) total_exp from credit_card_transcations
group by exp_type),
cte1 as (
select exp_type, sum(amount) cat_exp_type from credit_card_transcations
where gender ='f'
group by exp_type)

select cte1.exp_type, cat_exp_type*1.0/total_exp *100 as female_expend from cte1 inner join cte on cte.exp_type=cte1.exp_type;

--7- which card and expense type combination saw highest month over month growth in Jan-2014

with cte as (
select card_type,exp_type,datepart(month,transaction_date)mo,DATEPART(year,transaction_date)yo, sum(amount) total_amount
from credit_card_transcations
where DATEPART(year,transaction_date)='2014' and datepart(month,transaction_date)='1' 
group by card_type,exp_type,datepart(month,transaction_date),DATEPART(year,transaction_date)
--order by mo ,yo
),

cte1 as (
select card_type,exp_type,datepart(month,transaction_date)mo,DATEPART(year,transaction_date)yo, sum(amount) total_amount
from credit_card_transcations
where DATEPART(year,transaction_date)='2014' and datepart(month,transaction_date)='1' 
group by card_type,exp_type,datepart(month,transaction_date),DATEPART(year,transaction_date)
--order by mo ,yo
)
select top 1  * from cte inner join cte1 on cte.card_type=cte1.card_type
and cte.exp_type=cte1.exp_type
where cte1.total_amount >cte.total_amount
order by (cte1.total_amount-cte.total_amount) desc ;

------------------------------------------------------------------------------------------------------

with cte as (
select card_type,exp_type,datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt,sum(amount) as total_spend
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date)
)
select  top 1 *, (total_spend-prev_mont_spend) as mom_growth
from (
select *
,lag(total_spend,1) over(partition by card_type,exp_type order by yt,mt) as prev_mont_spend
from cte) A
where prev_mont_spend is not null and yt=2014 and mt=1
order by mom_growth desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 

select * from credit_card_transcations;

select  city, sum(amount)*1.0/count(transaction_date) ratio
--datepart(weekday,transaction_date)
from credit_card_transcations
where datepart(weekday,transaction_date) in(1,7) 
group by city
order by ratio desc


--select  city, sum(amount)*1.0/count(transaction_date) ratio
----DATENAME(weekday,transaction_date)
--from credit_card_transcations
--where datename(weekday,transaction_date) in('saturday','sunday') 
--group by city
--order by ratio desc

--9- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (
select city, count(*) city_wise_transaction,
min(transaction_date) first_trans_date,max(transaction_date) '500th_transaction'
from
credit_card_transcations
group by city
having count(*)>500),

cte1 as (
select *, row_number() over(partition by city order by transaction_date,transaction_id) rnk
from credit_card_transcations)

select top 1 cte.city, datediff(day,first_trans_date,transaction_date) least_day
from cte1 inner join cte on cte1.city=cte.city
where rnk=500 
order by least_day asc 
































