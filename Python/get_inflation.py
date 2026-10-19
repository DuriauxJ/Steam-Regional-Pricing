import pandas as pd
import requests
from datetime import datetime

def get_inflation(df):
    current_year = datetime.now().year
    historical_years = range(current_year - 5, current_year) #doesn't include present year as it is an estimate

    years = list(historical_years) + [current_year]

    url = "https://www.imf.org/external/datamapper/api/v1/PCPIPCH"

    response = requests.get(url,params={"periods": ",".join(map(str, years))},timeout=30)
    response.raise_for_status()

    data = response.json()["values"]["PCPIPCH"]

    inflation = pd.DataFrame.from_dict(data, orient="index")
    inflation.index.name = "iso3"
    inflation.columns = inflation.columns.astype(int)
    inflation = inflation.apply(pd.to_numeric, errors="coerce")

    inflation["inflation_yearly"] = inflation.get(current_year, pd.Series(index=inflation.index, dtype=float))

    inflation["inflation_5_years_average"] = inflation[list(historical_years)].mean(axis=1)

    inflation = inflation[["inflation_yearly", "inflation_5_years_average"]].reset_index()

    df = df.merge(inflation, how="left", on="iso3")

    return df