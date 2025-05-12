-- 1. Analiză Customer Lifetime Value (CLV)
--Ce face: Calculează valoarea pe termen lung a fiecărui client, bazându-se pe istoricul lor de cumpărături.
--Metrici cheie:
--order_count: Număr de comenzi per client
--total_spent: Valoare totală cheltuită
--avg_order_value: Valoare medie a comenzii
--freq_months: Frecvența de cumpărare (în luni)
--Identifică clienții cei mai valoroși
CREATE OR REPLACE VIEW OLAP_CUSTOMER_CLV AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    SUM(o.total_amount) / NULLIF(COUNT(o.order_id), 0) AS avg_order_value,
    ROUND(
      MONTHS_BETWEEN(SYSDATE, MIN(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS')))
      / NULLIF(COUNT(o.order_id), 0)
    , 2) AS freq_months
FROM customers_view c
JOIN orders_view o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) >= 1;

SELECT * 
FROM OLAP_CUSTOMER_CLV
ORDER BY total_spent DESC;

-- 2. Analiză performanță produse 
--Ce face: Evaluare completă a produselor
--Metrici cheie:
--total_units: Cantitate vândută
--total_revenue: Venit generat
--avg_rating: Evaluare medie clienți
--feedback_count: Număr de recenzii
--Clasifică produsele după profitabilitate și satisfacție
CREATE OR REPLACE VIEW OLAP_VIEW_PRODUCT_REVENUE AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_units,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(f.rating) AS avg_rating,
    COUNT(f.feedback_id) AS feedback_count,
    MIN(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS')) AS first_order_date,
    MAX(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS')) AS last_order_date
FROM products_view p
LEFT JOIN order_items_view oi ON p.product_id = oi.product_id
LEFT JOIN orders_view o ON oi.order_id = o.order_id
LEFT JOIN view_feedback_mongodb f ON p.product_id = f.product_id
GROUP BY p.product_id, p.product_name, p.category;

SELECT *
FROM OLAP_VIEW_PRODUCT_REVENUE
WHERE first_order_date BETWEEN TO_DATE(:p_start_date, 'YYYY-MM-DD') 
                            AND TO_DATE(:p_end_date, 'YYYY-MM-DD')
ORDER BY total_revenue DESC;

-- 3. Analiză interacțiuni utilizatori
-- Agregare de date privind interacțiunile utilizatorilor,
-- Se grupează evenimentele în funcție de tipul de eveniment (ex.: page_view, add_to_cart, purchase) și pagina vizitată.
-- Metrici cheie:
--   - total_events: numărul total de evenimente pentru fiecare combinație (data, eveniment, pagină).
--   - unique_customers: numărul de clienți unici pentru fiecare combinație.
-- Acest view poate fi utilizat ca bază pentru identificarea etapei de abandon în funnel-ul de conversie,
-- identificând unde clienții opresc interacțiunea înainte de a ajunge la finalizarea unei comenzi.

CREATE OR REPLACE VIEW OLAP_USER_INTERACTION_ANALYTICS AS
SELECT
    TRUNC(interaction_time) AS interaction_date,
    event_type,
    page,
    COUNT(*) AS total_events,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM view_user_interactions_mongodb
GROUP BY TRUNC(interaction_time), event_type, page;

SELECT * FROM OLAP_USER_INTERACTION_ANALYTICS


-- 4. Analiză campanii marketing (cu comparativ)
--Ce face: Măsoară ROI-ul campaniilor

--customers_acquired: Clienți noi atrași
--revenue_per_click: Venit per click
--survey_score: Satisfacție clienți
--Utilizare: Compară eficiența campaniilor

CREATE OR REPLACE VIEW OLAP_VIEW_CAMPAIGN_PERFORMANCE AS
SELECT 
    a.campaign_id,
    a.campaign_name,
    a.start_date,
    a.end_date,
    a.clicks,
    a.impressions,
    a.conversion_rate,
    COUNT(DISTINCT o.customer_id) AS customers_acquired,
    COUNT(DISTINCT o.order_id) AS orders_generated,
    SUM(o.total_amount) AS revenue_generated,
    ROUND(SUM(o.total_amount)/NULLIF(a.clicks,0),2) AS revenue_per_click,
    a.survey_score
FROM analytics a
LEFT JOIN orders_view o 
    ON o.order_date BETWEEN a.start_date AND a.end_date
GROUP BY 
    a.campaign_id, 
    a.campaign_name, 
    a.start_date, 
    a.end_date, 
    a.clicks, 
    a.impressions, 
    a.conversion_rate, 
    a.survey_score;
    
-- campaign_id: C001,C002
SELECT *
FROM OLAP_VIEW_CAMPAIGN_PERFORMANCE
WHERE campaign_id = :campaign_id
ORDER BY start_date DESC;

-- 5. Analiză serii temporale pentru vânzări
-- Ce face: Afișează trenduri vânzări pe perioade
--Opțiuni timeframe:
--Zilnic/Săptămânal/Lunar/Trimestrial/Anual
--Metrici cheie:
--order_count: Comenzi per perioadă
--total_sales: Venit total
--avg_order_value: Valoare medie comandă
--Utilizare: Detectează sezonalități
--(vanzari din urma cu 24 de luni)

CREATE OR REPLACE VIEW OLAP_SALES_TRENDS AS
SELECT 
    TRUNC(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS'), 'DD') AS sales_day,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    SUM(o.total_amount) AS total_sales, -- Total vânzări pe zi
    SUM(oi.quantity) AS total_units,    -- Total produse vândute pe zi
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_order_value
FROM orders_view o
JOIN order_items_view oi ON o.order_id = oi.order_id
WHERE TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS') >= ADD_MONTHS(TRUNC(SYSDATE, 'MONTH'), -48) 
GROUP BY TRUNC(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS'), 'DD');

SELECT *
FROM OLAP_SALES_TRENDS
ORDER BY sales_day DESC;


-- 6. Segmentare comportamentală clienți
-- Ce face: Grupează clienții după valoare, frecvență și recență
-- Metrici: total comenzi, total cheltuit, ultima comandă, ultima interacțiune
-- Util: Segmentare pentru campanii și retenție

CREATE OR REPLACE VIEW OLAP_CUSTOMER_BEHAVIOR_SEGMENTS AS
WITH orders_summary AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        MAX(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS')) AS last_order_date,
        ROUND(SUM(o.total_amount) / NULLIF(COUNT(o.order_id), 0), 2) AS avg_order_value
    FROM orders_view o
    GROUP BY o.customer_id
),
interactions_summary AS (
    SELECT 
        customer_id,
        MAX(interaction_time) AS last_interaction,
        COUNT(*) AS total_events
    FROM view_user_interactions_mongodb
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.total_orders,
    o.total_spent,
    o.avg_order_value,
    o.last_order_date,
    i.last_interaction,
    i.total_events,
    CASE 
        WHEN o.total_orders >= 10 THEN 'High Frequency'
        WHEN o.total_orders BETWEEN 5 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS order_segment,
    CASE 
        WHEN o.total_spent >= 1000 THEN 'High Value'
        WHEN o.total_spent BETWEEN 500 AND 999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM customers_view c
LEFT JOIN orders_summary o ON c.customer_id = o.customer_id
LEFT JOIN interactions_summary i ON c.customer_id = i.customer_id;

 Select * From OLAP_CUSTOMER_BEHAVIOR_SEGMENTS;
 
-- 7. Corelare vânzări vs satisfacție clienți
-- Ce face: Leagă volumul vânzărilor de scorul mediu de feedback
-- Metrici: total vânzări, unități, rating mediu, eficiență per feedback
-- Util: Identificare produse performante sau problematice

CREATE OR REPLACE VIEW OLAP_SALES_AND_FEEDBACK_INSIGHTS AS
WITH sales_data AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS total_units,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products_view p
    JOIN order_items_view oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
feedback_data AS (
    SELECT 
        product_id,
        ROUND(AVG(rating), 2) AS avg_rating,
        COUNT(*) AS feedback_count
    FROM view_feedback_mongodb
    GROUP BY product_id
)
SELECT
    s.product_id,
    s.product_name,
    s.category,
    s.total_units,
    s.total_revenue,
    f.avg_rating,
    f.feedback_count,
    ROUND(s.total_revenue / NULLIF(f.feedback_count, 0), 2) AS revenue_per_feedback,
    ROUND(f.avg_rating * s.total_revenue / NULLIF(s.total_units, 0), 2) AS rating_weighted_score
FROM sales_data s
LEFT JOIN feedback_data f ON s.product_id = f.product_id;

 Select * From OLAP_SALES_AND_FEEDBACK_INSIGHTS;

--8. Clienți inactivi recent
-- Ce face: Detectează clienții care au avut activitate/interacțiuni în trecut, dar care au devenit inactivi
-- Metrici: ultima comandă, ultima interacțiune, zile de inactivitate

CREATE OR REPLACE VIEW OLAP_INACTIVE_CUSTOMERS_INSIGHTS AS
WITH last_orders AS (
    SELECT 
        customer_id,
        MAX(TO_DATE(order_date, 'YYYY-MM-DD"T"HH24:MI:SS')) AS last_order_date
    FROM orders_view
    GROUP BY customer_id
),
last_interactions AS (
    SELECT 
        customer_id,
        MAX(interaction_time) AS last_interaction_date
    FROM view_user_interactions_mongodb
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    lo.last_order_date,
    li.last_interaction_date,
    ROUND(SYSDATE - GREATEST(
        NVL(lo.last_order_date, TO_DATE('1900-01-01', 'YYYY-MM-DD')),
        NVL(li.last_interaction_date, TO_DATE('1900-01-01', 'YYYY-MM-DD'))
    )) AS days_inactive
FROM customers_view c
LEFT JOIN last_orders lo ON c.customer_id = lo.customer_id
LEFT JOIN last_interactions li ON c.customer_id = li.customer_id
WHERE (
    SYSDATE - GREATEST(
        NVL(lo.last_order_date, TO_DATE('1900-01-01', 'YYYY-MM-DD')),
        NVL(li.last_interaction_date, TO_DATE('1900-01-01', 'YYYY-MM-DD'))
    )
) >= 30;

SELECT * FROM OLAP_INACTIVE_CUSTOMERS_INSIGHTS

-- 9. Alertă: produse în declin
-- Ce face: Detectează scăderi bruște de performanță (vânzări sau rating) pe produs
-- Metrici: diferență vânzări, diferență rating (curent vs. luna trecută)

CREATE OR REPLACE VIEW OLAP_PRODUCT_ALERTS_TRENDS AS
WITH sales_by_month AS (
    SELECT
        p.product_id,
        p.product_name,
        TRUNC(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS'), 'MONTH') AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM products_view p
    JOIN order_items_view oi ON p.product_id = oi.product_id
    JOIN orders_view o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, TRUNC(TO_DATE(o.order_date, 'YYYY-MM-DD"T"HH24:MI:SS'), 'MONTH')
),
ratings_by_month AS (
    SELECT
        product_id,
        TRUNC(feedback_time, 'MONTH') AS feedback_month,
        AVG(rating) AS avg_rating
    FROM view_feedback_mongodb
    GROUP BY product_id, TRUNC(feedback_time, 'MONTH')
),
combined_data AS (
    SELECT 
        s1.product_id,
        s1.product_name,
        s1.monthly_revenue AS revenue_current,
        s2.monthly_revenue AS revenue_prev,
        r1.avg_rating AS rating_current,
        r2.avg_rating AS rating_prev
    FROM sales_by_month s1
    LEFT JOIN sales_by_month s2 
        ON s1.product_id = s2.product_id AND s2.sales_month = ADD_MONTHS(s1.sales_month, -1)
    LEFT JOIN ratings_by_month r1 
        ON s1.product_id = r1.product_id AND r1.feedback_month = s1.sales_month
    LEFT JOIN ratings_by_month r2 
        ON s1.product_id = r2.product_id AND r2.feedback_month = ADD_MONTHS(s1.sales_month, -1)
    WHERE s1.sales_month = TRUNC(SYSDATE, 'MONTH')
)
SELECT 
    product_id,
    product_name,
    revenue_prev,
    revenue_current,
    ROUND(NVL(revenue_current, 0) - NVL(revenue_prev, 0), 2) AS revenue_change,
    rating_prev,
    rating_current,
    ROUND(NVL(rating_current, 0) - NVL(rating_prev, 0), 2) AS rating_change,
    CASE 
        WHEN NVL(revenue_current, 0) < NVL(revenue_prev, 0) * 0.7 THEN 'Revenue Drop'
        WHEN NVL(rating_current, 0) < NVL(rating_prev, 0) - 1 THEN ' Rating Fall'
        ELSE 'Stable'
    END AS alert_status
FROM combined_data;

SELECT * FROM OLAP_PRODUCT_ALERTS_TRENDS

