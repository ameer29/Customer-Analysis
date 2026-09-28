# Retail Customer Analysis: SQL → Excel → Power BI

**AnalytixLabs integrated case study · Jun 2023 · SQL Server (T-SQL) · Excel pivots & Pareto · Power BI**

This was the Term 1 capstone of my 2023 career switch. One retail dataset (transactions for a multi-store chain, joined to customer demographics) runs through all three tools:

1. **SQL:** clean the raw tables, join them, answer 15 business questions and build a Customer 360 table.
2. **Excel:** take the sampled data (**67,593 transactions**) and answer 10 more questions with formulas, pivot tables and **Pareto analysis**.
3. **Power BI:** build an interactive **3-page dashboard** on the same sample.

| | |
|---|---|
| 🗄️ **SQL** | [`sql/customer_analysis.sql`](sql/customer_analysis.sql) |
| 📗 **Excel** | [`excel/sample_data_with_excel_answers.xlsx`](excel/sample_data_with_excel_answers.xlsx): `SAMPLE_DATA` sheet plus the `Excel Answers` sheet (formulas and pivots) |
| 📊 **Power BI** | [`powerbi/customer_analysis_dashboard.pbix`](powerbi/customer_analysis_dashboard.pbix): open it in Power BI Desktop |
| 🗜️ Original upload | `Customer Analysis.zip` (same files, kept for history) |

---

## 1 · SQL (SQL Server)
- **Cleaning:** dropped an empty column, and deleted rows with a missing customer (MCN), store or cash-memo number.
- **Joining:** built `FINAL_DATA` by left-joining transactions to customers.
- **Questions answered:**
  - null audit
  - distinct shoppers and multi-store shoppers
  - shopping behaviour by **weekday** (customers, transactions, sales, quantity)
  - revenue by location and by store
  - department spend by store
  - data date range
  - top-3 locations by share of sales
  - sales by gender
  - **discount and discount % by location**
  - best age group
  - average transaction value by gender × location × segment
- **Customer_360 table:** defined the schema (transactions, items, spend and transactions per department, weekday vs weekend, spend rank, decile).
- **Output:** exported `SAMPLE_DATA` (`sample_flag = 1`) for the Excel and Power BI stages.

## 2 · Excel
- Transactions per department with `COUNTIF`.
- **Repeat vs one-time shoppers:** 41% of transactions come from repeat customers. I also compared the two groups by age.
- Share of transactions with a discount (`TotalAmount − SaleAmount > 0`).
- **Three Pareto analyses** for campaign targeting:
  - top customers by revenue
  - the locations that make up 80% of revenue: **Chennai, Mumbai and Bengaluru**
  - the stores behind more than 70% of revenue, led by **Store 14, Store 2 and Store 28**
- Revenue and customers by age band. The **50+ group brings in 54%** of sampled revenue.
- Weekend spend: Saturday is well ahead of Sunday.

## 3 · Power BI dashboard (3 pages)
| Page | What's on it |
|---|---|
| **Overview** | Sales by store, a daily sales trend, sales by gender, purchases by age group, a location funnel and net spend by department |
| **Sales & Customer Metrics** | KPI cards (transactions, items, sales, total amount, total discount, average discount, distinct customers), total vs sale amount, items by location, and a treemap of sales by location |
| **Department Spend Breakdown** | Spend for each of the four departments (cards, funnel, pie), department spend by age group, location and gender, and minimum spend |

Every page has the same slicer panel (year, month, week, location, store, age, gender, customer segment), plus page-navigation buttons.

---

## What I'd fix now (2026 review)
- **"Average revenue per customer" (SQL Q5–Q6)** averaged per *transaction*. It should be total sales ÷ distinct customers.
- **Top-3 locations (Q10)** grouped by `Location, SaleAmount`, which breaks the aggregation. It should group by location only and order by the summed share.
- **"Segment contributing maximum sales" (Q13)** used age bands; the question meant `Cust_seg`.
- **Customer_360** is only a schema. The `INSERT … SELECT` with `GROUP BY CustID`, `RANK()` and `NTILE(10)` is missing, and it's the part I'd write first today.
- **Excel Q5** was asked as "revenue from the top 50% of customers" but lists only the top 5. A cumulative-share column would answer it directly. In Q8 the column headers are swapped (revenue vs customer count).
- **Power BI:** "Distinct Customer" uses a count of rows, not `DISTINCTCOUNT`. I'd also add written insights to each page instead of charts alone.

*Dataset provided by AnalytixLabs for the case study. The Excel workbook includes the sample data because the formulas and pivots depend on it.*

---
Part of my portfolio · **[ameer29.github.io](https://ameer29.github.io)** · more 2023 work: [Python case studies](https://github.com/ameer29/analytixlabs-python-case-studies) · [Supply-chain Python case](https://github.com/ameer29/Projects)
