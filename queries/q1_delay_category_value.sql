-- ========================================================================================================================================================================================================================
-- q1_delay_category_value
-- Objetivo: consolidar, ao nível de order_id, delta_days, review_score, categoria do produto e valor do pedido para responder à Pergunta 1 - O atraso é simétrico entre categorias e faixas de valor
-- ========================================================================================================================================================================================================================

WITH payment_total AS (
    SELECT
        order_id,
        SUM(payment_value) as order_value
    FROM payments
    GROUP BY order_id
),

item_principal AS (
    SELECT  
        order_id,
        product_id,
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY price DESC
        ) as rn
    FROM items
), 

categoria_pedido AS (
    SELECT 
        ip.order_id,
        COALESCE (c.product_category_name_english, 'unknown') as category_en
    FROM item_principal ip
    LEFT JOIN products p
        on ip.product_id = p.product_id
    LEFT JOIN categorys c 
        on p.product_category_name = c.product_category_name
    WHERE ip.rn = 1 
),

reviews_dedup AS (
    SELECT 
        order_id, 
        review_score,
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY review_creation_date DESC
        ) as rn
    FROM reviews
)

SELECT
    od.order_id,
    od.delta_days,
    r.review_score,
    cp.category_en,
    pt.order_value
FROM orders_delivered od
JOIN reviews_dedup r 
    ON od.order_id = r.order_id
    and r.rn = 1 
JOIN categoria_pedido cp 
    ON od.order_id = cp.order_id
JOIN payment_total pt 
    ON od.order_id = pt.order_id