library(quantmod)

Data <- read.csv("C:/Users/User/Desktop/Steam Regional Pricing/R/temp.csv")

START_DATE <- Sys.Date()
END_DATE <- seq(START_DATE, length = 2, by = "-3 months")[2]

Yahoo_Symbols <- paste0(Data$currency_code_steam, "USD=X")

#taux change entre  START_DATE et END_DATE, source:yahoo
for (i in 1:nrow(Data)) {
  if(Yahoo_Symbols[i] != "USDUSD=X"){
    symbol <- getSymbols(Yahoo_Symbols[i], src = "yahoo", from = START_DATE, to = END_DATE, auto.assign = TRUE)
    rate_series <- list()
    rate_series <- get(symbol) 
    Data$USD_regional_price_currency_exchange_rate[i] <- mean(rate_series[,1]) 
  }
  else{
    Data$USD_regional_price_currency_exchange_rate[i]  <- 1
  }
}
rm(list=Yahoo_Symbols)

symbol <- getSymbols("EURUSD=X", src = "yahoo", from = START_DATE, to = END_DATE, verbose = TRUE,auto.assign = TRUE)
rate_series <- list()
rate_series <- get(symbol) 
print(mean(rate_series[,1]))