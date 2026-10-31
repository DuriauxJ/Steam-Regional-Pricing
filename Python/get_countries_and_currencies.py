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

    # fix to be inline with World Bank PPP data
    countries.loc[countries["iso3"] == "LBR","currency_code_country"] = "USD"

    # fix for the local currency (pegged 1 to 1 to ZAR but babel consider their currency to be ZAR which causes issues with merging)
    countries.loc[countries["iso3"] == "NAM","currency_code_country"] = "NAD"
    countries.loc[countries["iso3"] == "LSO","currency_code_country"] = "LSL"

    # for the purpose of Steam regional pricing, Cyprus is in Europe
    countries.loc[countries["iso3"] == "CYP","continent"] = "Europe"

    return countries