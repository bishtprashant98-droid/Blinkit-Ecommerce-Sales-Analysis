"""
Blinkit E-Commerce — Python Analysis
Customer cohort retention, delivery-rating correlation, and customer segmentation.
"""

import pandas as pd
import matplotlib.pyplot as plt

# ---------------------------------------------------------
# 1. Load the data
# ---------------------------------------------------------
orders = pd.read_csv('orders.csv')
customers = pd.read_csv('customers.csv')
order_items = pd.read_csv('order_items.csv')
products = pd.read_csv('products.csv')
warehouses = pd.read_csv('warehouses.csv')

# ---------------------------------------------------------
# 2. Clean date columns
# ---------------------------------------------------------
orders['OrderDateTime'] = pd.to_datetime(orders['OrderDateTime'])
customers['SignupDate'] = pd.to_datetime(customers['SignupDate'])

# ---------------------------------------------------------
# 3. Cohort retention analysis
# ---------------------------------------------------------
# First order date per customer defines their cohort month
first_order = orders.groupby('CustomerID')['OrderDateTime'].min()
orders['CohortMonth'] = orders['CustomerID'].map(first_order).dt.to_period('M')
orders['OrderMonth'] = orders['OrderDateTime'].dt.to_period('M')

# Months since first purchase
orders['CohortIndex'] = (orders['OrderMonth'] - orders['CohortMonth']).apply(lambda x: x.n)

# Unique customers active in each cohort month / cohort index
cohort_data = orders.groupby(['CohortMonth', 'CohortIndex'])['CustomerID'].nunique().reset_index()

# Cohort size = customers present at CohortIndex 0
cohort_sizes = cohort_data[cohort_data['CohortIndex'] == 0][['CohortMonth', 'CustomerID']] \
    .rename(columns={'CustomerID': 'CohortSize'})

cohort_data = cohort_data.merge(cohort_sizes, on='CohortMonth')
cohort_data['RetentionPercent'] = round(cohort_data['CustomerID'] / cohort_data['CohortSize'] * 100, 2)

print(cohort_data)

# ---------------------------------------------------------
# 4. Delivery time vs. customer rating correlation
# ---------------------------------------------------------
delivery_rating_corr = orders['DeliveryTimeMinutes'].corr(orders['Rating'])
print(f"Correlation between delivery time and rating: {delivery_rating_corr:.3f}")

# ---------------------------------------------------------
# 5. Customer segmentation by total spend
# ---------------------------------------------------------
customer_spend = orders.groupby('CustomerID')['FinalAmount'].sum().reset_index()
print(customer_spend['FinalAmount'].describe())

customer_spend['Segment'] = pd.cut(
    customer_spend['FinalAmount'],
    bins=[0, 4356, 7847, float('inf')],
    labels=['Low', 'Medium', 'High']
)

print(customer_spend['Segment'].value_counts())

# ---------------------------------------------------------
# 6. Visualization — revenue by customer segment
# ---------------------------------------------------------
customer_spend.groupby('Segment')['FinalAmount'].sum().plot(
    kind='bar',
    color=['#ff6b6b', '#4ecdc4', '#45b7d1']
)
plt.title('Total Revenue by Customer Segment')
plt.xlabel('Segment')
plt.ylabel('Total Revenue (₹)')
plt.tight_layout()
plt.show()
