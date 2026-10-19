import pandas as pd
import requests

def EUR_non_eurozone_PPP_fix(df):
    currencies = df["currency_code_country"]
    currencies_to_fetch = [c for c in currencies.dropna().unique()if c != "EUR"]

    end_date = pd.Timestamp.now().normalize()
    start_date = end_date - pd.DateOffset(months=3)

    url = "https://api.frankfurter.dev/v2/rates"

    response = requests.get(url,params={"base": "EUR","from": start_date.strftime("%Y-%m-%d"),"to": end_date.strftime("%Y-%m-%d"),},timeout=60,)
    response.raise_for_status()
    
    rates = pd.DataFrame(response.json())
    rates["rate"] = pd.to_numeric(rates["rate"], errors="coerce")
    
    avg_rates = rates[rates["quote"].isin(currencies_to_fetch)].groupby("quote")["rate"].mean().to_dict()

    exchange_rates = currencies.map(avg_rates)

    df["computed_PPP_price"] = pd.to_numeric(df["computed_PPP_price"], errors="coerce") / exchange_rates

    return df