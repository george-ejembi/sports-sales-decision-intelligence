/*==============================================================================
    PROJECT: SPORTS SALES DECISION INTELLIGENCE
    FILE: sports_sales_analysis.sql

    PURPOSE:
    End-to-end SQL analysis of sports product sales data.

    ANALYTICAL OBJECTIVES:
        1. Profile the source data
        2. Identify data-quality issues
        3. Validate business metrics
        4. Analyze sales, volume and profitability
        5. Analyze products, retailers, channels and markets
        6. Identify growth and profitability opportunities
        7. Support Power BI decision-intelligence reporting

    SOURCE TABLE:
        dbo.Sales

    IMPORTANT:
        - This script is READ-ONLY against the source table.
        - No DELETE, UPDATE or DROP operations are performed on dbo.Sales.
        - Cleaning logic is implemented through SELECT statements.
        - Validate column data types before production deployment.

    AUTHOR:
        George
==============================================================================*/


/*==============================================================================
    SECTION 01 — DATA PROFILING
==============================================================================*/


/*------------------------------------------------------------------------------
    1.1 — Source row count
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS total_rows
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    1.2 — Dataset structure
------------------------------------------------------------------------------*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Sales'
ORDER BY ORDINAL_POSITION;


/*------------------------------------------------------------------------------
    1.3 — Basic categorical profiling
------------------------------------------------------------------------------*/

SELECT
    COUNT(DISTINCT Retailer) AS unique_retailers,
    COUNT(DISTINCT [Retailer ID]) AS unique_retailer_ids,
    COUNT(DISTINCT Region) AS unique_regions,
    COUNT(DISTINCT State) AS unique_states,
    COUNT(DISTINCT City) AS unique_cities,
    COUNT(DISTINCT Product) AS unique_products,
    COUNT(DISTINCT [Sales Method]) AS unique_sales_methods
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    1.4 — Date range
------------------------------------------------------------------------------*/

