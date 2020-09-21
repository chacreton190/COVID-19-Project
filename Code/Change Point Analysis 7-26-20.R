
install.packages("changepoint")
install.packages("changepoint.np")
library(xts)
library(ggplot2)
library(changepoint)
library(changepoint.np)
covid <- read_excel("Coding/COVID-19 Project/Data/COVID Multi-state Model Data set (7-14-20).xlsx", sheet = "Project_Dataset")
pp <- read_excel("Coding/COVID-19 Project/Data/Change Point Analysis State Level Median PP.xlsx")
case <- read_excel("Coding/COVID-19 Project/Data/Change Point Analysis State Level Avg Case.xlsx")

covid$date <- as.Date(covid$date)

plot(pp$median)

class(covid$date)

plot(covid$date, covid$PERCENT_POSITIVE, main='sdsddfd', xlab='sdsd', ylab='sdsd', ylim= c(15,30))

View(pp)

#Change point analysis using the median percent positive ratio for the state
pp.pelt=cpt.meanvar(pp$median,method='PELT',minseglen=1 )
cpts(pp.pelt)
plot(pp.pelt, main='Change Point Analysis FL Weekly COVID-19 Percent Pos. Ratio', col='Black' ,ylab= 'Median')

case_med.pelt=cpt.meanvar(case$median,method='PELT',minseglen=2,test.stat = 'Poisson'  )
cpts(case_med.pelt)
plot(case_med.pelt, main='Change Point Analysis FL Weekly COVID-19 Med. Case Count', col='brown', ylab= 'Median')

case_avg.pelt=cpt.meanvar(case$mean,method='PELT',minseglen=2,test.stat = 'Gamma'  )
cpts(case_avg.pelt)
plot(case_avg.pelt, main='Change Point Analysis FL Weekly COVID-19 Avg. Case Count', col='black', ylab= 'Mean')

case_var.pelt=cpt.meanvar(case$var,method='PELT',minseglen=2,test.stat = 'Gamma' )
cpts(case_var.pelt)
plot(case_var.pelt, main='Change Point Analysis FL Weekly COVID-19 Case Count Variance', col='blue', ylab= 'Variance')


