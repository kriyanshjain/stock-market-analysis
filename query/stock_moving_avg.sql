# 7 - DAY Moving Avg
CREATE VIEW moving_averages_7day AS
SELECT 
    ticker,
    date,
    close_price,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS ma_7day
FROM stock_prices
ORDER BY ticker, date;

#21 - DAY Moving Avg
CREATE VIEW moving_averages_21day AS
SELECT 
    ticker,
    date,
    close_price,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
    ), 2) AS ma_21day
FROM stock_prices
ORDER BY ticker, date;

#50 - DAY Moving Avg
CREATE VIEW moving_averages_50day AS
SELECT 
    ticker,
    date,
    close_price,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ), 2) AS ma_50day
FROM stock_prices
ORDER BY ticker, date;

CREATE VIEW all_moving_averages AS
SELECT 
    ticker,
    date,
    close_price,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS ma_7day,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
    ), 2) AS ma_21day,
    ROUND(AVG(close_price) OVER (
        PARTITION BY ticker 
        ORDER BY date 
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ), 2) AS ma_50day
FROM stock_prices
ORDER BY ticker, date;

# 20 - DAY Rolling
CREATE VIEW volatility_analysis AS
SELECT 
    dr.ticker,
    dr.date,
    ROUND(
        STDDEV(dr.daily_return_pct) OVER (
            PARTITION BY dr.ticker 
            ORDER BY dr.date 
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ), 
        4
    ) AS volatility_20day
FROM daily_returns dr
WHERE dr.daily_return_pct IS NOT NULL
ORDER BY dr.ticker, dr.date;

CREATE VIEW performance_metrics AS
WITH price_boundaries AS (
    SELECT 
        ticker,
        FIRST_VALUE(close_price) OVER (PARTITION BY ticker ORDER BY date) AS first_price,
        FIRST_VALUE(close_price) OVER (PARTITION BY ticker ORDER BY date DESC) AS last_price,
        MIN(close_price) OVER (PARTITION BY ticker) AS min_price,
        MAX(close_price) OVER (PARTITION BY ticker) AS max_price
    FROM stock_prices
)
SELECT DISTINCT
    ticker,
    ROUND(first_price, 2) AS starting_price,
    ROUND(last_price, 2) AS ending_price,
    ROUND(((last_price - first_price) / first_price) * 100, 2) AS total_return_pct,
    ROUND(min_price, 2) AS lowest_price,
    ROUND(max_price, 2) AS highest_price,
    ROUND(((max_price - min_price) / min_price) * 100, 2) AS price_range_pct
FROM price_boundaries;