SELECT
    MIN(TRY_CONVERT(date, [Invoice Date])) AS minimum_invoice_date,
    MAX(TRY_CONVERT(date, [Invoice Date])) AS maximum_invoice_date,
    DATEDIFF(
        DAY,
        MIN(TRY_CONVERT(date, [Invoice Date])),
        MAX(TRY_CONVERT(date, [Invoice Date]))
    ) AS date_range_days
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    1.5 — Numerical summary statistics
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS transaction_count,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS total_units_sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS total_sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS total_operating_profit,

    AVG(TRY_CONVERT(decimal(18,2), [Price per Unit])) AS average_price_per_unit,

    AVG(TRY_CONVERT(decimal(18,2), [Units Sold])) AS average_units_per_transaction,

    AVG(TRY_CONVERT(decimal(18,2), [Total Sales])) AS average_transaction_sales,

    AVG(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS average_transaction_profit,

    MIN(TRY_CONVERT(decimal(18,2), [Total Sales])) AS minimum_transaction_sales,

    MAX(TRY_CONVERT(decimal(18,2), [Total Sales])) AS maximum_transaction_sales
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    1.6 — Categorical distributions
------------------------------------------------------------------------------*/

SELECT
    [Sales Method],
    COUNT(*) AS transaction_count,
    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS total_sales,
    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS total_profit
FROM dbo.Sales
GROUP BY [Sales Method]
ORDER BY total_sales DESC;


SELECT
    Region,
    COUNT(*) AS transaction_count,
    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS total_sales,
    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS total_profit
FROM dbo.Sales
GROUP BY Region
ORDER BY total_sales DESC;


SELECT
    Product,
    COUNT(*) AS transaction_count,
    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS units_sold,
    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS total_sales,
    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS total_profit
FROM dbo.Sales
GROUP BY Product
ORDER BY total_sales DESC;


/*==============================================================================
    SECTION 02 — DATA QUALITY CHECKS
==============================================================================*/


/*------------------------------------------------------------------------------
    2.1 — NULL / blank value assessment
------------------------------------------------------------------------------*/

SELECT
    SUM(CASE WHEN Retailer IS NULL OR LTRIM(RTRIM(Retailer)) = '' THEN 1 ELSE 0 END)
        AS missing_retailer,

    SUM(CASE WHEN [Retailer ID] IS NULL THEN 1 ELSE 0 END)
        AS missing_retailer_id,

    SUM(CASE WHEN [Invoice Date] IS NULL THEN 1 ELSE 0 END)
        AS missing_invoice_date,

    SUM(CASE WHEN Region IS NULL OR LTRIM(RTRIM(Region)) = '' THEN 1 ELSE 0 END)
        AS missing_region,

    SUM(CASE WHEN City IS NULL OR LTRIM(RTRIM(City)) = '' THEN 1 ELSE 0 END)
        AS missing_city,

    SUM(CASE WHEN State IS NULL OR LTRIM(RTRIM(State)) = '' THEN 1 ELSE 0 END)
        AS missing_state,

    SUM(CASE WHEN Product IS NULL OR LTRIM(RTRIM(Product)) = '' THEN 1 ELSE 0 END)
        AS missing_product,

    SUM(CASE WHEN [Price per Unit] IS NULL THEN 1 ELSE 0 END)
        AS missing_price,

    SUM(CASE WHEN [Units Sold] IS NULL THEN 1 ELSE 0 END)
        AS missing_units,

    SUM(CASE WHEN [Total Sales] IS NULL THEN 1 ELSE 0 END)
        AS missing_sales,

    SUM(CASE WHEN [Operating Profit] IS NULL THEN 1 ELSE 0 END)
        AS missing_profit,

    SUM(CASE WHEN [Operating Margin] IS NULL THEN 1 ELSE 0 END)
        AS missing_margin,

    SUM(CASE WHEN [Sales Method] IS NULL OR LTRIM(RTRIM([Sales Method])) = '' THEN 1 ELSE 0 END)
        AS missing_sales_method

FROM dbo.Sales;


/*------------------------------------------------------------------------------
    2.2 — Invalid numeric values
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS invalid_numeric_rows
FROM dbo.Sales
WHERE TRY_CONVERT(decimal(18,2), [Price per Unit]) IS NULL
   OR TRY_CONVERT(decimal(18,2), [Units Sold]) IS NULL
   OR TRY_CONVERT(decimal(18,2), [Total Sales]) IS NULL
   OR TRY_CONVERT(decimal(18,2), [Operating Profit]) IS NULL
   OR TRY_CONVERT(decimal(18,4), [Operating Margin]) IS NULL;


/*------------------------------------------------------------------------------
    2.3 — Invalid dates
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS invalid_date_rows
FROM dbo.Sales
WHERE TRY_CONVERT(date, [Invoice Date]) IS NULL;


/*------------------------------------------------------------------------------
    2.4 — Negative values
------------------------------------------------------------------------------*/

SELECT
    SUM(
        CASE
            WHEN TRY_CONVERT(decimal(18,2), [Price per Unit]) < 0
            THEN 1 ELSE 0
        END
    ) AS negative_prices,

    SUM(
        CASE
            WHEN TRY_CONVERT(decimal(18,2), [Units Sold]) < 0
            THEN 1 ELSE 0
        END
    ) AS negative_units,

    SUM(
        CASE
            WHEN TRY_CONVERT(decimal(18,2), [Total Sales]) < 0
            THEN 1 ELSE 0
        END
    ) AS negative_sales
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    2.5 — Zero-value checks
------------------------------------------------------------------------------*/

SELECT
    SUM(CASE WHEN TRY_CONVERT(decimal(18,2), [Price per Unit]) = 0 THEN 1 ELSE 0 END)
        AS zero_price,

    SUM(CASE WHEN TRY_CONVERT(decimal(18,2), [Units Sold]) = 0 THEN 1 ELSE 0 END)
        AS zero_units,

    SUM(CASE WHEN TRY_CONVERT(decimal(18,2), [Total Sales]) = 0 THEN 1 ELSE 0 END)
        AS zero_sales
FROM dbo.Sales;


/*------------------------------------------------------------------------------
    2.6 — Duplicate transaction assessment

    NOTE:
    This checks duplicates across the complete record rather than assuming
    an artificial transaction ID that does not exist in the source dataset.
------------------------------------------------------------------------------*/

SELECT
    Retailer,
    [Retailer ID],
    [Invoice Date],
    Region,
    City,
    State,
    Product,
    [Price per Unit],
    [Units Sold],
    [Total Sales],
    [Operating Profit],
    [Operating Margin],
    [Sales Method],
    COUNT(*) AS duplicate_count
FROM dbo.Sales
GROUP BY
    Retailer,
    [Retailer ID],
    [Invoice Date],
    Region,
    City,
    State,
    Product,
    [Price per Unit],
    [Units Sold],
    [Total Sales],
    [Operating Profit],
    [Operating Margin],
    [Sales Method]
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


/*------------------------------------------------------------------------------
    2.7 — Sales reconciliation

    Expected:
        Price per Unit × Units Sold ≈ Total Sales
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN ABS(
                TRY_CONVERT(decimal(18,2), [Price per Unit])
                *
                TRY_CONVERT(decimal(18,2), [Units Sold])
                -
                TRY_CONVERT(decimal(18,2), [Total Sales])
            ) > 0.01
            THEN 1 ELSE 0
        END
    ) AS sales_reconciliation_failures

FROM dbo.Sales;


/*------------------------------------------------------------------------------
    2.8 — Profit reconciliation

    Expected:
        Operating Profit / Total Sales ≈ Operating Margin
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN TRY_CONVERT(decimal(18,2), [Total Sales]) <> 0
             AND ABS(
                (
                    TRY_CONVERT(decimal(18,2), [Operating Profit])
                    /
                    TRY_CONVERT(decimal(18,2), [Total Sales])
                )
                -
                TRY_CONVERT(decimal(18,6), [Operating Margin])
             ) > 0.0001
            THEN 1 ELSE 0
        END
    ) AS margin_reconciliation_failures

FROM dbo.Sales;


/*==============================================================================
    SECTION 03 — CLEANED ANALYTICAL DATASET
==============================================================================*/


/*
    This CTE standardizes the source fields without modifying dbo.Sales.

    It can be reused as the foundation for downstream analytical queries.
*/

WITH CleanSales AS
(
    SELECT
        LTRIM(RTRIM(Retailer)) AS Retailer,

        TRY_CONVERT(int, [Retailer ID]) AS Retailer_ID,

        TRY_CONVERT(date, [Invoice Date]) AS Invoice_Date,

        LTRIM(RTRIM(Region)) AS Region,

        LTRIM(RTRIM(City)) AS City,

        LTRIM(RTRIM(State)) AS State,

        LTRIM(RTRIM(Product)) AS Product,

        TRY_CONVERT(decimal(18,2), [Price per Unit]) AS Price_Per_Unit,

        TRY_CONVERT(decimal(18,2), [Units Sold]) AS Units_Sold,

        TRY_CONVERT(decimal(18,2), [Total Sales]) AS Total_Sales,

        TRY_CONVERT(decimal(18,2), [Operating Profit]) AS Operating_Profit,

        TRY_CONVERT(decimal(18,6), [Operating Margin]) AS Operating_Margin,

        LTRIM(RTRIM([Sales Method])) AS Sales_Method

    FROM dbo.Sales
)

SELECT *
FROM CleanSales;


/*------------------------------------------------------------------------------
    3.1 — Analytical dataset with derived metrics
------------------------------------------------------------------------------*/

WITH CleanSales AS
(
    SELECT
        LTRIM(RTRIM(Retailer)) AS Retailer,
        TRY_CONVERT(int, [Retailer ID]) AS Retailer_ID,
        TRY_CONVERT(date, [Invoice Date]) AS Invoice_Date,
        LTRIM(RTRIM(Region)) AS Region,
        LTRIM(RTRIM(City)) AS City,
        LTRIM(RTRIM(State)) AS State,
        LTRIM(RTRIM(Product)) AS Product,
        TRY_CONVERT(decimal(18,2), [Price per Unit]) AS Price_Per_Unit,
        TRY_CONVERT(decimal(18,2), [Units Sold]) AS Units_Sold,
        TRY_CONVERT(decimal(18,2), [Total Sales]) AS Total_Sales,
        TRY_CONVERT(decimal(18,2), [Operating Profit]) AS Operating_Profit,
        TRY_CONVERT(decimal(18,6), [Operating Margin]) AS Operating_Margin,
        LTRIM(RTRIM([Sales Method])) AS Sales_Method
    FROM dbo.Sales
)

SELECT
    *,
    
    YEAR(Invoice_Date) AS Sales_Year,

    MONTH(Invoice_Date) AS Sales_Month,

    DATEFROMPARTS(
        YEAR(Invoice_Date),
        MONTH(Invoice_Date),
        1
    ) AS Month_Start,

    CASE
        WHEN Units_Sold > 0
        THEN Operating_Profit / Units_Sold
        ELSE NULL
    END AS Profit_Per_Unit,

    CASE
        WHEN Units_Sold > 0
        THEN Total_Sales / Units_Sold
        ELSE NULL
    END AS Sales_Per_Unit,

    CASE
        WHEN Total_Sales > 0
        THEN Operating_Profit / Total_Sales
        ELSE NULL
    END AS Calculated_Operating_Margin

FROM CleanSales;


/*==============================================================================
    SECTION 04 — EXPLORATORY SALES ANALYSIS
==============================================================================*/


/*------------------------------------------------------------------------------
    4.1 — Overall business performance
------------------------------------------------------------------------------*/

SELECT
    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Total_Operating_Profit,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Total_Units_Sold,

    COUNT(DISTINCT [Retailer ID]) AS Active_Retailers,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        ELSE NULL
    END AS Profit_Per_Unit

FROM dbo.Sales;


/*------------------------------------------------------------------------------
    4.2 — Monthly sales and profitability trend
------------------------------------------------------------------------------*/

SELECT
    DATEFROMPARTS(
        YEAR(TRY_CONVERT(date, [Invoice Date])),
        MONTH(TRY_CONVERT(date, [Invoice Date])),
        1
    ) AS Month_Start,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Total_Operating_Profit,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Total_Units_Sold,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY
    DATEFROMPARTS(
        YEAR(TRY_CONVERT(date, [Invoice Date])),
        MONTH(TRY_CONVERT(date, [Invoice Date])),
        1
    )

ORDER BY Month_Start;


/*------------------------------------------------------------------------------
    4.3 — Yearly performance
------------------------------------------------------------------------------*/

SELECT
    YEAR(TRY_CONVERT(date, [Invoice Date])) AS Sales_Year,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Total_Operating_Profit,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Total_Units_Sold,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY
    YEAR(TRY_CONVERT(date, [Invoice Date]))

ORDER BY Sales_Year;


/*==============================================================================
    SECTION 05 — PRODUCT INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    5.1 — Product performance ranking
------------------------------------------------------------------------------*/

SELECT
    Product,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        ELSE NULL
    END AS Profit_Per_Unit

FROM dbo.Sales

GROUP BY Product

ORDER BY Operating_Profit DESC;


/*------------------------------------------------------------------------------
    5.2 — Highest-volume products
------------------------------------------------------------------------------*/

SELECT TOP 10
    Product,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit

FROM dbo.Sales

GROUP BY Product

ORDER BY Units_Sold DESC;


/*------------------------------------------------------------------------------
    5.3 — Highest-margin products
------------------------------------------------------------------------------*/

SELECT
    Product,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY Product

HAVING SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) > 0

