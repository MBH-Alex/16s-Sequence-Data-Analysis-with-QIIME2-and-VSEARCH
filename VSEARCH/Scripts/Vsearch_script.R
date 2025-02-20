library(data.table)
library(tidyverse)
library(dplyr)
library(stringr)

Table <- fread("YOUR PATH HERE/all.otutab.txt")
Taxonomy <- read.delim("YOUR PATH HERE/tax_raw.txt", sep="\t", header=F)
Taxonomy$V1 = gsub(";.*","",Taxonomy$V1)
Taxonomy$V6 = lapply(Taxonomy$V1, gsub, pattern = "OTU_", replacement = "")
Taxonomy <- as.data.frame(Taxonomy)
Taxonomy$V6 <- unlist(Taxonomy$V6)
write.csv(Taxonomy, "YOUR PATH HERE/axonomy.csv", row.names = FALSE)
Taxonomy <- read.csv("YOUR PATH HERE/Taxonomy.csv")
names(Taxonomy)[1] <- 'OTU'
names(Taxonomy)[2] <- 'Taxonomy'
names(Taxonomy)[3] <- 'Useless'
names(Taxonomy)[4] <- 'Taxonomy2'
names(Taxonomy)[5] <- 'Useless2'
names(Taxonomy)[6] <- 'Sort'
Taxonomy <- Taxonomy[order(Taxonomy$Sort) , ]

Taxonomy2 <- subset(Taxonomy, select=c("OTU", "Taxonomy"))
Taxonomy2$Taxonomy = gsub("([0-9].[0-9])","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("([0-9])","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy <- gsub("[()]", "", Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("d:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("c:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("p:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("o:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("f:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("g:","",Taxonomy2$Taxonomy)
Taxonomy2$Taxonomy = gsub("s:","",Taxonomy2$Taxonomy)

Taxonomy3 <- as.data.frame(str_split_fixed(Taxonomy2$Taxonomy, ",", 7))
names(Taxonomy3)[1] <- 'Kingdom'
names(Taxonomy3)[2] <- 'Phylum'
names(Taxonomy3)[3] <- 'Class'
names(Taxonomy3)[4] <- 'Order'
names(Taxonomy3)[5] <- 'Family'
names(Taxonomy3)[6] <- 'Genus'
names(Taxonomy3)[7] <- 'Species'

Taxonomy3$OTU = Taxonomy2$OTU
Taxonomy3 <- Taxonomy3 %>% relocate(OTU, .before = Kingdom)
names(Table)[1] <- 'OTU'
Table$Sort = lapply(Table$OTU, gsub, pattern = "OTU_", replacement = "")
Table <- as.data.frame(Table)
Table$Sort <- unlist(Table$Sort)
write.csv(Table, "YOUR PATH HERE/OTU_Table.csv", row.names = FALSE)
Table <- read.csv("YOUR PATH HERE/OTU_Table.csv")
Table <- Table[order(Table$Sort) , ]

OTU_Table = Table
OTU_Table$OTU = Taxonomy3$Species
names(OTU_Table)[1] <- 'Species'

OTU_Table2 <- OTU_Table %>% group_by(Species) %>% summarise_each(funs(max)) 
