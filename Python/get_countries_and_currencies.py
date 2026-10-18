import pycountry
import pandas as pd
import country_converter as coco
from babel.numbers import get_territory_currencies

def get_countries_and_currencies():
    countries = pd.DataFrame([
        {"country_name": country.name,
        "iso2": country.alpha_2,
        "iso3": country.alpha_3}
        for country in pycountry.countries
    ])
    countries = countries[countries["country_name"] != "Antarctica"]
    countries["currency_code_country"] = countries["iso2"].apply(lambda iso2: get_territory_currencies(iso2))
    countries["currency_code_country"] = countries["currency_code_country"].str[0]

    countries["continent"] = coco.convert(names=countries["iso2"].tolist(),to="continent")

    return countries