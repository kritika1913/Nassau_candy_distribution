import streamlit as st
import pandas as pd
import plotly.express as px


# ------------------------------------------------
# PAGE SETTINGS
# ------------------------------------------------

st.set_page_config(
    page_title="Shipping Route Efficiency Dashboard",
    layout="wide"
)

st.title("Factory-to-Customer Shipping Route Efficiency Analysis")


# ------------------------------------------------
# LOAD DATA
# ------------------------------------------------

df = pd.read_csv("nassau_shipping.csv")


# ------------------------------------------------
# CONVERT DATES
# ------------------------------------------------

df['order_date'] = pd.to_datetime(df['order_date'])
df['shipping_date'] = pd.to_datetime(df['shipping_date'])


# ------------------------------------------------
# CREATE SHIPPING LEAD TIME
# ------------------------------------------------

df['shipping_lead_time'] = (
    df['shipping_date'] - df['order_date']
).dt.days


# ------------------------------------------------
# KPI CALCULATIONS
# ------------------------------------------------

total_sales = round(df['Sales'].sum(), 2)

total_profit = round(df['gross_profit'].sum(), 2)

total_orders = df['Order ID'].nunique()

avg_lead_time = round(
    df['shipping_lead_time'].mean(), 2
)

delay_frequency = round(
    (df['shipping_lead_time'] > 5).mean() * 100,
    2
)


# ------------------------------------------------
# SIDEBAR FILTERS
# ------------------------------------------------

st.sidebar.header("Filters")

selected_region = st.sidebar.multiselect(
    "Select Region",
    df['Region'].unique(),
    default=df['Region'].unique()
)

selected_ship_mode = st.sidebar.multiselect(
    "Ship Mode",
    df['Ship Mode'].unique(),
    default=df['Ship Mode'].unique()
)


# ------------------------------------------------
# FILTER DATA
# ------------------------------------------------

filtered_df = df[
    (df['Region'].isin(selected_region)) &
    (df['Ship Mode'].isin(selected_ship_mode))
]


# ------------------------------------------------
# KPI CARDS
# ------------------------------------------------

col1, col2, col3, col4, col5 = st.columns(5)

col1.metric("Total Sales", f"${total_sales}")

col2.metric("Total Profit", f"${total_profit}")

col3.metric("Total Orders", total_orders)

col4.metric("Avg Lead Time", f"{avg_lead_time} Days")

col5.metric("Delay Frequency", f"{delay_frequency}%")


# ------------------------------------------------
# BAR CHART
# ------------------------------------------------

st.subheader("Average Shipping Lead Time by Region")

region_perf = filtered_df.groupby(
    'Region'
)['shipping_lead_time'].mean().reset_index()

fig1 = px.bar(
    region_perf,
    x='Region',
    y='shipping_lead_time',
    color='Region'
)

st.plotly_chart(fig1, use_container_width=True)


# ------------------------------------------------
# PIE CHART
# ------------------------------------------------

st.subheader("Ship Mode Distribution")

fig2 = px.pie(
    filtered_df,
    names='Ship Mode'
)

st.plotly_chart(fig2, use_container_width=True)


# ------------------------------------------------
# MONTHLY SALES TREND
# ------------------------------------------------

st.subheader("Monthly Sales Trend")

filtered_df['Month'] = filtered_df[
    'order_date'
].dt.strftime('%b')

monthly_sales = filtered_df.groupby(
    'Month'
)['Sales'].sum().reset_index()

fig3 = px.line(
    monthly_sales,
    x='Month',
    y='Sales',
    markers=True
)

st.plotly_chart(fig3, use_container_width=True)


# ------------------------------------------------
# STATE PERFORMANCE
# ------------------------------------------------

st.subheader("State-Level Shipping Performance")

state_perf = filtered_df.groupby(
    'State/province'
)['shipping_lead_time'].mean().reset_index()

fig4 = px.bar(
    state_perf,
    x='State/province',
    y='shipping_lead_time',
    color='shipping_lead_time'
)

st.plotly_chart(fig4, use_container_width=True)


# ------------------------------------------------
# DETAILED TABLE
# ------------------------------------------------

st.subheader("Shipment Details")

st.dataframe(filtered_df.head(100))