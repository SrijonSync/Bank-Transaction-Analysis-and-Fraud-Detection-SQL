-- create table bank
create table bank (
    customer_id varchar(100),
    customer_name varchar(100),
    gender varchar(10),
    age int,
    state varchar(50),
    city text,
    bank_branch varchar(50),
    account_type varchar(20),
    transaction_id varchar(100),
    transaction_date date,
    transaction_time time,
    transaction_amount decimal(10, 2),
    merchant_id varchar(100),
    transaction_type varchar(20),
    merchant_category varchar(50),
    account_balance decimal(15, 2),
    transaction_device varchar(50),
    transaction_location varchar(100),
    device_type varchar(50),
    is_fraud boolean,
    transaction_currency varchar(10),
    customer_contact varchar(15),
    transaction_description text,
    customer_email varchar(100)
);

-- drop table bank
drop table bank;

-- select all from bank
select * from bank;

-- checking data quality

-- deleting duplicate transactions
select transaction_id,
       count(*)
from bank
group by transaction_id
having count(*) > 1;

-- transactions with 0 or negative amount
select *
from bank
where transaction_amount = 0;

-- account balance vs transaction amount
select account_balance, transaction_amount
from bank
where account_balance < transaction_amount;

-- fraud findings with risk analysis

-- top 10 merchants with fraud transactions
select customer_name,
       state,
       transaction_amount,
       count(*) as fraud
from bank
where is_fraud = true
group by customer_name, state, transaction_amount
order by transaction_amount desc
limit 20;

-- highest fraud rate branches
select bank_branch,
       count(case
                 when is_fraud = true then 1
             end) * 100 / count(*) as fraud_rate
from bank
group by bank_branch
order by fraud_rate desc
limit 20;

-- customer repeated fraudulent transactions
select customer_id,
       count(*) as fraud_count
from bank
where is_fraud = true
group by customer_id
having count(*) > 1;

-- high amount suspicious transaction at midnight
select *
from bank
where transaction_amount > 30000
    and cast(transaction_time as time) between '01:00:00' and '05:00:00'
order by transaction_amount desc
limit 20;

-- top state fraud count
select state,
       count(*) as fraud_state
from bank
where is_fraud = true
group by state
order by fraud_state desc
limit 10;

-- customers' use of device for transactions (potential fraud)
select device_type,
       count(*) as fraud
from bank
where is_fraud = true
group by device_type
order by fraud desc;

-- fraud based on gender and account type
select gender,
       account_type,
       count(*) as fraud
from bank
where is_fraud = true
group by gender, account_type
order by fraud desc;

-- fraud count based on account type
select transaction_type,
       count(*) as fraud
from bank
where is_fraud = true
    and cast(transaction_time as time) between '01:00:00' and '05:00:00'
group by transaction_type
order by fraud desc;

-- customers' segmentation and spending pattern:

-- gender-based transactions total
select gender,
       sum(transaction_amount) as total_spent
from bank
group by gender
order by total_spent desc;

-- top 10 high-spending customers
select customer_id,
       customer_name,
       sum(transaction_amount) as total_spent
from bank
group by customer_id, customer_name
order by total_spent desc
limit 10;

-- most common transaction types among high-spending customers
select transaction_type,
       count(*) as trans_count
from bank
where customer_id in
        (select customer_id
         from bank
         group by customer_id
         order by sum(transaction_amount) desc
         limit 10)
group by transaction_type
order by trans_count desc;

-- state-wise transaction
select state,
       sum(transaction_amount) as total_trans
from bank
group by state
order by total_trans desc;

-- city-wise transaction
select city,
       count(*) as total_trans
from bank
group by city
order by total_trans desc;

-- bank branch performance & operational analysis

-- branches' average transaction
select bank_branch,
       avg(transaction_amount) as avg_total_trans
from bank
group by bank_branch
order by avg_total_trans desc;

-- branches' highest transaction volume
select bank_branch,
       count(*) as trans_count
from bank
group by bank_branch
order by trans_count desc;

-- peak transaction hour
select bank_branch,
       extract(hour from transaction_time) as peak_hour,
       count(*) as transaction_count
from bank
group by bank_branch, extract(hour from transaction_time)
order by transaction_count desc
limit 15;

-- time-based transaction trends

-- daily transaction volume over last month
select transaction_date,
       count(*) as daily_trans
from bank
where transaction_date between '2025-01-01' and '2025-01-31'
group by transaction_date
order by daily_trans asc;

-- popular transaction time
select extract(hour from transaction_time) as peak_hour,
       count(*) trans_count
from bank
group by extract(hour from transaction_time)
order by trans_count desc;

select customer_id,
       transaction_date,
       count(distinct transaction_location) as location_count
from bank
group by customer_id, transaction_date
having count(distinct transaction_location) > 1;

-- transaction time pattern analysis
select extract(hour from transaction_time) as transaction_hour,
       count(*) as transaction_count,
       sum(transaction_amount) as total_amount
from bank
group by extract(hour from transaction_time)
order by transaction_count desc;

-- potential risk transaction based on merchant
select merchant_category,
       count(*) as transaction_count,
       avg(transaction_amount) as avg_trans_value,
       sum(transaction_amount) as total_spending
from bank
group by merchant_category
order by avg_trans_value desc
limit 10;
