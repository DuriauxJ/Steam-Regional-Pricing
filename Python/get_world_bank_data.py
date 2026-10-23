import pandas as pd
import numpy as np
import wbgapi as wb

def get_world_bank_data(df):
    countries = df["iso3"]
    wb_data = wb.data.DataFrame(["NY.GDP.MKTP.CD", "NY.ADJ.NNTY.PC.CD","NY.GNP.PCAP.CD","NE.CON.PRVT.CD","PA.NUS.PRVT.PP","IT.NET.BBND.P2","SI.POV.GINI","IT.NET.USER.ZS"], economy=countries, time=range(2022, 2027), mrnev=1)
    df = df.merge(wb_data, how="outer", left_on="iso3", right_on="economy")
    df.rename(columns={"NY.GDP.MKTP.CD":"GDP_USD","NY.ADJ.NNTY.PC.CD":"net_national_income_per_capita","NY.GNP.PCAP.CD":"GNI_per_capita","NE.CON.PRVT.CD":"households_final_consumption_expenditure","PA.NUS.PRVT.PP":"PPP_rate_households","IT.NET.BBND.P2":"fixed_broadband_subscriptions_per_100","SI.POV.GINI":"gini_index","IT.NET.USER.ZS":"percent_using_internet"}, inplace=True)

    #income-group not available directly
    economies = wb.economy.DataFrame()
    income = economies.reset_index()
    if "economy" not in income.columns:
        income = income.rename(columns={income.columns[0]: "economy"})

    income_col = next((col for col in income.columns if col.lower() in {"income", "incomelevel", "income_level"}),None)

    income = income[["economy", income_col]].rename(columns={"economy": "iso3", income_col: "income_classification",})
    income_mapping = {"LIC": "Low income", "LMC": "Lower middle income", "UMC": "Upper middle income", "HIC": "High income",}
    income["income_classification"] = income["income_classification"].map(income_mapping)
    df = df.merge(income, on="iso3", how="left")

    #remove very low quality datas
    df.loc[df["iso3"] == "HKG","net_national_income_per_capita"] = np.nan #data from 1980, too outdated
    df.loc[df["iso3"] == "VEN","PPP_rate_households"] = np.nan #data from 2011, = 0
    return df