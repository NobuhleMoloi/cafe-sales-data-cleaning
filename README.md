# Cafe Sales Data Cleaning (SQL)

**Author:** Nobuhle Moloi

## Overview
This project focuses on cleaning and standardising a cafe sales dataset using SQL. The goal is to transform raw, inconsistent data into a structured and analysis-ready format using rule-based transformations.

## Dataset
The dataset used in this project can be found here: [https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training]


---

## Objectives
- Preserve raw data using a staging table  
- Standardise column names  
- Handle invalid and missing values  
- Apply controlled imputation  
- Enforce correct data types  

---

## Cleaning Process

### Data Staging
A staging table was created to avoid modifying the original dataset.

### Column Standardisation
Columns were renamed into a consistent format for readability.

### Data Cleaning
Invalid values (`ERROR`, `UNKNOWN`, blanks) were standardised to either `NULL` or `'Unknown'` depending on context.

### Item Imputation
Missing `item` values were filled using `price_per_unit` only where a one-to-one relationship existed.  
Ambiguous mappings were excluded to avoid incorrect assumptions.

### Numeric Correction
`total_spent` was recalculated using `quantity × price_per_unit` where values were invalid.

### Date Cleaning
`transaction_date` was cleaned and converted from text to DATE format.

### Data Type Enforcement
- `price_per_unit` → DECIMAL  
- `total_spent` → DECIMAL  
- `transaction_date` → DATE  

---

## Data Quality Note
A high frequency of `'Unknown'` values in categorical fields and NULL values in `transaction_date` indicates inconsistencies in data capture.

---

## Recommendation
Implement input validation controls in POS systems and reinforce staff training to ensure accurate transaction recording.

---

## Tools Used
- SQL (MySQL)

---

## Project Status
Completed (Data Cleaning Phase)
