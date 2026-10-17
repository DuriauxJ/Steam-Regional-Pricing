install.packages("quantmod")
install.packages("tmap")

library(quantmod)
library(tmap)

#pour simplifier: 
#seul Turquie et Egypte  pris en compte pour zone MENA
#Argentine pour zone LATAM
#Pakistan et Bangladesh pour zone South Asia
#Ouzbekistan pour zone CIS
#Hong Kong et Taiwan non-inclus (pas inclus par la Banque Mondiale)

#données entrées à la main, !!!ENTRER BON CHEMIN MENANT AU FICHIER!!!
Data <- read.csv("C:/Users/User/Desktop/Tarification_régionale/JoakimDuriaux_TarificationRégionaleSteam.csv")

#dates pour calculer taux d'échange moyen
START_DATE <- "2025-9-14"
END_DATE <- "2025-12-14"

#--------------------calcul taux d'échange moyen sur 3 mois--------------------
#formatage pour recherche taux change
Yahoo_Symbols <- paste0(Data[,2], "USD=X")

#taux change entre  START_DATE et END_DATE, source:yahoo
for (i in 1:nrow(Data)) {
  if(Yahoo_Symbols[i] != "USDUSD=X"){
    symbol <- getSymbols(Yahoo_Symbols[i], src = "yahoo", from = START_DATE, to = END_DATE, auto.assign = TRUE)
    rate_series <- list()
    rate_series <- get(symbol) 
    Data[i,4] <- mean(rate_series[,1]) 
  }
  else{
    Data[i,4] <- 1
 }
}
rm(list=Yahoo_Symbols)

#--------------------conversion prix recommandé--------------------
#conversion monnaie locale à USD
for(i in 1:nrow(Data)){
  Data[i,5] <- Data[i,3] * Data[i,4] 
}

#conversion inverse pour région utilisant USD plutôt que monnaie locale
Yahoo_Symbols_Reverse <- c("USDUZS=X","USDARS=X","USDTRY=X","USDEGP=X","USDPKR=X","USDBDT=X")
for (i in 1:length(Yahoo_Symbols_Reverse)) {
  getSymbols(Yahoo_Symbols_Reverse[i], src = "yahoo", from = START_DATE, to = END_DATE, auto.assign = TRUE)
  rate_series <- get(Yahoo_Symbols_Reverse[i]) 
  avg_rate <- mean(rate_series[,1])  
  Data[40+i,3] <- Data[40+i,5] * avg_rate
}
rm(list=Yahoo_Symbols_Reverse)

#--------------------calcul Affordability (prix recommandé/salaire net moyen)--------------------
for(i in 1:nrow(Data)){
  Data[i,9] <- Data[i,5] / Data[i,6] 
}

#--------------------calcul prix "juste" PPP--------------------
for(i in 1:nrow(Data)){
  Data[i,10] <- 69.99 * Data[i,8] 
}

#--------------------calcul difference % prix "juste" PPP et prix effectif--------------------
for(i in 1:nrow(Data)){
  Data[i,11] <- (Data[i,3]-Data[i,10])/Data[i,10]
}

#--------------------représentations graphiques--------------------

plot(Data[,6],Data[,5],ylim=c(0,90),
     main = "Prix recommandé en fonction du salaire mensuel",
     xlab = "Salaire mensuel net moyen (USD)",
     ylab = "Prix recommandé (USD)",
     pch = 20, 
     col = 1)
lines(lowess(Data[, 6], Data[, 5]), col = 2, lwd = 2)
abline(h=69.99,lty = 2)
points(Data[3, 6], Data[3, 5],
       col = "purple",
       pch = 19,
       cex = 1.3)
points(Data[4:9, 6], Data[4:9, 5],
       col = "blue",
       pch = 19,
       cex = 1.3)

plot(Data[,6],Data[,9],ylim=c(0,0.25),
     main = "Abordabilité en fonction du salaire mensuel",
     xlab = "Salaire mensuel net moyen (USD)",
     ylab = "Prix recommandé / salaire mensuel",
     pch = 20, 
     col = 1)
