-- ========================================================================================================================================================================================================================
-- q1_delay_category_value.sql
-- Objetivo: consolidar, ao nível de order_id, delta_days, review_score, -- categoria do produto e valor do pedido, para responder à Pergunta 1 -- — o atraso é simétrico entre categorias e faixas de valor do pedido?
-- ========================================================================================================================================================================================================================

WITH payment_total AS (
    -- CTE 1: soma o valor pago por pedido
    -- (order_payments pode ter múltiplas linhas por order_id quando
    -- o pagamento é feito em várias parcelas ou métodos diferentes —
    -- por isso é necessário agregar antes de juntar a orders_delivered)
    SELECT
        order_id,
        SUM(payment_value) as order_value
    FROM payments
    GROUP BY order_id
),

item_principal AS (
    -- CTE 2: identifica o item de maior valor (price) em cada pedido
    -- (critério de desempate para pedidos com múltiplos itens de
    -- categorias diferentes — ver verificação feita em pandas:
    -- 96.550 pedidos com 1 categoria, 727 com 2-3 categorias)
    SELECT
        order_id,
        product_id,
        -- ordena os itens do pedido por preço decrescente;
        -- rn = 1 identifica o item de maior valor
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY price DESC
        ) as rn
    FROM items
),

categoria_pedido AS (
    -- CTE 3: obtém a categoria (em inglês) do item principal de cada
    -- pedido, tratando categorias nulas em products (610 produtos)
    -- como 'unknown' em vez de excluir o pedido da base
    SELECT
        ip.order_id,
        -- COALESCE garante que pedidos sem categoria identificada
        -- (product_category_name nulo em products) não geram nulos
        -- no resultado final, ficando rotulados como 'unknown'
        COALESCE (c.product_category_name_english, 'unknown') as category_en
    FROM item_principal ip
    -- LEFT JOIN preserva o pedido mesmo que o produto não tenha
    -- categoria associada em products
    LEFT JOIN products p
        on ip.product_id = p.product_id
    LEFT JOIN categorys c
        on p.product_category_name = c.product_category_name
    -- filtra apenas o item de maior valor por pedido (rn = 1),
    -- definido no CTE anterior
    WHERE ip.rn = 1
),

reviews_dedup AS (
    -- CTE 4: mantém apenas a review mais recente por pedido
    -- (551 pedidos tinham mais de uma review registada — sem este
    -- tratamento, o JOIN final duplicaria essas linhas)
    SELECT
        order_id,
        review_score,
        -- ordena as reviews do pedido pela mais recente primeiro;
        -- rn = 1 identifica a review a manter
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY review_creation_date DESC
        ) as rn
    FROM reviews
)

-- consolidação final: junta delta_days (orders_delivered), nota do
-- cliente (reviews_dedup), categoria do produto (categoria_pedido)
-- e valor total pago (payment_total), ao nível de um registo por pedido
SELECT
    od.order_id,
    od.delta_days,
    r.review_score,
    cp.category_en,
    pt.order_value
FROM orders_delivered od
-- liga à review mais recente do pedido (exclui pedidos sem review —
-- 646 pedidos, perda esperada e documentada no notebook)
JOIN reviews_dedup r
    ON od.order_id = r.order_id
    and r.rn = 1
-- liga à categoria do item principal do pedido
JOIN categoria_pedido cp
    ON od.order_id = cp.order_id
-- liga ao valor total pago (exclui 1 pedido sem payment registado)
JOIN payment_total pt
    ON od.order_id = pt.order_id