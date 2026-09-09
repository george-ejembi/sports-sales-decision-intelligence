# Calculated Columns — Sports Sales Decision Intelligence

Companion reference to [`dax-measures.md`](./dax-measures.md). Documents the calculated columns used in the Sports Sales Decision Intelligence Power BI model.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Source Table](#2-source-table)
- [3. Invoice Date Only](#3-invoice-date-only)
- [4. Profitability Category](#4-profitability-category)
- [5. Sales Volume Category](#5-sales-volume-category)
- [6. Commercial Segment](#6-commercial-segment)
- [7. Commercial Segment Framework](#7-commercial-segment-framework)
- [8. Design Principle](#8-design-principle)
- [9. Threshold Governance](#9-threshold-governance)
- [10. Calculated Columns vs Measures](#10-calculated-columns-vs-measures)

---

## 1. Purpose

This document defines the calculated columns used in the Sports Sales Decision Intelligence Power BI model.

Calculated columns are used for row-level classification and segmentation where the value needs to be stored for each record and used as a categorical dimension in filters, slicers, matrices, and business-decision logic.

---

## 2. Source Table

All calculated columns documented here belong to:

**`Sales`**

Primary source fields:

| Field |
|---|
| `Invoice Date` |
| `Operating Margin` |
| `Units Sold` |
| `Total Sales` |
| `Operating Profit` |
| `Product` |
| `Sales Method` |
| `Region` |
| `Retailer` |

---

## 3. Invoice Date Only

**Purpose:** Creates a date-only field when `Invoice Date` contains a time component.

```dax
Invoice Date Only =
DATEVALUE('Sales'[Invoice Date])
```

**Usage:** This column should be used to establish the relationship with the Date dimension:

```
Date[Date]  1 ─────────── *  Sales[Invoice Date Only]
```

**Reason:** Time-intelligence functions such as `PREVIOUSMONTH()` and `DATEADD()` should operate against the dedicated Date dimension rather than the transaction date directly.

---

## 4. Profitability Category

**Purpose:** Classifies individual sales records according to operating margin.

```dax
Profitability Category =
SWITCH(
    TRUE(),

    'Sales'[Operating Margin] >= 0.30,
        "High Margin",

    'Sales'[Operating Margin] >= 0.15,
        "Moderate Margin",

    "Low Margin"
)
```

**Classification**

| Operating Margin | Category |
|---|---|
| ≥ 30% | High Margin |
| 15% – 29.9% | Moderate Margin |
| < 15% | Low Margin |

**Business use** — identifies:

- High-margin sales
- Margin-risk transactions
- Product profitability patterns
- Profitability-category contribution
- Portfolio opportunities

**Governance:** The 30% and 15% thresholds are analytical thresholds, not assumed corporate targets. They should be validated against:

- Historical performance
- Management targets
- Product category economics
- Margin distribution
- Strategic objectives

---

## 5. Sales Volume Category

**Purpose:** Classifies individual sales records according to units sold.

```dax
Sales Volume Category =
SWITCH(
    TRUE(),

    'Sales'[Units Sold] >= 100,
        "High Volume",

    'Sales'[Units Sold] >= 50,
        "Medium Volume",

    "Low Volume"
)
```

**Classification**

| Units Sold | Category |
|---|---|
| ≥ 100 | High Volume |
| 50 – 99 | Medium Volume |
| < 50 | Low Volume |

**Business use** — supports:

- Product volume analysis
- Volume/margin segmentation
- Commercial opportunity identification
- Portfolio classification

---

## 6. Commercial Segment

**Purpose:** Combines sales volume and profitability into an actionable commercial classification.

```dax
Commercial Segment =
SWITCH(
    TRUE(),

    'Sales'[Sales Volume Category] = "High Volume"
        && 'Sales'[Profitability Category] = "High Margin",
        "Scale",

    'Sales'[Sales Volume Category] = "High Volume"
        && 'Sales'[Profitability Category] = "Moderate Margin",
        "Optimize",

    'Sales'[Sales Volume Category] = "High Volume"
        && 'Sales'[Profitability Category] = "Low Margin",
        "Margin Risk",

    'Sales'[Sales Volume Category] = "Medium Volume"
        && 'Sales'[Profitability Category] = "High Margin",
        "Grow",

    'Sales'[Sales Volume Category] = "Low Volume"
        && 'Sales'[Profitability Category] = "High Margin",
        "Invest",

    'Sales'[Sales Volume Category] = "Low Volume"
        && 'Sales'[Profitability Category] = "Low Margin",
        "Review",

    "Monitor"
)
```

> Depends on `Sales Volume Category` (§5) and `Profitability Category` (§4) — both must be created first.

---

## 7. Commercial Segment Framework

| Sales Volume | Profitability | Commercial Segment | Management Interpretation |
|---|---|---|---|
| High | High | Scale | Expand and protect |
| High | Moderate | Optimize | Improve economics |
| High | Low | Margin Risk | Investigate profitability |
| Medium | High | Grow | Increase commercial focus |
| Low | High | Invest | Test growth potential |
| Low | Low | Review | Reassess viability |
| Other | Other | Monitor | Continue observation |

---

## 8. Design Principle

The calculated columns provide the categorical decision layer of the model.

```
                  Operating Margin
                         │
                         ▼
                Profitability Category
                         │
            ┌────────────┴────────────┐
            │                         │
            ▼                         ▼
        Units Sold           Sales Volume Category
            │                         │
            └────────────┬────────────┘
                          ▼
                 Commercial Segment
```

---

## 9. Threshold Governance

Thresholds should be reviewed before production deployment.

**Potential future implementation:**

```
Fixed thresholds
      ↓
Business validation
      ↓
Historical benchmarking
      ↓
Percentile segmentation
      ↓
Dynamic decision framework
```

This prevents arbitrary thresholds from becoming permanent business rules.

---

## 10. Calculated Columns vs Measures

| Requirement | Use |
|---|---|
| Row-level classification | Calculated Column |
| Product category | Calculated Column |
| Volume classification | Calculated Column |
| Commercial segment | Calculated Column |
| Total Sales | Measure |
| Total Profit | Measure |
| Operating Margin | Measure |
| Sales Growth | Measure |
| Profit Growth | Measure |
| Opportunity Score | Measure |

The model should avoid creating calculated columns where a measure is more appropriate.