lines(lowess(Data[, 6], Data[, 9]), col = 2, lwd = 2)
abline(h=0.016373883,lty = 2)
points(Data[43:44, 6], Data[43:44, 9],
       col = "#e69a30",
       pch = 19,
       cex = 1.3)
points(Data[4:9, 6], Data[4:9, 9],
       col = "blue",
       pch = 19,
       cex = 1.3)



plot(log(Data[,6]),log(Data[,9]),
     main = "Abordabilité en fonction du salaire mensuel (échelle logarithmique)",
     xlab = "Salaire mensuel net moyen (USD, log)",
     ylab = "Prix recommandé / salaire mensuel (log)",
     pch = 20, 
     col = 1)
lines(lowess(log(Data[, 6]), log(Data[, 9])), col = 2, lwd = 2)
abline(h=log(0.016373883),lty = 2)
points(log(Data[43:44, 6]), log(Data[43:44, 9]),
       col = "#e69a30",
       pch = 19,
       cex = 1.3)
points(log(Data[4:9, 6]), log(Data[4:9, 9]),
       col = "blue",
       pch = 19,
       cex = 1.3)

plot(Data[,7],Data[,5],ylim=c(0,90),
     main = "Prix recommandé en fonction du revenu national net par habitant",
     xlab = "Revenu national net par habitant (USD, 2021)",
     ylab = "Prix recommandé (USD)",
     pch = 20, 
     col = 1)
lines(lowess(Data[, 7], Data[, 5]), col = 2, lwd = 2)
abline(h=69.99,lty = 2)

plot(Data[,6],Data[,11],
     main = "Écart relatif entre prix recommandé et prix théorique PPP",
     xlab = "Salaire mensuel net moyen (USD)",
     ylab = "écart relatif prix recommandé - prix PPP",
     pch = 20, 
     col = 1)
lines(lowess(Data[,6], Data[, 11]), col = 2, lwd = 2)
abline(h=0,lty = 2)

mean(Data[,11]) #écart prix recommandé et prix théorique PPP moyen



Data_sorted <- Data[order(Data[, 11], decreasing = TRUE), ]
Data_sorted[,1] <- c("Égypte (MENA)", "Pologne", "Inde", "Portugal (EUR)", "Thaïlande", "Turquie (MENA)", "Espagne (EUR)", "Vietnam", "Ouzbékistan (CIS)", "Ukraine", "Argentine (LATAM)", "Italie (EUR)", "Indonésie", "Malaisie", "Kazakhstan", "Philippines", "Colombie", "France (EUR)", "Pakistan (SASIA)", "Allemagne (EUR)", "Bangladesh (SASIA)", "Corée du Sud", "Costa Rica", "Royaume-Uni", "Norvège", "Luxembourg (EUR)", "Japon", "Canada", "Afrique du Sud", "Russie", "Émirats arabes unis", "Brésil", "Pérou", "Uruguay", "Australie", "Singapour", "Israël", "Chili", "Suisse", "Mexique", "Arabie saoudite", "États-Unis", "Nouvelle-Zélande", "Chine", "Qatar", "Koweït")
bar_colors <- ifelse(Data_sorted[, 11] > 0, "darkred", "darkgreen")
barplot(Data_sorted[, 11], 
        names.arg = Data_sorted[, 1], 
        main = "Écart relatif entre prix recommandé et prix théorique PPP",
        ylab = "écart relatif prix recommandé - prix PPP)",
        xlab = "",
        col = bar_colors,
        las = 2, 
        cex.names = 0.5) 
abline(h = 0, col = "black", lty = 1, lwd = 1.5)
abline(h = 0.3674228, col = "black", lty = 2, lwd = 1.5)

#--------------------carte 1--------------------
data("World")
World <- World[World$continent != "Antarctica", ]


