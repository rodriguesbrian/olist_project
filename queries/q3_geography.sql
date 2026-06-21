-- =====================================================================================================================================================================================================================
-- q3_geography.sql
-- Objetivo: analisar o atraso por estado do cliente, separando problema logístico real (tempo de entrega) de problema de gestão de expectativa (prazo estimado).
-- Pergunta 3: geografia como factor estrutural 
-- Pergunta 4 (vendedor como variável oculta), através da exposição de seller_id e seller_state ao nível do pedido.
-- =====================================================================================================================================================================================================================

WITH delivery_time AS (
    -- CTE 1: decompõe delta_days nos seus dois componentes temporais,
    -- ambos medidos a partir da data de compra, para permitir separar
    -- "demora real a entregar" de "prazo prometido ao cliente"
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
    -- CTE 2: garante exactamente um vendedor por pedido
    -- (um pedido pode ter múltiplos itens do mesmo ou de vendedores
    -- diferentes; aqui fixamos um critério determinístico de seleção
    -- para não duplicar linhas no resultado final)
    SELECT DISTINCT
        order_id,
        seller_id
    FROM items
    -- mantém apenas a primeira linha por order_id, segundo a ordenação
    -- definida — evita que pedidos multi-vendedor gerem múltiplas linhas
    QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) = 1
)

-- consolidação final: junta tempo de entrega/estimativa, estado do
-- cliente (destino) e vendedor + estado do vendedor (origem),
-- ao nível de um registo por pedido
SELECT
    dt.order_id,
    dt.delta_days,
    dt.actual_delivery_days,
    dt.estimated_delivery_days,
    c.customer_state,
    so.seller_id,
    s.seller_state
FROM delivery_time dt
-- liga ao estado do cliente (destino da entrega)
JOIN customers c
    ON dt.customer_id = c.customer_id
-- liga ao vendedor já deduplicado por pedido
JOIN seller_per_order so
    ON dt.order_id = so.order_id
-- liga ao estado do vendedor (origem do envio)
JOIN sellers s
    ON so.seller_id = s.seller_id