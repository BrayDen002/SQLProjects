SELECT * FROM mcdonald_nutrition_facts.mcd_menu;

# Query for organizing all breakfast items that contain egg and ordering them by their daily cholesterol percent levels that are over 50.
SELECT category, item, daily_cholesterol 
FROM mcd_menu 
WHERE category = "breakfast" AND item LIKE "%egg%" 
AND daily_cholesterol > 50 ORDER BY daily_cholesterol ASC;

# Query for which item on the menu has the Highest amount of calories for each category.
SELECT * FROM (
    SELECT category, 
           item,
           calories, 
           # This is where we find the highest Calorie item for each category by ordering by DESC, if ASC then it would find the lowest calorie item.
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY calories DESC) AS calorie_rank 
    FROM mcd_menu) AS ranks
WHERE calorie_rank = 1;