ORDER BY Operating_Margin DESC;


/*------------------------------------------------------------------------------
    5.4 — High-sales / low-profit products
------------------------------------------------------------------------------*/

WITH ProductPerformance AS
(
    SELECT
        Product,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

        SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

        CASE
            WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
            THEN
                SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
                /
                SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
            ELSE NULL
        END AS Operating_Margin

    FROM dbo.Sales

    GROUP BY Product
),

RankedProducts AS
(
    SELECT
        *,
        PERCENT_RANK() OVER (ORDER BY Total_Sales) AS Sales_Percentile,
        PERCENT_RANK() OVER (ORDER BY Operating_Profit) AS Profit_Percentile
    FROM ProductPerformance
)

SELECT *
FROM RankedProducts

WHERE Sales_Percentile >= 0.75
  AND Profit_Percentile <= 0.50

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    5.5 — Product commercial classification

    Decision framework:
        High Volume + High Margin = SCALE
        Medium Volume + High Margin = GROW
        Low Volume + High Margin = INVEST
        High Volume + Low Margin = OPTIMIZE
        Low Volume + Low Margin = REVIEW
        Everything else = MONITOR
------------------------------------------------------------------------------*/

WITH ProductPerformance AS
(
    SELECT
        Product,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

        CASE
            WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
            THEN
                SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
                /
                SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
            ELSE NULL
        END AS Operating_Margin

    FROM dbo.Sales

    GROUP BY Product
)

