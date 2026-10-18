import pandas as pd
import requests
import pandas as pd
import requests

def get_3months_average_conversion_rates(Data):
    steam_currency = (Data["currency_code_steam_price"])
    country_currency = (Data["currency_code_country"])

    Data["_currency_for_conversion"] = steam_currency.where(steam_currency != "USD",country_currency)

    currencies = (Data["_currency_for_conversion"])
    currencies_to_fetch = [c for c in currencies if c != "USD"]

    end_date = pd.Timestamp.now().normalize()
    start_date = end_date - pd.DateOffset(months=3)

    url = "https://api.frankfurter.dev/v2/rates"

    response = requests.get(url,params={"base": "USD", "from": start_date.strftime("%Y-%m-%d"), "to": end_date.strftime("%Y-%m-%d")}, timeout=60,)
    response.raise_for_status()

    rates = pd.DataFrame(response.json())
    rates["rate"] = pd.to_numeric(rates["rate"], errors="coerce")

    avg_rates = (rates[rates["quote"].isin(currencies_to_fetch)].groupby("quote")["rate"].mean().to_dict())
    avg_rates["USD"] = 1.0

    Data["exchange_rate_USD_currency_regional_price"] = (Data["_currency_for_conversion"].map(avg_rates))
    Data.drop(columns=["_currency_for_conversion"], inplace=True)
    return Data