select * from restaurant r 

select count(*) from restaurant r 

-- Czyszczenie danych, utworzenie nowej tabeli

create table ban as(
select
url,
case when "name" = '' then null else "name" end as "name",
address,
case when rate = '' then null when rate = 'NEW' then null when rate = '-' then null else CAST(regexp_replace(rate, '(/5)?$', '') as numeric) end as rate,
votes,
online_order,
book_table,
phone,
case when "location" = '' then null else "location" end as "location",
case when rest_type = '' then null else rest_type end as rest_type,
case when dish_liked = '' then null else dish_liked end as dish_liked,
case when cuisines = '' then null else cuisines end as cuisines,
case when "approx_cost(for two people)" = '' then null else replace("approx_cost(for two people)", ',', '')::float end as "approx_cost(for two people)",
menu_item,
"listed_in(type)",
"listed_in(city)"
from (
select distinct on ("name", address) * from restaurant r 
where
"location" is not null and
rate != '' and
rate != '-' and
rate != 'NEW' and
rate != '0' and
votes != 0 and
"approx_cost(for two people)" != ''
order by "name", address, votes DESC) as q)

select * from ban

select count(*) from ban

-- najwięcej resteuracji

select "name", count(*) from ban
group by 1
order by 2 desc

select count(*) from
(select "name", count(*) from ban
group by 1
order by 2 desc) as q

-- kategorie restauracji

select "listed_in(type)", count(*) from ban
group by 1
order by 2 desc 

-- liczba retauracji per dzielnica

select "listed_in(city)", count(*) from ban
group by 1 
order by 2 desc 

-- koszty

select
min("approx_cost(for two people)"),
max("approx_cost(for two people)"),
mode() within group (order by "approx_cost(for two people)") as mode,
percentile_cont(0.25) within group (order by "approx_cost(for two people)"),
percentile_cont(0.50) within group (order by "approx_cost(for two people)"),
percentile_cont(0.75) within group (order by "approx_cost(for two people)"),
round(avg("approx_cost(for two people)") - stddev("approx_cost(for two people)")) as avg_minus_std,
round(avg("approx_cost(for two people)")) as avg,
round(avg("approx_cost(for two people)") + stddev("approx_cost(for two people)")) as avg_plus_std,
round(stddev("approx_cost(for two people)")) as stddev
from ban

-- oceny

select
min(rate),
max(rate),
mode() within group (order by rate) as mode,
percentile_cont(0.25) within group (order by rate),
percentile_cont(0.50) within group (order by rate),
percentile_cont(0.75) within group (order by rate),
round(avg(rate) - stddev(rate),1) as avg_minus_std,
round(avg(rate),1) as avg,
round(avg(rate) + stddev(rate),1) as avg_plus_std,
round(stddev(rate),1) as stddev
from ban

select
min(votes),
max(votes),
mode() within group (order by votes) as mode,
percentile_cont(0.25) within group (order by votes),
percentile_cont(0.50) within group (order by votes),
percentile_cont(0.75) within group (order by votes),
round(avg(votes) - stddev(votes)) as avg_minus_std,
round(avg(votes)) as avg,
round(avg(votes) + stddev(votes)) as avg_plus_std,
round(stddev(votes)) as stddev
from ban

-- koleracje

select corr(rate, "approx_cost(for two people)") from ban

select corr(votes, "approx_cost(for two people)") from ban

select corr(rate, votes) from ban

-- podział na kuchnie

select trim(regexp_split_to_table(b.cuisines, E',')) AS split_cuisines, count(*) 
from ban b
group by 1
order by 2 desc

-- najwyżej oceniane z uwzględnieniem popularności

select trim(regexp_split_to_table(b.cuisines, E',')) AS split_cuisines, 
round(avg(rate),1) as avg_rate,
round(avg(votes)) as avg_votes,
count(*) 
from ban b
group by 1
order by 2 desc

-- znalezienie "smacznych" i zweryfikowanych, ocena >= 4,5, oceny >= 1000

select * from ban b 
where rate >= 4.5
and votes >= 1000

-- znalezienie "smacznych i tanich", ocena >= 4,5, cena pomiędzy 410 - 820

select * from ban b 
where rate >= 4.5
and "approx_cost(for two people)" between 410 and 820

-- znalezienie "smacznych i tanich", ocena >= 4,5, cena pomiędzy 410 - 820; zweryfikowane -liczba głosów  >= 1000

select * from ban b 
where rate >= 4.5
and votes >= 1000
and "approx_cost(for two people)" between 410 and 820


