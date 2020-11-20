install.packages('msm')
library(msm)

covid_msm <- read_excel("Coding/COVID-19 Project/Data/Change Point Analysis State Level Median PP.xlsx")
head(covid_msm)




View(covid_msm)
colnames(covid_msm)

Q <- rbind(c(1,1,1),
           c(1,1,1),
           c(1,1,1))
Q

Q <- rbind(c(1,1,1)
       )
covid_msm.msm <- msm(stage ~ week, data=covid_msm, qmatrix = Q ,
                     , exacttimes = TRUE)

statetable.msm(stage , week, data=covid_msm)

covid_msm.msm <- msm(stage ~ week , data=covid_msm, qmatrix = Q)
