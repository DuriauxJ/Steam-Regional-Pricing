import pycountry
import pandas as pd
from babel.numbers import get_territory_currencies

def get_countries_and_currencies():
    countries = pd.DataFrame([
        {"country_name": country.name,
        "iso2": country.alpha_2,
        "iso3": country.alpha_3}
        for country in pycountry.countries
    ])
    countries = countries[countries["country_name"] != "Antarctica"]
    countries["currency_code"] = countries["iso2"].apply(lambda iso2: get_territory_currencies(iso2))
    countries["currency_code"] = countries["currency_code"].str[0]

    for column in ["country_name", "iso2", "iso3", "currency_code"]:
        countries[column] = countries[column].astype("string")
    return countries
df = get_countries_and_currencies()
print(df.info())