SELECT
    Product,
    Total_Sales,
    Units_Sold,
    Operating_Profit,
    Operating_Margin,

    CASE
        WHEN Operating_Margin >= 0.30
            THEN 'High Margin'

        WHEN Operating_Margin >= 0.15
            THEN 'Moderate Margin'

        ELSE 'Low Margin'
    END AS Profitability_Category,

    CASE
        WHEN Units_Sold >= 100
            THEN 'High Volume'

        WHEN Units_Sold >= 50
            THEN 'Medium Volume'

        ELSE 'Low Volume'
    END AS Sales_Volume_Category,

    CASE

        WHEN Units_Sold >= 100
         AND Operating_Margin >= 0.30
            THEN 'SCALE'

        WHEN Units_Sold >= 50
         AND Operating_Margin >= 0.30
            THEN 'GROW'

        WHEN Units_Sold < 50
         AND Operating_Margin >= 0.30
            THEN 'INVEST'

        WHEN Units_Sold >= 100
         AND Operating_Margin < 0.15
            THEN 'OPTIMIZE'

        WHEN Units_Sold < 50
         AND Operating_Margin < 0.15
            THEN 'REVIEW'

        ELSE 'MONITOR'

    END AS Commercial_Decision

FROM ProductPerformance

ORDER BY
    Operating_Profit DESC;