eurozone_list <- c("Austria", "Belgium", "Croatia", "Cyprus", "Estonia", "Finland", "France", "Germany", "Greece", "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Portugal", "Slovakia", "Slovenia", "Spain")
#pays européen n'ayant pas leur propre tarification utilise prix en euro
EUR_non_eurozone <- c("Greenland", "Iceland", "Denmark", "Sweden", "Czechia", "Hungary", "Romania", "Bosnia and Herz.", "Serbia", "Kosovo", "Montenegro", "Albania", "North Macedonia", "Bulgaria")


CIS_list <- c("Armenia", "Azerbaijan", "Belarus", "Georgia", "Kyrgyzstan", "Moldova", "Tajikistan", "Uzbekistan")
LATAM_list <- c("Belize", "El Salvador", "Guatemala", "Honduras", "Nicaragua", "Panama", "Argentina", "Bolivia", "Ecuador", "Guyana", "Paraguay", "Suriname", "Venezuela")
MENA_list <- c("Bahrain", "Egypt", "Iraq", "Jordan", "Lebanon", "Oman", "State of Palestine", "Turkey", "Yemen", "Algeria", "Libya", "Morocco", "Tunisia", "Sudan")
SASIA_list <- c("Bangladesh", "Bhutan", "Nepal", "Pakistan", "Sri Lanka")
RegionalCurrency_list <- c("Switzerland", "Israel", "Poland", "Norway", "United Kingdom", "Mexico", "Peru", "South Africa", "Singapore", "Colombia", "Australia", "Ukraine", "United Arab Emirates", "Brazil", "Costa Rica", "New Zealand", "Saudi Arabia", "Chile", "Uruguay", "Kuwait", "Qatar", "Canada", "Japan", "Malaysia", "South Korea", "Thailand", "Kazakhstan", "Philippines", "Indonesia", "Vietnam", "India", "China", "Russia", "Taiwan", "Hong Kong")
Baseline <- c("United States of America")

World$Pricing_Model <- "Pas de tarification régionale (Prix de base, USD)"
World$Pricing_Model[World$name %in% eurozone_list] <- "Eurozone (EUR)"
World$Pricing_Model[World$name %in% EUR_non_eurozone] <- "Prix Eurozone (non-Eurozone, EUR)"
World$Pricing_Model[World$name %in% CIS_list] <- "CIS (USD)"
World$Pricing_Model[World$name %in% LATAM_list] <- "LATAM (USD)"
World$Pricing_Model[World$name %in% MENA_list] <- "MENA (USD)"
World$Pricing_Model[World$name %in% SASIA_list] <- "South Asia (USD)"
World$Pricing_Model[World$name %in% RegionalCurrency_list] <- "Tarification régionale dans la monnaie locale"
World$Pricing_Model[World$name == "United States of America"] <- "Prix de base (USA, USD)"

custom_palette <- c(
  "Prix de base (USA, USD)" = "#ba4c66",
  "Eurozone (EUR)" = "#36abd6",
  "Prix Eurozone (non-Eurozone, EUR)" = "#216296",
  "Tarification régionale dans la monnaie locale" = "#006400",     
  "CIS (USD)" = "#FFD700",    
  "LATAM (USD)" = "#e0aa36",    
  "MENA (USD)" = "#e69a30",      
  "South Asia (USD)" = "#c96b34",   
  "Pas de tarification régionale (Prix de base, USD)" = "#FF0000" 
)

legend_order <- c("Prix de base (USA, USD)", "Eurozone (EUR)", "Prix Eurozone (non-Eurozone, EUR)", 
                  "Tarification régionale dans la monnaie locale", "CIS (USD)", "LATAM (USD)", 
                  "MENA (USD)", "South Asia (USD)")
World$Pricing_Model <- factor(World$Pricing_Model, levels = legend_order)

