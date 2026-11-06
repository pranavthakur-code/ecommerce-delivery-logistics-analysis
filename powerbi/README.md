# Olist E-Commerce Dashboard (Power BI)

An interactive Power BI dashboard analysing the Brazilian Olist e-commerce dataset. It covers revenue, orders, product categories, payment behaviour and order status.

![Dashboard](Screenshot%202026-11-06%20172756.png)

## Project Overview

| Item | Details |
|---|---|
| Tool | Microsoft Power BI Desktop |
| Dataset | Olist Brazilian E-Commerce (orders, items, payments, products, sellers, geolocation) |
| Type | Group project |
| Team | *Add team member names here* |
| Institution | SRM Institute of Science and Technology, Delhi NCR Campus |

## Objectives

- Build a clean data model linking the Olist tables.
- Create DAX measures for key business metrics.
- Present revenue, order, category and payment trends in one interactive dashboard.
- Let users filter the report by order status.

## Data Model

Relationships are all **Many-to-One, single direction**:

| From (many) | To (one) | Key |
|---|---|---|
| olist_order_items_dataset | olist_orders_cleaned | order_id |
| olist_order_payments_dataset | olist_orders_cleaned | order_id |
| olist_order_items_dataset | olist_products_dataset_cleaned | product_id |
| olist_order_items_dataset | olist_sellers_dataset | seller_id |

`olist_geolocation_dataset` is kept unconnected, because zip-code prefixes repeat and would create many-to-many relationships.

## DAX Measures

```DAX
Total Revenue = SUM(olist_order_items_dataset[price])
Total Orders = DISTINCTCOUNT(olist_orders_cleaned[order_id])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
Total Freight = SUM(olist_order_items_dataset[freight_value])
Payment Orders = DISTINCTCOUNT(olist_order_payments_dataset[order_id])
```

`Payment Orders` is used for the donut chart because the payments table sits on the "many" side of its relationship, so `Total Orders` would not split by payment type.

## Dashboard Components

| Visual | Fields | Purpose |
|---|---|---|
| Cards | Total Revenue, Total Orders, Avg Order Value, Total Freight | Headline KPIs |
| Line chart | purchase_month, Total Revenue | Revenue trend by month |
| Bar chart | product_category_name, Total Revenue (Top 10 filter) | Best-performing categories |
| Donut chart | payment_type, Payment Orders | Payment method share |
| Slicer | order_status | Filter the whole page |

## Key Insights

1. **Overall performance:** The business generated about **13.59M** in revenue from roughly **99K orders**, an average order value of about **136.68**. Freight cost totals about **2.25M**, which is around 17% of revenue.
2. **Top categories:** Revenue is led by `beleza_saude` (health and beauty), `relogios_presentes` (watches and gifts), `cama_mesa_banho` (bed, bath and table), `esporte_lazer` (sports and leisure) and `informatica_acessorios` (computer accessories). Revenue is spread across many categories, with no single category dominating.
3. **Payment behaviour:** Credit card is by far the most used payment method (about **75%** of orders), followed by boleto (about **19%**). Voucher, debit card and undefined types together make up a small share.
4. **Revenue trend:** Monthly revenue climbs through the first half of the year and peaks around months 5 to 8. It then falls sharply in months 9 and 10 before a partial recovery. The months are summed across years, and the dataset does not cover every month of every year, so the late-year dip partly reflects missing data rather than a real drop in sales.
5. **Order status:** The slicer lets users compare delivered, shipped, cancelled and other statuses. Most orders are delivered.

## Recommendations

- Focus marketing and stock on the top categories, which drive the most revenue.
- Offer instalment or credit card promotions, since most customers pay by card.
- Review freight cost per order, since it is a sizeable share of revenue.
- Use a complete multi-year date range before drawing seasonality conclusions.

## How to Use

1. Install [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free, Windows only).
2. Download `Olist_Dashboard.pbix` from this repository.
3. Open it in Power BI Desktop. If it asks for the data, point it to the Olist CSV files.
4. Use the **order_status** slicer to explore the data.

## Repository Structure

```
├── Olist_Dashboard.pbix
├── README.md
└── images/
    └── dashboard.png
```

## Dataset Source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle. Please download the CSV files from there.


