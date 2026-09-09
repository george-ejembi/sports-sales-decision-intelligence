Sports Sales Decision Intelligence

«A decision-intelligence system for understanding what drives revenue, sales volume, and profitability across products, retailers, sales channels, and geographic markets.»

---

Project Overview

Sports businesses generate sales across multiple products, retailers, sales methods, and geographic markets. However, high sales volume does not always translate into strong profitability, and growing revenue does not necessarily mean the business is growing efficiently.

Sports Sales Decision Intelligence transforms transaction-level sales data into actionable commercial insights that help management understand:

- What is driving revenue?
- Which products generate the most value?
- Which products sell heavily but deliver weak margins?
- Which retailers and sales methods perform best?
- Which markets are growing or declining?
- Where should the business scale, invest, optimize, or intervene?

The project combines SQL-based data analysis, business intelligence, and decision-oriented analytics to move from raw transactions to commercially actionable recommendations.

---

Business Problem

The business lacks a consolidated view of its sales and profitability performance across products, retailers, sales methods, and geographic markets.

This creates several decision-making challenges:

- High-revenue products may not be the most profitable.
- High-volume products may have weak operating margins.
- Some retailers may generate significant sales but contribute disproportionately less profit.
- Sales channels may differ significantly in commercial efficiency.
- Geographic markets may have different growth and profitability profiles.
- Management may not have a clear framework for deciding where to scale, invest, optimize, or review.

Business Objective

Develop a Sales Performance Intelligence System that converts transaction-level sales data into insights for:

1. Revenue growth
2. Profitability improvement
3. Product portfolio optimization
4. Retailer performance management
5. Sales-channel optimization
6. Geographic market prioritization
7. Commercial resource allocation

---

Key Business Questions

1. Dashboard Overview — How is the business performing?

1. How are total sales, profit, and units sold trending over time?
2. Is the business growing profitably?
3. How efficiently are sales being converted into operating profit?
4. Which regions and sales methods contribute most to overall performance?
5. Where does management need to focus attention?

2. Product Intelligence — Which products should we scale or fix?

1. Which products generate the highest sales, profit, and margins?
2. Are our highest-volume products also the most profitable?
3. Which products generate high sales but low profitability?
4. Which low-volume products have strong margins and growth potential?
5. Which products should we Scale, Invest, Optimize, or Review?

3. Sales & Commercial Intelligence — Where and how should we sell?

1. Which retailers generate the highest sales and operating profit?
2. Which sales methods generate the strongest commercial returns?
3. Which regions, states, and cities are the strongest markets?
4. Where is sales growth strongest or declining?
5. Which markets, retailers, and sales methods should management prioritize?

---

Decision Framework

The project goes beyond reporting historical performance by translating analytical results into commercial decisions.

Commercial Decision Matrix

Performance Profile| Recommended Action
High Sales + High Profit| SCALE
Low Sales + High Profit| INVEST
High Sales + Low Profit| OPTIMIZE
Low Sales + Low Profit| REVIEW

This framework helps management distinguish between areas that should receive more resources and areas where performance needs intervention.

Growth & Profitability Framework

Sales Growth| Profit Growth| Interpretation
High| High| Profitable Growth
High| Low| Unprofitable Growth
Low| High| Efficiency Opportunity
Low| Low| Commercial Decline

---

Key Performance Indicators

The analysis focuses on metrics that connect sales performance to business value.

Revenue & Volume

- Total Sales
- Total Units Sold
- Sales per Unit
- Sales Contribution %
- Month-over-Month Sales Growth %

Profitability

- Total Operating Profit
- Operating Margin %
- Profit per Unit
- Profit Contribution %
- Profit Growth %

Commercial Efficiency

- Commercial Efficiency Index
- Revenue-to-Profit Risk
- Product Profitability Index
- Product Opportunity Score

Portfolio Intelligence

- Sales Volume Category
- Profitability Category
- Commercial Segment
- Product Decision

---

🗂️ Dataset

The dataset contains transaction-level sports product sales information.

Core Fields

