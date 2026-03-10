# Project Overview

This project demonstrates an end-to-end analytics pipeline built using Python, PostgreSQL, Docker, SQL, and Power BI.

The goal is to simulate a realistic Business Intelligence workflow used in commercial analytics environments.

The project ingests raw e-commerce data, transforms it into a dimensional warehouse model, and delivers a multi-page Power BI dashboard for business decision support.

---

## Key Features

• Python-based data ingestion pipeline  
• PostgreSQL data warehouse running in Docker  
• SQL transformation layer (raw → staging → mart)  
• Star schema dimensional model  
• Commercial KPI calculations  
• Data quality validation checks  
• Power BI semantic model and dashboard  

---

## Business Questions Answered

The dashboard supports analysis of:

• Revenue and profit trends  
• Product category performance  
• Geographic sales distribution  
• Customer value segmentation  
• Average order value and purchasing behaviour  

---

## Technologies Used

Python  
PostgreSQL  
Docker  
SQL  
Power BI  
GitHub

---

## Dataset

This project uses the **Olist Brazilian E-Commerce dataset** from Kaggle.

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains roughly:

• 99k orders  
• 112k order items  
• 32k products  

spanning the years **2016–2018**.

---

## Outcome

The result is a fully reproducible analytics environment capable of rebuilding the warehouse from scratch using the included rebuild script.