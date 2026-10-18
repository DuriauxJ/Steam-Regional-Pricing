import pandas as pd
import numpy as np
import wbgapi as wb

def get_world_bank_data(df):
    countries = df["iso3"]
    wb_data = wb.data.DataFrame(["NY.GDP.MKTP.CD", "NY.ADJ.NNTY.PC.CD","NY.GNP.PCAP.CD","NE.CON.PRVT.CD","PA.NUS.PRVT.PP","IT.NET.BBND.P2","SI.POV.GINI"], economy=countries, time=range(2022, 2027), mrnev=1)
    df = df.merge(wb_data, how="outer", left_on="iso3", right_on="economy")
    df.rename(columns={"NY.GDP.MKTP.CD":"GDP_USD","NY.ADJ.NNTY.PC.CD":"net_national_income_per_capita","NY.GNP.PCAP.CD":"GNI_per_capita","NE.CON.PRVT.CD":"households_final_consumption_expenditure","PA.NUS.PRVT.PP":"PPP_rate_households","IT.NET.BBND.P2":"fixed_broadband_subscriptions_per_100","SI.POV.GINI":"gini_index"}, inplace=True)

    df.loc[df["iso3"] == "HKG","net_national_income_per_capita"] = np.nan #data from 1980, too outdated
    return df