-- What are the standard ingredients for each pizza?
WITH toppings_cte AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, ',')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes)

Select pizza_name,string_agg(topping_name,',' order by topping_name)
from toppings_cte t
join pizza_runner.pizza_names pn
on pn.pizza_id = t.pizza_id
join pizza_runner.pizza_toppings pt
on pt.topping_id = t.topping_id
group by 1