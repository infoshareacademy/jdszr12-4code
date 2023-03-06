
--smacznie i tanio
--założenia: koszt posiłku między 5-10$ (410-820); rate >4; ilość głosów >1000
select name,address, rate::numeric,"approx_cost(for two people)"   from bangalore  
where "approx_cost(for two people)" between 410 and 820
and 
rate > 4
and votes > 1000