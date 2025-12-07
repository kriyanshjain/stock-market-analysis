CREATE DATABASE StockMarketAnalysis;
USE StockMarketAnalysis;

CREATE TABLE stock_prices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticker VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    open_price DECIMAL(10, 2),
    high_price DECIMAL(10, 2),
    low_price DECIMAL(10, 2),
    close_price DECIMAL(10, 2),
    adj_close DECIMAL(10, 2),
    volume BIGINT,
    UNIQUE KEY unique_ticker_date (ticker, date)
);

LOAD DATA INFILE 'stocks.csv'
INTO TABLE stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    ticker,
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(*) AS total_records
FROM stock_prices
GROUP BY ticker;

-- Create View for Daily Returns
CREATE VIEW daily_returns AS
SELECT 
    current.ticker,
    current.date,
    current.close_price,
    previous.close_price AS prev_close,
    ROUND(
        ((current.close_price - previous.close_price) / previous.close_price) * 100, 
        4
    ) AS daily_return_pct
FROM stock_prices current
LEFT JOIN stock_prices previous 
    ON current.ticker = previous.ticker 
    AND previous.date = (
        SELECT MAX(date) 
        FROM stock_prices 
        WHERE ticker = current.ticker 
        AND date < current.date
    )
ORDER BY current.ticker, current.date;

SELECT * FROM daily_returns
WHERE ticker = 'AAPL'
ORDER BY date DESC;