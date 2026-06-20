-- =====================================================================================================================================================================================================================
-- q3_geography.sql
-- Objetivo: analisar o atraso por estado do cliente, -- separando problema logístico real (tempo de entrega) -- de problema de gestão de expectativa (prazo estimado) -- Pergunta 3: geografia como factor estrutural
-- =====================================================================================================================================================================================================================

WITH delivery_time AS (
    SELECT
        order_id,
        customer_id,
        delta_days,
        -- tempo real de entrega em dias (compra → entrega)
        DATEDIFF('day', order_purchase_timestamp, order_delivered_customer_date) 
            AS actual_delivery_days,
        -- prazo estimado em dias (compra → estimado)
        DATEDIFF('day', order_purchase_timestamp, order_estimated_delivery_date)
            AS estimated_delivery_days
    FROM orders_delivered
),

seller_per_order AS (
    SELECT DISTINCT
        order_id,
        seller_id
    FROM items
    QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) = 1
)

SELECT
    dt.order_id,
    dt.delta_days,
    dt.actual_delivery_days,
    dt.estimated_delivery_days,
    c.customer_state,
    s.seller_state
FROM delivery_time dt
JOIN customers c
    ON dt.customer_id = c.customer_id
JOIN seller_per_order so
    ON dt.order_id = so.order_id
JOIN sellers s
    ON so.seller_id = s.seller_id   