/*==============================================================================
    SECTION 06 — RETAILER INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    6.1 — Retailer performance
------------------------------------------------------------------------------*/

SELECT
    Retailer,

    COUNT(*) AS Transaction_Count,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY Retailer

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    6.2 — Retailer sales contribution
------------------------------------------------------------------------------*/

WITH RetailerPerformance AS
(
    SELECT
        Retailer,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit

    FROM dbo.Sales

    GROUP BY Retailer
)

SELECT
    Retailer,
    Total_Sales,
    Operating_Profit,

    Total_Sales
    /
    NULLIF(SUM(Total_Sales) OVER (), 0) AS Sales_Contribution,

    Operating_Profit
    /
    NULLIF(SUM(Operating_Profit) OVER (), 0) AS Profit_Contribution

FROM RetailerPerformance

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    6.3 — Retailers with revenue-profit imbalance
------------------------------------------------------------------------------*/

WITH RetailerPerformance AS
(
    SELECT
        Retailer,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit

    FROM dbo.Sales

    GROUP BY Retailer
),

Contribution AS
(
    SELECT
        Retailer,
        Total_Sales,
        Operating_Profit,

        Total_Sales
        /
        NULLIF(SUM(Total_Sales) OVER (), 0) AS Sales_Contribution,

        Operating_Profit
        /
        NULLIF(SUM(Operating_Profit) OVER (), 0) AS Profit_Contribution

    FROM RetailerPerformance
)

