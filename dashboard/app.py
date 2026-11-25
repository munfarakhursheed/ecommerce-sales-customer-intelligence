
import streamlit as st
import pandas as pd
import plotly.express as px
from pathlib import Path
st.set_page_config(page_title="NovaCart | E-commerce Intelligence",layout="wide")
ROOT=Path(__file__).resolve().parents[1]
@st.cache_data
def load():
    d={}
    for f in ["customers","products","sellers","orders","order_items","payments","reviews"]:
        d[f]=pd.read_csv(ROOT/"data"/f"{f}.csv")
    d["orders"]["order_date"]=pd.to_datetime(d["orders"]["order_date"])
    d["order_items"]=d["order_items"].merge(d["products"][["product_id","category"]],on="product_id")
    d["order_items"]=d["order_items"].merge(d["orders"][["order_id","order_status","customer_id","order_date"]],on="order_id")
    return d
d=load(); orders=d["orders"]; items=d["order_items"]
st.title("NovaCart | E-commerce Sales & Customer Intelligence")
st.caption("Portfolio demonstration using synthetic data. Not actual company performance.")
min_d,max_d=orders.order_date.min().date(),orders.order_date.max().date()
dates=st.sidebar.date_input("Order date range",(min_d,max_d),min_value=min_d,max_value=max_d)
if isinstance(dates,tuple) and len(dates)==2:
    o=orders[(orders.order_date.dt.date>=dates[0])&(orders.order_date.dt.date<=dates[1])]
else: o=orders.copy()
valid=o[o.order_status=="delivered"]
it=items[items.order_id.isin(valid.order_id)]
rev=it.gross_revenue.sum(); profit=it.gross_profit.sum()
c1,c2,c3,c4=st.columns(4)
c1.metric("Delivered orders",f"{valid.order_id.nunique():,}")
c2.metric("Gross revenue",f"₹ {rev:,.0f}")
c3.metric("Gross profit*",f"₹ {profit:,.0f}")
c4.metric("Average order value",f"₹ {rev/max(valid.order_id.nunique(),1):,.2f}")
st.caption("*Illustrative contribution after product cost and item-level freight; excludes overhead, marketing and tax.")
a,b=st.columns(2)
monthly=it.groupby(it.order_date.dt.to_period("M").astype(str)).gross_revenue.sum().reset_index(name="revenue")
a.plotly_chart(px.line(monthly,x="order_date",y="revenue",markers=True,title="Monthly revenue"),use_container_width=True)
cat=it.groupby("category").gross_revenue.sum().reset_index().sort_values("gross_revenue",ascending=False)
b.plotly_chart(px.bar(cat,x="category",y="gross_revenue",title="Revenue by category"),use_container_width=True)
c,dcol=st.columns(2)
cust=o.merge(d["customers"],on="customer_id")
region=cust[cust.order_status=="delivered"].groupby("region").size().reset_index(name="orders")
c.plotly_chart(px.bar(region,x="region",y="orders",title="Delivered orders by region"),use_container_width=True)
delivery=valid.copy()
delivery["delivery_group"]=delivery.delivered_on_time.map({1:"On time",0:"Late"})
dcol.plotly_chart(px.histogram(delivery,x="delivery_days",color="delivery_group",title="Delivery time distribution"),use_container_width=True)
st.subheader("Category profitability")
margin=it.groupby("category").agg(revenue=("gross_revenue","sum"),profit=("gross_profit","sum")).reset_index()
margin["margin_pct"]=100*margin.profit/margin.revenue
st.dataframe(margin.style.format({"revenue":"₹ {:,.2f}","profit":"₹ {:,.2f}","margin_pct":"{:.1f}%"}),use_container_width=True)
