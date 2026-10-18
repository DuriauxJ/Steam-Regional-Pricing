import pandas as pd
import wbgapi as wb

def get_population(df):
    countries = df["iso3"]
    population = wb.data.DataFrame("SP.POP.TOTL", economy=countries, mrnev=1)
    df = df.merge(population, how="outer", left_on="iso3", right_on="economy")
    df.rename(columns={"SP.POP.TOTL":"total_population"}, inplace=True)
    return df