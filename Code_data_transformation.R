#Read libraries
install.packages(c("tidyverse","jsonlite"))
library(tidyverse)
library(jsonlite)

#Set working directory and assign address to data file. 

setwd("C:/Users/Mithun/Desktop/Git repositories/CHAMA_Data_Transformation")

url<-str_c(getwd(),"/data.json")

# Read JSON file and study structure of dataset.

data<-fromJSON(url) %>%
        janitor::clean_names()

glimpse(data)

#Change data types to date time and factors.

data$enqueued_time_utc<-as_datetime(data$enqueued_time_utc)
data$event_name<-factor(data$event_name)

glimpse(data)

#Change timezone to brazillion timezone.

data$enqueued_time_utc<-force_tz(data$enqueued_time_utc,"America/Sao_Paulo")

#Check column names and check number of factors.
colnames(data)

data %>% count(event_name,sort=T)

#Filter out requisite data

CurateOffer_Result<-data %>% filter(event_name=="CurateOffer_Result")
DynamicPrice_Result<-data %>% filter(event_name=="DynamicPrice_Result")

#Filter, read nested json, unnest dataset, select requisite columns and save final output.
CuratedOfferOptions.csv<-CurateOffer_Result %>%
        mutate(extract=lapply(payload,fromJSON)) %>% 
        unnest(extract) %>% 
        unnest(options) %>%
        select(4:20,1) %>% 
        rename(enqueued_time_utc_3="enqueued_time_utc")

CuratedOfferOptions.csv

DynamicPrice_Result.csv<-DynamicPrice_Result %>% 
        mutate(extract=lapply(payload,fromJSON)) %>% 
        unnest_wider(extract) 

DynamicPrice_Result.csv

DynamicPrice_Result.csv %>% count(provider,sort=T)

DynamicPriceRange.csv<-DynamicPrice_Result.csv %>% 
        filter(provider=="ApplyDynamicPriceRange") %>% 
        select(4:6,1) %>%
        unnest_wider(algorithmOutput) %>% 
        rename(enqueued_time_utc_3="enqueued_time_utc")

DynamicPriceRange.csv

DynamicPriceOption.csv<-DynamicPrice_Result.csv %>% 
        filter(provider=="ApplyDynamicPricePerOption") %>% 
        select(4:6,1) %>% 
        unnest_wider(algorithmOutput) %>% 
        rename(enqueued_time_utc_3="enqueued_time_utc")

DynamicPriceOption.csv

#Save final output as csv files.
write_csv(DynamicPriceRange.csv,"DynamicPriceRange.csv")
write_csv(DynamicPriceOption.csv,"DynamicPriceOption.csv")
write_csv(CuratedOfferOptions.csv,"CuratedOfferOptions.csv")