Field| Description
"Retailer"| Name of the retailer
"Retailer ID"| Unique retailer identifier
"Invoice Date"| Transaction date
"Region"| Geographic region
"City"| City where the transaction occurred
"State"| State where the transaction occurred
"Product"| Sports product sold
"Price per Unit"| Selling price per unit
"Units Sold"| Number of units sold
"Total Sales"| Total transaction revenue
"Operating Profit"| Operating profit generated
"Operating Margin"| Operating profit margin
"Sales Method"| Sales channel/method

---

Technology Stack

Data Analysis

- SQL

Business Intelligence

- Microsoft Power BI
- DAX
- Power Query

Data Management

- Relational data modeling
- Dimensional modeling concepts
- Data quality validation
- Time-series analysis

Development & Version Control

- Git
- GitHub

---

Analytical Methodology

The project follows a structured analytics workflow:

Raw Sales Data
      │
      ▼
Data Profiling
      │
      ▼
Data Quality Checks
      │
      ▼
Data Cleaning & Transformation
      │
      ▼
Exploratory Analysis
      │
      ▼
Business Analysis
      │
      ▼
Data Modeling
      │
      ▼
DAX Measures & KPIs
      │
      ▼
Power BI Decision Dashboards
      │
      ▼
Insights & Recommendations

---

📈 Dashboard Structure

01 — Dashboard Overview

Answers:

«How is the business performing?»

Focus areas:

- Sales trend
- Profit trend
- Units sold
- Month-over-month growth
- Operating margin
- Regional performance
- Sales-method performance
- Revenue-to-profit risk

---

02 — Product Intelligence

Answers:

«Which products should we scale or fix?»

Focus areas:

- Product sales
- Product profitability
- Sales volume
- Operating margin
- Profit per unit
- Sales vs profit relationship
- Product opportunity
- Commercial segmentation

Products are classified into actionable segments such as:

- Scale
- Grow
- Invest
- Optimize
- Margin Risk
- Review
- Monitor

---

03 — Sales & Commercial Intelligence

Answers:

«Where and how should we sell?»

Focus areas:

- Retailer performance
- Sales-method performance
- Regional performance
- State-level performance
- City-level performance
- Sales growth
- Profit growth
- Commercial opportunities

---

Analytical Concepts

The project incorporates several decision-oriented analytical concepts.

Operating Margin

Measures how efficiently revenue is converted into operating profit.

Operating Margin =
Operating Profit / Total Sales

Profit per Unit

Measures the average operating profit generated per unit sold.

Profit per Unit =
Operating Profit / Units Sold

Revenue-to-Profit Risk

Identifies areas where the contribution to revenue is significantly greater than the contribution to profit.

A positive gap may indicate that an area generates substantial sales without producing proportional profitability.

Product Opportunity

Products are evaluated using a combination of:

- Sales
- Sales volume
- Profitability
- Growth

This allows the analysis to move beyond simply ranking products by revenue.

---

Repository Structure
---

Expected Business Outcomes

The completed system is designed to help decision-makers:

- Identify the products responsible for profitable growth.
- Detect high-revenue products with weak profitability.
- Prioritize high-margin products with growth potential.
- Identify high-performing retailers and sales channels.
- Detect underperforming markets.
- Understand where revenue growth is or is not translating into profit.
- Improve commercial resource allocation.
- Support evidence-based product and market decisions.

The ultimate goal is not simply to answer “What happened?”, but:

«“What should management do next?”»

---

Project Status

Component| Status
Business problem definition| 🟢 Complete
Business questions| 🟢 Complete
Repository architecture| 🟢 Complete
Data profiling| 🔵 In Progress
Data quality checks| 🔵 In Progress
SQL analysis| 🔵 In Progress
Data model| 🔵 In Progress
DAX measures| 🔵 In Progress
Power BI dashboards| 🔵 In Progress
Insights| 🔵 In Progress
Recommendations| 🔵 In Progress

---

👤 Author

George

Data Analyst | Analytics Engineer | Data Scientist

Focused on building data systems that transform raw operational data into business intelligence and actionable decisions.