SELECT
    Retailer,
    Total_Sales,
    Operating_Profit,
    Sales_Contribution,
    Profit_Contribution,

    (Sales_Contribution - Profit_Contribution) AS Revenue_Profit_Gap

FROM Contribution

ORDER BY Revenue_Profit_Gap DESC;


/*==============================================================================
    SECTION 07 — SALES METHOD INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    7.1 — Sales method performance
------------------------------------------------------------------------------*/

SELECT
    [Sales Method] AS Sales_Method,

    COUNT(*) AS Transaction_Count,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY [Sales Method]

ORDER BY Operating_Profit DESC;


/*------------------------------------------------------------------------------
    7.2 — Sales method efficiency
------------------------------------------------------------------------------*/

SELECT
    [Sales Method] AS Sales_Method,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        ELSE NULL
    END AS Profit_Per_Unit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY [Sales Method]

ORDER BY Operating_Margin DESC;


/*==============================================================================
    SECTION 08 — GEOGRAPHIC MARKET INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    8.1 — Regional performance
------------------------------------------------------------------------------*/

SELECT
    Region,

    COUNT(*) AS Transaction_Count,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY Region

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    8.2 — State performance
------------------------------------------------------------------------------*/

SELECT
    Region,
    State,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY
    Region,
    State

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    8.3 — City performance
------------------------------------------------------------------------------*/

SELECT
    Region,
    State,
    City,

    SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

    SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin

FROM dbo.Sales

GROUP BY
    Region,
    State,
    City

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    8.4 — Geographic revenue-profit risk
------------------------------------------------------------------------------*/

WITH MarketPerformance AS
(
    SELECT
        Region,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit

    FROM dbo.Sales

    GROUP BY Region
),

Contribution AS
(
    SELECT
        Region,
        Total_Sales,
        Operating_Profit,

        Total_Sales
        /
        NULLIF(SUM(Total_Sales) OVER (), 0) AS Sales_Contribution,

        Operating_Profit
        /
        NULLIF(SUM(Operating_Profit) OVER (), 0) AS Profit_Contribution

    FROM MarketPerformance
)

SELECT
    Region,
    Total_Sales,
    Operating_Profit,
    Sales_Contribution,
    Profit_Contribution,

    (Sales_Contribution - Profit_Contribution) AS Revenue_Profit_Gap

FROM Contribution

ORDER BY Revenue_Profit_Gap DESC;


/*==============================================================================
    SECTION 09 — GROWTH INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    9.1 — Monthly sales growth

    LAG() is used instead of self-joins to create a cleaner analytical pattern.
------------------------------------------------------------------------------*/

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(TRY_CONVERT(date, [Invoice Date])),
            MONTH(TRY_CONVERT(date, [Invoice Date])),
            1
        ) AS Month_Start,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Total_Operating_Profit

    FROM dbo.Sales

    GROUP BY
        DATEFROMPARTS(
            YEAR(TRY_CONVERT(date, [Invoice Date])),
            MONTH(TRY_CONVERT(date, [Invoice Date])),
            1
        )
),

Growth AS
(
    SELECT
        Month_Start,
        Total_Sales,
        Total_Operating_Profit,

        LAG(Total_Sales)
            OVER (ORDER BY Month_Start) AS Previous_Month_Sales,

        LAG(Total_Operating_Profit)
            OVER (ORDER BY Month_Start) AS Previous_Month_Profit

    FROM MonthlySales
)

SELECT
    Month_Start,
    Total_Sales,
    Total_Operating_Profit,
    Previous_Month_Sales,
    Previous_Month_Profit,

    CASE
        WHEN Previous_Month_Sales <> 0
        THEN
            (Total_Sales - Previous_Month_Sales)
            /
            Previous_Month_Sales
        ELSE NULL
    END AS Sales_Growth_Percentage,

    CASE
        WHEN Previous_Month_Profit <> 0
        THEN
            (Total_Operating_Profit - Previous_Month_Profit)
            /
            Previous_Month_Profit
        ELSE NULL
    END AS Profit_Growth_Percentage

