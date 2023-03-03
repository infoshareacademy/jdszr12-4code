select * from rest r -- główna baza to rest

-- tabela tymczasowa do analizy

drop table rt -- kasowanie tabeli tymczasowej

select 
case when "name"  = '' then null else "name" end as "name",
case when rate  = '' then null when rate = 'NEW' then null when rate = '-' then null else CAST(regexp_replace(rate, '(/5)?$', '') as numeric) end as rate,
votes,
case when "location"  = '' then null else "location" end as "location",
case when rest_type  = '' then null else rest_type end as rest_type,
case when dish_liked  = '' then null else dish_liked end as dish_liked,
case when cuisines  = '' then null else cuisines end as cuisines,
case when "approx_cost(for two people)" = '' then null else replace("approx_cost(for two people)", ',', '')::float end as "approx_cost(for two people)",
"listed_in(type)",
"listed_in(city)" 
into temp rt from (
select distinct on ("name", rate, votes, "location") * from rest r
where 
"location" is not null and 
rate != '' and 
rate != '-' and 
rate != 'NEW' and 
rate != '0' and 
votes != 0 and
"approx_cost(for two people)" != ''
order by "name", rate, votes, "location") as q

-----------------------------------

select * from rt

select count(*)  from rt

-- najwięcej resteuracji

select "name", count(*) from rt
group by 1
order by 2 desc 

-- kategorie restauracji

select "listed_in(type)", count(*) from rt
group by 1
order by 2 desc 

-- liczba retauracji per dzielnica

select "listed_in(city)", count(*) from rt
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
from rt

-- oceny

select 
min(rate),
round(avg(rate),1),
max(rate),
mode() within group (order by rate)
from rt


select 
min(votes),
round(avg(votes)),
max(votes),
mode() within group (order by votes)
from rt

-- koleracje

select corr(rate, "approx_cost(for two people)") from rt

select corr(votes, "approx_cost(for two people)") from rt

select corr(rate, votes) from rt


