library(readxl)
library(readr)
# --------------------------------------- Higher geographical level summary measure --------------------------------------- #

# ------------------------------------------------- AVERAGE SCORE ------------------------------------------ #

# can be calculated for each domain, here an example for the overall BIMD2011 at the level of municipality 

# upload file with domains and overall indices 

# this code is using overall indices but can be modified for individual domains 

bimd2011 <-read.csv("https://raw.githubusercontent.com/bimd-project/Belgian-Indices-of-Multiple-Deprivation/main/FILE%202%20BIMD2011%20DOMAINS%20(SCORES%2C%20RANKS%2C%20DECILES)/BIMD2011_DOMAINS_STATISTICAL_SECTOR_ELLIS_WIDE.csv")

names(bimd2011)
bimd2011 <- dplyr::select(bimd2011, c(1,20))

# population for statistical sectors 
pop2011 <- read_delim("https://raw.githubusercontent.com/bimd-project/Belgian-Indices-of-Multiple-Deprivation/main/FILE%202%20BIMD2011%20DOMAINS%20(SCORES%2C%20RANKS%2C%20DECILES)/population_2011")

bimd_pop <- merge(bimd2011, pop2011, by = "CD_RES_SECTOR", all = F)
names(bimd_pop)

bimd_pop$SCORE_pop <- bimd_pop$BIMD2011_score*bimd_pop$POPULATION

bimd_pop$municipality <- substr(bimd_pop$CD_RES_SECTOR, 1,5)
bimd_pop <- aggregate(SCORE_pop ~ municipality, bimd_pop, sum)
head(bimd_pop)

# total population per municipality 

pop2011 <- read_delim("https://raw.githubusercontent.com/bimd-project/Belgian-Indices-of-Multiple-Deprivation/main/FILE%202%20BIMD2011%20DOMAINS%20(SCORES%2C%20RANKS%2C%20DECILES)/population_2011")
pop2011$municipality <- substr(pop2011$CD_RES_SECTOR, 1,5 )
pop2011 <- aggregate(POPULATION ~ municipality, pop2011, sum)
names(pop2011)[2] <- "total_pop"

# names of the municipalities 
municipality <- read_delim("https://raw.githubusercontent.com/bimd-project/Belgian-Indices-of-Multiple-Deprivation/main/FILE%202%20BIMD2011%20DOMAINS%20(SCORES%2C%20RANKS%2C%20DECILES)/names_sectors_municipalities_2011.csv")
municipality <- municipality[!duplicated(municipality$COMMUNE),]

fin_pop <- merge(bimd_pop, pop2011, by = "municipality", all = F)

final <- merge(fin_pop, municipality, by.x = "municipality", by.y = "CD_MUNTY_REFNIS", all = F)
names(final)

final$avg_score <-(final$SCORE_pop)/final$total_pop
final$rank_avg_score <- rank(-final$avg_score , na.last = 'NA', ties.method = "random") # assigns to the most negative number the highest SCORE

final <- final[order(final$rank_avg_score, decreasing = F),]
head(final)
final <- dplyr::select(final, -c(2,3,4,5))

write.xlsx(final, " ", sheetName = "Sheet1", colNames = TRUE, rowNames = TRUE, append = FALSE)
