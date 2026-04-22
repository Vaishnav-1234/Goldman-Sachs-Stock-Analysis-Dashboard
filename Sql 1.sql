Select * from goldmansach;

--Daily Return (Adjusted Close)

Select 
trade_date,adj_close_price,
(adj_close_price/lag(adj_close_price) over (order by trade_date))-1
as daily_return 
from goldmansach;

--DISTRIBUTION OF RETURNS (RISK PROFILE)
select
avg(daily_return) as avg_return,
stddev(daily_return) as volatility,
min(daily_return) as worst_day,
max(daily_return) as best_day
from(
	Select 
(adj_close_price/lag(adj_close_price) over (order by trade_date))-1
as daily_return 
from goldmansach
	)t
where daily_return is not null;

--CUMULATIVE RETURN (WEALTH GROWTH)
SELECT
    trade_date,
    EXP(
        SUM(LN(1 + daily_return))
        OVER (ORDER BY trade_date)
    ) - 1 AS cumulative_return
FROM (
    SELECT
        trade_date,
        (adj_close_price / LAG(adj_close_price) OVER (ORDER BY trade_date)) - 1
            AS daily_return
    FROM goldmansach
) t
WHERE daily_return IS NOT NULL;

--Annualized Volatility
SELECT
    STDDEV(daily_return) * SQRT(252) AS annual_volatility
FROM (
    SELECT
        (adj_close_price / LAG(adj_close_price) OVER (ORDER BY trade_date)) - 1
            AS daily_return
    FROM goldmansach
) t
WHERE daily_return IS NOT NULL;

--MAX DRAWDOWN (MOST CRITICAL RISK METRIC)

SELECT
    MIN((adj_close_price - peak_price) / peak_price) AS max_drawdown
FROM (
    SELECT
        trade_date,
        adj_close_price,
        MAX(adj_close_price) OVER (ORDER BY trade_date) AS peak_price 
    FROM goldmansach
) t;

--INTRADAY RISK (HIGH–LOW RANGE)

SELECT
    trade_date,
    (high_price - low_price) / low_price AS intraday_range_pct
FROM goldmansach;

-- MONTHLY PERFORMANCE (MANAGEMENT VIEW)

SELECT
    DATE_TRUNC('month', trade_date) AS month,
    (MAX(adj_close_price) / MIN(adj_close_price)) - 1 AS monthly_return
FROM goldmansach
GROUP BY 1
ORDER BY 1;

--YEARLY PERFORMANCE (LONG-TERM VIEW)

SELECT
    EXTRACT(YEAR FROM trade_date) AS year,
    (MAX(adj_close_price) / MIN(adj_close_price)) - 1 AS yearly_return
FROM goldmansach
GROUP BY 1
ORDER BY 1;

--Volume Spike Detection

SELECT
    trade_date,
    volume,
    CASE
        WHEN volume > AVG(volume) OVER () * 1.5
        THEN 'SPIKE'
        ELSE 'NORMAL'
    END AS volume_signal
FROM goldmansach;



