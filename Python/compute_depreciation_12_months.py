import pandas as pd
import requests


def compute_depreciation_12_months(df):
    currencies = df["currency_code_country"]
    currencies_to_fetch = [c for c in currencies.dropna().unique() if c != "USD"]

    end_date = pd.Timestamp.now().normalize()
    start_date = end_date - pd.DateOffset(months=12)

    url = "https://api.frankfurter.dev/v2/rates"

    response = requests.get(url,params={"base": "USD","from": (start_date - pd.Timedelta(days=6)).strftime("%Y-%m-%d"),"to": end_date.strftime("%Y-%m-%d"),},timeout=60,)
    response.raise_for_status()

    rates = pd.DataFrame(response.json())
    rates["date"] = pd.to_datetime(rates["date"])
    rates["rate"] = pd.to_numeric(rates["rate"], errors="coerce")

    rates = rates[rates["quote"].isin(currencies_to_fetch)]

    start_avg = rates[(rates["date"] >= start_date - pd.Timedelta(days=6)) & (rates["date"] <= start_date)].groupby("quote")["rate"].mean()
    end_avg = rates[(rates["date"] >= end_date - pd.Timedelta(days=6)) & (rates["date"] <= end_date)].groupby("quote")["rate"].mean()

    FX_12_months_ago = currencies.map(start_avg)
    FX_current = currencies.map(end_avg)

    FX_12_months_ago = FX_12_months_ago.where(currencies != "USD", 1.0)
    FX_current = FX_current.where(currencies != "USD", 1.0)

    df["FX_Depreciation_12_months_USD"] = ((FX_current - FX_12_months_ago) / FX_12_months_ago).where(FX_12_months_ago != 0)
    
    return df
