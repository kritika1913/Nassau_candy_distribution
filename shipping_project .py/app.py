import streamlit as st
import pandas as pd
import plotly.express as px

# -----------------------------------
# PAGE SETTINGS
# -----------------------------------

st.set_page_config(
    page_title="Nassau Candy Dashboard",
    layout="wide"
)

st.title("Factory-to-Customer Shipping Route Efficiency Analysis")

# -----------------------------------
# LOAD DATA
# -----------------------------------

df = pd.read_csv("Nassau Candy Distributor.csv")

# -----------------------------------
# DATE CONVERSION
# -----------------------------------

df['Order Date'] = pd.to_datetime(
    df['Order Date'],
    errors='coerce'
)

df['Ship Date'] = pd.to_datetime(
    df['Ship Date'],
    errors='coerce'
)

# -----------------------------------
# SHIPPING LEAD TIME
# -----------------------------------

df['Shipping Lead Time'] = (
    df['Ship Date'] - df['Order Date']
).dt.days

# -----------------------------------
# SIDEBAR FILTERS
# -----------------------------------

st.sidebar.header("Filters")

selected_region = st.sidebar.multiselect(
    "Select Region",
    options=df['Region'].unique(),
    default=df['Region'].unique()
)

selected_ship_mode = st.sidebar.multiselect(
    "Select Ship Mode",
    options=df['Ship Mode'].unique(),
    default=df['Ship Mode'].unique()
)

filtered_df = df[
    (df['Region'].isin(selected_region)) &
    (df['Ship Mode'].isin(selected_ship_mode))
]

# -----------------------------------
# KPI CALCULATIONS
# -----------------------------------

total_sales = round(filtered_df['Sales'].sum(), 2)

total_profit = round(filtered_df['Gross Profit'].sum(), 2)

total_orders = filtered_df['Order ID'].nunique()

avg_lead_time = round(
    filtered_df['Shipping Lead Time'].mean(),
    2
)

# -----------------------------------
# KPI CARDS
# -----------------------------------

col1, col2, col3, col4 = st.columns(4)

col1.metric("Total Sales", f"${total_sales}")

col2.metric("Total Profit", f"${total_profit}")

col3.metric("Total Orders", total_orders)

col4.metric("Avg Lead Time", f"{avg_lead_time} Days")

# -----------------------------------
# REGION BAR CHART
# -----------------------------------

st.subheader("Average Lead Time by Region")

region_data = filtered_df.groupby(
    'Region'
)['Shipping Lead Time'].mean().reset_index()

fig1 = px.bar(
    region_data,
    x='Region',
    y='Shipping Lead Time',
    color='Region'
)

st.plotly_chart(fig1, use_container_width=True)

# -----------------------------------
# SHIP MODE PIE CHART
# -----------------------------------

st.subheader("Ship Mode Distribution")

fig2 = px.pie(
    filtered_df,
    names='Ship Mode'
)

st.plotly_chart(fig2, use_container_width=True)

# -----------------------------------
# MONTHLY SALES TREND
# -----------------------------------

filtered_df['Month'] = filtered_df['Order Date'].dt.strftime('%b')

monthly_sales = filtered_df.groupby(
    'Month'
)['Sales'].sum().reset_index()

st.subheader("Monthly Sales Trend")

fig3 = px.line(
    monthly_sales,
    x='Month',
    y='Sales',
    markers=True
)

st.plotly_chart(fig3, use_container_width=True)

# -----------------------------------
# STATE PERFORMANCE
# -----------------------------------

st.subheader("State Shipping Performance")

state_data = filtered_df.groupby(
    'State/Province'
)['Shipping Lead Time'].mean().reset_index()

fig4 = px.bar(
    state_data,
    x='State/Province',
    y='Shipping Lead Time',
    color='Shipping Lead Time'
)

st.plotly_chart(fig4, use_container_width=True)

# -----------------------------------
# DATA TABLE
# -----------------------------------

st.subheader("Shipment Details")

st.dataframe(filtered_df.head(100))