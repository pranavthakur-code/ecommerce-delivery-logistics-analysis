import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

plt.style.use('seaborn-v0_8-whitegrid')

df_products = pd.read_csv('olist_products_dataset.csv')

df_products['product_category_name'] = df_products['product_category_name'].fillna('Unknown')

numeric_cols = [
    'product_name_lenght', 
    'product_description_lenght', 
    'product_photos_qty', 
    'product_weight_g', 
    'product_length_cm', 
    'product_height_cm', 
    'product_width_cm'
]

for col in numeric_cols:
    mean_value = df_products[col].mean()
    df_products[col] = df_products[col].fillna(mean_value)

df_products.to_csv('olist_products_dataset_cleaned.csv', index=False)

print("--- DataFrame Info ---")
print(df_products.info())

print("\n--- First 5 Rows ---")
print(df_products.head())

print("\n--- Missing Values Check ---")
print(df_products.isnull().sum())

print(f"\nDuplicate Rows: {df_products.duplicated().sum()}")

print("\n--- Statistical Summary ---")
print(df_products.describe())

print(f"\nTotal Unique Products: {df_products['product_id'].nunique()}")
print(f"Total Unique Categories: {df_products['product_category_name'].nunique()}")

plt.figure(figsize=(12, 6))
top_categories = df_products['product_category_name'].value_counts().head(10)
sns.barplot(x=top_categories.values, y=top_categories.index, palette='viridis')
plt.title('Top 10 Product Categories by Count', fontsize=14, fontweight='bold')
plt.xlabel('Number of Products', fontsize=12)
plt.ylabel('Product Category', fontsize=12)
plt.tight_layout()
plt.show()

plt.figure(figsize=(10, 5))
sns.histplot(df_products['product_weight_g'], bins=50, kde=True, color='crimson')
plt.title('Distribution of Product Weight (grams)', fontsize=14, fontweight='bold')
plt.xlabel('Weight (g)', fontsize=12)
plt.ylabel('Frequency', fontsize=12)
plt.xlim(0, 15000)
plt.tight_layout()
plt.show()

plt.figure(figsize=(10, 5))
sns.countplot(x='product_photos_qty', data=df_products, palette='magma')
plt.title('Distribution of Photos Quantity per Product', fontsize=14, fontweight='bold')
plt.xlabel('Number of Photos', fontsize=12)
plt.ylabel('Product Count', fontsize=12)
plt.tight_layout()
plt.show()