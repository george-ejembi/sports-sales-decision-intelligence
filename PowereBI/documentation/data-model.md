# Data Model — Sports Sales Decision Intelligence

Companion reference to [`dax-measures.md`](./dax-measures.md) and [`calculated-columns.md`](./calculated-columns.md). Defines the Power BI semantic model for the Sports Sales Decision Intelligence system.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Modeling Approach](#2-modeling-approach)
- [3. Fact Table](#3-fact-table)
- [4. Date Dimension](#4-date-dimension)
- [5. Date Table Construction](#5-date-table-construction)
- [6. Relationship Design](#6-relationship-design)
- [7. Why the Date Dimension Matters](#7-why-the-date-dimension-matters)
- [8. Sorting Requirements](#8-sorting-requirements)
- [9. Semantic Layer](#9-semantic-layer)
- [10. Core Analytical Dimensions](#10-core-analytical-dimensions)
- [11. Business Logic Layer](#11-business-logic-layer)
- [12. Model Governance](#12-model-governance)
- [13. Performance Considerations](#13-performance-considerations)
- [14. Future-State Model](#14-future-state-model)
- [15. Model Objective](#15-model-objective)

---

## 1. Purpose

This document defines the Power BI semantic model for the Sports Sales Decision Intelligence system.

The model is designed to provide a reliable analytical foundation for:

- Revenue analysis
- Profitability analysis
- Product intelligence
- Retailer analysis
- Sales-method analysis
- Geographic analysis
- Time intelligence
- Commercial decision-making

---

## 2. Modeling Approach

The initial dataset is transaction-oriented.

The Power BI model follows a fact-and-dimension architecture, with the sales transaction table acting as the central fact table and supporting dimensions providing analytical context.

```
                    ┌──────────────┐
                    │     Date     │
                    └──────┬───────┘
                           │
┌──────────────┐   ┌───────▼───────┐   ┌──────────────┐
│   Product    │   │     Sales     │   │   Retailer   │
└──────┬───────┘   │  Fact Table   │   └──────┬───────┘
       │           └───────┬───────┘          │
       │                   │                  │
       │           ┌───────┴───────┐          │
       ▼           ▼               ▼          ▼
   Product     Geography      Sales Method   Other Dimensions
```

---

## 3. Fact Table

### `Sales`

The `Sales` table contains transaction-level sales records.

| Field | Role | Description |
|---|---|---|
| `Retailer` | Dimension attribute | Retailer name |
| `Retailer ID` | Business key | Retailer identifier |
| `Invoice Date` | Date attribute | Transaction date |
| `Region` | Geography | Region |
| `City` | Geography | City |
| `State` | Geography | State |
| `Product` | Product attribute | Product name |
| `Price per Unit` | Measure input | Unit selling price |
| `Units Sold` | Measure input | Units sold |
| `Total Sales` | Measure input | Revenue |
| `Operating Profit` | Measure input | Operating profit |
| `Operating Margin` | Measure input | Operating margin |
| `Sales Method` | Channel | Sales method |

---

## 4. Date Dimension

### `Date`

The Date table is the primary time dimension.

**Recommended fields**

| Field | Purpose |
|---|---|
| `Date` | Primary date key |
| `Year` | Year filtering |
| `Month Number` | Month sorting |
| `Month` | Short month label |
| `Month Name` | Full month name |
| `Quarter` | Quarterly analysis |
| `Year Month` | Monthly reporting |
| `Year Month Sort` | Chronological sorting |
| `Week Number` | Weekly analysis |
| `Day` | Day number |
| `Day Name` | Day analysis |
| `Day of Week` | Day sorting |

---

## 5. Date Table Construction

```dax
Date =
VAR MinDate =
    MINX(
        ALL('Sales'),
        DATEVALUE('Sales'[Invoice Date])
    )

VAR MaxDate =
    MAXX(
        ALL('Sales'),
        DATEVALUE('Sales'[Invoice Date])
    )

RETURN
ADDCOLUMNS(
    CALENDAR(
        MinDate,
        MaxDate
    ),

    "Year",
        YEAR([Date]),

    "Month Number",
        MONTH([Date]),

    "Month",
        FORMAT([Date], "MMM"),

    "Month Name",
        FORMAT([Date], "MMMM"),

    "Quarter",
        "Q" & FORMAT([Date], "Q"),

    "Year Month",
        FORMAT([Date], "YYYY-MM"),

    "Year Month Sort",
        YEAR([Date]) * 100
        +
        MONTH([Date]),

    "Week Number",
        WEEKNUM([Date], 2),

    "Day",
        DAY([Date]),

    "Day Name",
        FORMAT([Date], "DDD"),

    "Day of Week",
        WEEKDAY([Date], 2)
)
```

---

## 6. Relationship Design

**Primary relationship**

```
Date[Date]
     │ 1
     ▼
Sales[Invoice Date Only]
     *
```

**Relationship properties**

| Property | Value |
|---|---|
| Cardinality | One-to-Many |
| Cross-filter direction | Single |
| Date table side | `Date` |
| Fact side | `Sales` |

---

## 7. Why the Date Dimension Matters

Using a dedicated Date table prevents common time-intelligence issues such as:

> `DATEADD` expects a contiguous selection

...and allows reliable calculations using:

- `PREVIOUSMONTH`
- `DATEADD`
- `SAMEPERIODLASTYEAR`
- `TOTALYTD`
- `DATESINPERIOD`

Time intelligence should therefore reference `'Date'[Date]` rather than the raw transaction date.

---

## 8. Sorting Requirements

`Year Month` should be sorted by `Year Month Sort`.

| Year Month | Sort Value |
|---|---|
| 2025-01 | 202501 |
| 2025-02 | 202502 |
| 2025-03 | 202503 |

This prevents alphabetical month ordering.

Similarly, `Month` should be sorted by `Month Number`.

---

## 9. Semantic Layer

The semantic model is organized into four logical layers.

| Layer | Contents |
|---|---|
| **Layer 1 — Transaction Data** | `Sales` |
| **Layer 2 — Dimensions** | `Date`, `Product`, `Retailer`, `Geography`, `Sales Method` |
| **Layer 3 — Analytical Logic** | Measures, Calculated Columns, Business Classifications |
| **Layer 4 — Decision Intelligence** | Growth, Profitability, Risk, Opportunity, Management Action |

---

## 10. Core Analytical Dimensions

The primary slicing dimensions are:

**Product**
- `Product`

**Retailer**
- `Retailer`
- `Retailer ID`

**Geography**
- `Region`
- `State`
- `City`

Recommended hierarchy:

```
Region
   ↓
State
   ↓
City
```

**Sales Channel**
- `Sales Method`

**Time**

```
Year
   ↓
Quarter
   ↓
Month
   ↓
Date
```

---

## 11. Business Logic Layer

The model contains the following major analytical concepts:

`Sales` → `Profit` → `Units` → `Margin` → `Growth` → `Contribution` → `Risk` → `Opportunity` → `Decision`

This creates a progression from descriptive reporting to decision support.

---

## 12. Model Governance

**Naming** — Use clear, business-readable names.

| Preferred | Avoid |
|---|---|
| `Total Operating Profit` | `Sum_OpProfit_2` |

**Measures** — Centralize reusable calculations in the measure layer.

**Columns** — Use calculated columns primarily for:

- Classification
- Segmentation
- Sorting
- Row-level attributes

**Relationships** — Avoid unnecessary many-to-many relationships.

**Filters** — Prefer single-direction relationships unless there is a documented reason to use bidirectional filtering.

---

## 13. Performance Considerations

For a larger production dataset:

- Prefer Power Query transformations for data cleaning.
- Avoid unnecessary calculated columns.
- Use measures for aggregations.
- Keep the model narrow.
- Remove unused fields.
- Use a proper star schema when the dataset expands.
- Avoid unnecessary bidirectional relationships.
- Validate model performance with Power BI Performance Analyzer.

---

## 14. Future-State Model

If the project evolves into a larger analytical warehouse, the model can be expanded toward:

```
                  Dim Date
                     │
Dim Product ─── Fact Sales ─── Dim Retailer
                     │
             Dim Sales Method
                     │
               Dim Geography
```

Potential future dimensions:

- `Dim Product`
- `Dim Retailer`
- `Dim Geography`
- `Dim Sales Method`
- `Dim Date`

This would provide a more scalable enterprise-style analytical model.

---

## 15. Model Objective

The model should ultimately enable management to move from:

```
What happened?
      ↓
Why did it happen?
      ↓
Where is the opportunity/risk?
      ↓
What should we do?
```

This is the core design principle behind the Sports Sales Decision Intelligence system.