FROM Growth

ORDER BY Month_Start;


/*------------------------------------------------------------------------------
    9.2 — Profitable growth classification
------------------------------------------------------------------------------*/

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(TRY_CONVERT(date, [Invoice Date])),
            MONTH(TRY_CONVERT(date, [Invoice Date])),
            1
        ) AS Month_Start,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Total_Operating_Profit

    FROM dbo.Sales

    GROUP BY
        DATEFROMPARTS(
            YEAR(TRY_CONVERT(date, [Invoice Date])),
            MONTH(TRY_CONVERT(date, [Invoice Date])),
            1
        )
),

Growth AS
(
    SELECT
        *,
        LAG(Total_Sales)
            OVER (ORDER BY Month_Start) AS Previous_Month_Sales,

        LAG(Total_Operating_Profit)
            OVER (ORDER BY Month_Start) AS Previous_Month_Profit

    FROM MonthlySales
),

GrowthMetrics AS
(
    SELECT
        *,
        
        CASE
            WHEN Previous_Month_Sales <> 0
            THEN
                (Total_Sales - Previous_Month_Sales)
                /
                Previous_Month_Sales
            ELSE NULL
        END AS Sales_Growth,

        CASE
            WHEN Previous_Month_Profit <> 0
            THEN
                (Total_Operating_Profit - Previous_Month_Profit)
                /
                Previous_Month_Profit
            ELSE NULL
        END AS Profit_Growth

    FROM Growth
)

SELECT
    Month_Start,
    Total_Sales,
    Total_Operating_Profit,
    Sales_Growth,
    Profit_Growth,

    CASE
        WHEN Sales_Growth > 0
         AND Profit_Growth > 0
            THEN 'PROFITABLE GROWTH'

        WHEN Sales_Growth > 0
         AND Profit_Growth <= 0
            THEN 'UNPROFITABLE GROWTH'

        WHEN Sales_Growth <= 0
         AND Profit_Growth > 0
            THEN 'EFFICIENCY OPPORTUNITY'

        WHEN Sales_Growth <= 0
         AND Profit_Growth <= 0
            THEN 'COMMERCIAL DECLINE'

        ELSE 'MONITOR'
    END AS Growth_Segment

FROM GrowthMetrics

ORDER BY Month_Start;


/*==============================================================================
    SECTION 10 — MANAGEMENT DECISION INTELLIGENCE
==============================================================================*/


/*------------------------------------------------------------------------------
    10.1 — Product decision matrix

    Four primary quadrants:
        High Sales + High Profit = SCALE
        Low Sales + High Profit = INVEST
        High Sales + Low Profit = OPTIMIZE
        Low Sales + Low Profit = REVIEW

    Thresholds are based on medians rather than arbitrary fixed values.
------------------------------------------------------------------------------*/

WITH ProductPerformance AS
(
    SELECT
        Product,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit

    FROM dbo.Sales

    GROUP BY Product
),

Thresholds AS
(
    SELECT
        *,
        
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Total_Sales)
        OVER () AS Median_Sales,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Operating_Profit)
        OVER () AS Median_Profit

    FROM ProductPerformance
)

SELECT
    Product,
    Total_Sales,
    Operating_Profit,
    Median_Sales,
    Median_Profit,

    CASE

        WHEN Total_Sales >= Median_Sales
         AND Operating_Profit >= Median_Profit
            THEN 'SCALE'

        WHEN Total_Sales < Median_Sales
         AND Operating_Profit >= Median_Profit
            THEN 'INVEST'

        WHEN Total_Sales >= Median_Sales
         AND Operating_Profit < Median_Profit
            THEN 'OPTIMIZE'

        WHEN Total_Sales < Median_Sales
         AND Operating_Profit < Median_Profit
            THEN 'REVIEW'

        ELSE 'MONITOR'

    END AS Management_Decision

FROM Thresholds

ORDER BY
    Operating_Profit DESC;