tm_shape(World) +
  tm_polygons("Pricing_Model", 
              title = "Régime de tarification de Steam",
              palette = custom_palette,
              colorNA = "#FF0000", #!!! pas un vrai NA
              textNA = "Pas de tarification régionale (Prix de base, USD)",
              border.col = "black", 
              lwd = 1,
              ) +
  tm_layout(legend.outside = TRUE, frame = TRUE, legend.outside = FALSE,legend.position = c("left", "bottom"), na.show=FALSE)

#--------------------carte 2--------------------
data("World")
World <- World[World$continent != "Antarctica", ]

eurozone_list <- c("France", "Germany", "Italy", "Luxembourg", "Portugal", "Spain")
CIS_list <- "Uzbekistan"
LATAM_list <- "Argentina"
MENA_list <- c("Egypt", "Turkey")
SASIA_list <- c("Bangladesh", "Pakistan")
RegionalCurrency_list <- c("Switzerland", "Israel", "Poland", "Norway", "United Kingdom", "Mexico", "Peru", "South Africa", "Singapore", "Colombia", "Australia", "Ukraine", "United Arab Emirates", "Brazil", "Costa Rica", "New Zealand", "Saudi Arabia", "Chile", "Uruguay", "Kuwait", "Qatar", "Canada", "Japan", "Malaysia", "South Korea", "Thailand", "Kazakhstan", "Philippines", "Indonesia", "Vietnam", "India", "China", "Russia", "Taiwan", "Hong Kong")
Baseline <- c("United States of America")

World$Pricing_Model <- "Pas considéré"
World$Pricing_Model[World$name %in% eurozone_list] <- "Eurozone (EUR)"
World$Pricing_Model[World$name %in% CIS_list] <- "CIS (USD)"
World$Pricing_Model[World$name %in% LATAM_list] <- "LATAM (USD)"
World$Pricing_Model[World$name %in% MENA_list] <- "MENA (USD)"
World$Pricing_Model[World$name %in% SASIA_list] <- "South Asia (USD)"
World$Pricing_Model[World$name %in% RegionalCurrency_list] <- "Tarification régionale dans la monnaie locale"
World$Pricing_Model[World$name == "United States of America"] <- "Prix de base (USA, USD)"

custom_palette <- c(
  "Prix de base (USA, USD)" = "#ba4c66",
  "Eurozone (EUR)" = "#36abd6",
  "Tarification régionale dans la monnaie locale" = "#006400",     
  "CIS (USD)" = "#FFD700",    
  "LATAM (USD)" = "#e0aa36",    
  "MENA (USD)" = "#e69a30",      
  "South Asia (USD)" = "#c96b34",   
  "Pas considéré" = "#FF0000" 
)

legend_order <- c("Prix de base (USA, USD)", "Eurozone (EUR)", 
                  "Tarification régionale dans la monnaie locale", "CIS (USD)", "LATAM (USD)", 
                  "MENA (USD)", "South Asia (USD)")
World$Pricing_Model <- factor(World$Pricing_Model, levels = legend_order)


tm_shape(World) +
  tm_polygons("Pricing_Model", 
              title = "46 pays pris en considération",
              palette = custom_palette,
              textNA = "Pas considéré",
              border.col = "black", 
              lwd = 1,
  ) +
  tm_layout(legend.outside = TRUE, frame = TRUE, legend.outside = FALSE,legend.position = c("left", "bottom"), na.show=FALSE)


#SOURCES:
#prix suggerés steam (70$): https://steamdb.info/sub/447947/
#codes monnaie: https://www.iban.com/currency-codes
#pays membre régions: https://partner.steamgames.com/doc/store/pricing/currencies
#Average Monthly Net Salary: https://www.numbeo.com/cost-of-living/country_price_rankings?itemId=105
#Adjusted net national income per capita: https://data.worldbank.org/indicator/NY.ADJ.NNTY.PC.CD
#PPP conversion factor: https://data.worldbank.org/indicator/PA.NUS.PPP?most_recent_value_desc=false
#taux de change: https://finance.yahoo.com
#tmap: https://doi.org/10.18637/jss.v084.i06
#quantmod:https://CRAN.R-project.org/package=quantmod