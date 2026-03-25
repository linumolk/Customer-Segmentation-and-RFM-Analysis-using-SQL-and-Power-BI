# Customer-Segmentation-RFM-Analysis-using-SQL-and-Power-BI

This project focuses on performing Customer Segmentation using RFM (Recency, Frequency, Monetary) Analysis on a retail dataset. 
The goal is to identify high-value customers, understand purchasing behavior, and provide actionable business insights for targeted marketing strategies.

----

## 🎯 Objectives
* Segment customers based on purchasing behavior
* Identify high-value and at-risk customers
* Analyze revenue contribution across segments
* Support data-driven decision making

---

## 🛠️ Tools & Technologies
* MySQL → Data cleaning, transformation, RFM calculation
* Power BI → Data visualization and dashboard creation

---

## 📂 Dataset
Retail transactional dataset (~30K records)
Contains:
1. CustomerID
2. InvoiceNo
3. Quantity
4. InvoiceDate
5. UnitPrice
6. Country

---

## 🔄 Project Workflow

1. Data Preparation (MySQL)
* Imported raw dataset
* Handled missing and blank values
* Removed duplicates
* Fixed inconsistencies (negative values, invalid entries)
* Standardized data types

2. Feature Engineering
* Created Total_Price = Quantity × UnitPrice
* Prepared customer-level aggregation

3. RFM Calculation
* Recency → Days since last purchase
* Frequency → Number of transactions
* Monetary → Total spend

4. RFM Scoring
* Applied NTILE(5) to assign scores (1–5)
* Generated RFM Score (combined)

5. Customer Segmentation

Customers were segmented into:

* Champions → High value, recent, frequent buyers
* Loyal Customers → Regular and consistent buyers
* At Risk → Inactive customers with declining engagement
* Low Value → Remaining customers

---

## 📊 Dashboard Creation (Power BI) :

Key Visuals:

1. KPI Cards (Total Customers, Revenue, Avg Metrics)
2. Customers by Segment
3. Revenue by Segment
4. Segment-wise Behavior Analysis
5. RFM Distribution
7. Top 5 Customers
8. Customer vs Revenue Comparison (Combo Chart)
9. Segment Filter (Slicer)


## Dashboard Preview : 
![RFM_Dashboard}(RFM_Analysis_Dashboard.png).

--- 

## 📈 Key Insights
* A small group of customers (Champions) contributes a significant portion of total revenue
* Loyal customers form a stable revenue base with consistent purchases
* A noticeable segment of customers is at risk, indicating retention opportunities
* Customer behavior varies significantly across segments, enabling targeted marketing strategies

--- 

## 💡 Business Recommendations
* Focus marketing efforts on retaining Champions
* Upsell and cross-sell to Loyal customers
* Re-engage At Risk customers through targeted campaigns
* Personalize offers based on segment behavior

---

##🚀 Conclusion

This project demonstrates how RFM analysis can effectively segment customers and provide valuable insights into 
customer behavior, helping businesses optimize marketing strategies and improve revenue.