/*------------------------------------------------------------------------------
    10.2 — Regional commercial opportunity matrix
------------------------------------------------------------------------------*/

WITH RegionalPerformance AS
(
    SELECT
        Region,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

        CASE
            WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
            THEN
                SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
                /
                SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
            ELSE NULL
        END AS Operating_Margin

    FROM dbo.Sales

    GROUP BY Region
),

Thresholds AS
(
    SELECT
        *,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Total_Sales)
        OVER () AS Median_Sales,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Operating_Margin)
        OVER () AS Median_Margin

    FROM RegionalPerformance
)

SELECT
    Region,
    Total_Sales,
    Operating_Profit,
    Operating_Margin,

    CASE

        WHEN Total_Sales >= Median_Sales
         AND Operating_Margin >= Median_Margin
            THEN 'SCALE'

        WHEN Total_Sales < Median_Sales
         AND Operating_Margin >= Median_Margin
            THEN 'INVEST'

        WHEN Total_Sales >= Median_Sales
         AND Operating_Margin < Median_Margin
            THEN 'OPTIMIZE'

        WHEN Total_Sales < Median_Sales
         AND Operating_Margin < Median_Margin
            THEN 'REVIEW'

        ELSE 'MONITOR'

    END AS Management_Decision

FROM Thresholds

ORDER BY Total_Sales DESC;


/*------------------------------------------------------------------------------
    10.3 — High-volume / high-margin opportunity analysis
------------------------------------------------------------------------------*/

WITH ProductPerformance AS
(
    SELECT
        Product,

        SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) AS Units_Sold,

        SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) AS Total_Sales,

        SUM(TRY_CONVERT(decimal(18,2), [Operating Profit])) AS Operating_Profit,

        CASE
            WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
            THEN
                SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
                /
                SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
            ELSE NULL
        END AS Operating_Margin

    FROM dbo.Sales

    GROUP BY Product
),

Thresholds AS
(
    SELECT
        *,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Units_Sold)
        OVER () AS Median_Units,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Operating_Margin)
        OVER () AS Median_Margin

    FROM ProductPerformance
)

SELECT
    Product,
    Units_Sold,
    Total_Sales,
    Operating_Profit,
    Operating_Margin,

    CASE
        WHEN Units_Sold >= Median_Units
         AND Operating_Margin >= Median_Margin
            THEN 'CORE WINNER'

        WHEN Units_Sold >= Median_Units
         AND Operating_Margin < Median_Margin
            THEN 'MARGIN OPTIMIZATION'

        WHEN Units_Sold < Median_Units
         AND Operating_Margin >= Median_Margin
            THEN 'GROWTH OPPORTUNITY'

        ELSE 'UNDERPERFORMER'

    END AS Portfolio_Segment

FROM Thresholds

ORDER BY Operating_Profit DESC;


/*==============================================================================
    SECTION 11 — EXECUTIVE PERFORMANCE SUMMARY
==============================================================================*/


/*
    Final SQL output designed to provide a management-level summary.

    This can be used as a source for a Power BI executive summary page.
*/

SELECT

    /* Revenue */
    SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        AS Total_Sales,

    /* Profit */
    SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
        AS Total_Operating_Profit,

    /* Volume */
    SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        AS Total_Units_Sold,

    /* Retailer count */
    COUNT(DISTINCT [Retailer ID])
        AS Active_Retailers,

    /* Profitability */
    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Total Sales])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
        ELSE NULL
    END AS Operating_Margin,

    /* Profit per unit */
    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Operating Profit]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        ELSE NULL
    END AS Profit_Per_Unit,

    /* Average selling price */
    CASE
        WHEN SUM(TRY_CONVERT(decimal(18,2), [Units Sold])) <> 0
        THEN
            SUM(TRY_CONVERT(decimal(18,2), [Total Sales]))
            /
            SUM(TRY_CONVERT(decimal(18,2), [Units Sold]))
        ELSE NULL
    END AS Sales_Per_Unit

FROM dbo.Sales;


/*==============================================================================
    END OF ANALYSIS
==============================================================================*/
