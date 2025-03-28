library(ggplot2)
library(tidyr)

args = commandArgs(trailingOnly = TRUE)
# 1st = ortholog_groups.tsv
# 2nd = Summary data folder 

##### PREP DATA ######
OGs = read.delim(args[1], na.strings = "*")
colnames(OGs) = gsub("\\.fasta", "", colnames(OGs))
allSpecies = colnames(OGs[,5:ncol(OGs)])
sumFile = paste(args[2], "/", Sys.Date(), "_summary.txt", sep="")

# Proteins per species table
df = NULL
for (species in allSpecies) {
  temp_df = as.data.frame(OGs[,c(species)])
  colnames(temp_df) = c("species")
  temp_df = separate_rows(temp_df, species, sep = ",")
  newRow = c(species, nrow(temp_df))
  df = rbind(df, newRow)
}

colnames(df) = c('species', 'prot_cnt')
row.names(df) = NULL
df = as.data.frame(df)
df$prot_cnt = as.numeric(df$prot_cnt)

###### GRAPHS #####
# Get enough of the tail wihout making the rest of the graph unreadable
avg = mean(OGs$group_size)
avg2 = mean(OGs[OGs$group_size > avg,]$group_size)
cutoff = avg2 + sd(OGs[OGs$group_size > avg,]$group_size)

p = ggplot(OGs, aes(x = group_size)) + 
  geom_histogram(fill="darkorchid4", binwidth = 1) + xlim(0,cutoff) +
  labs(x = "Cluster size", title = "Cluster size distribution")
ggsave(paste(args[2], '/', "cluster_size_hist.png", sep=""),
       plot = p, height = 1200, width = 1500, units = "px")

p = ggplot(df, aes(x = species, y = prot_cnt)) + 
  geom_bar(stat = "identity", fill = "darkorchid4") + 
  labs(y = "Protein count", title = "Proteins per species")
ggsave(paste(args[2], '/', "proteins_per_species.png", sep=""),
       plot = p, height = 1200, width = 1500, units = "px")

###### SUMMARY  ######
# Amount of clusters 
cat(paste("Orthology clustering for", length(allSpecies), "species"),
    file = sumFile, sep = "\n")
cat(paste("Amount of ortholog clusters =", nrow(OGs)), file = sumFile,
    append = T, sep = "\n")

# Cluster size
cat("\n##### CLUSTER SIZE #####", file = sumFile, append = T, sep = "\n")
cat(paste("Minimum cluster size =", min(OGs$group_size)), file = sumFile,
    append = T, sep = "\n")
cat(paste("Maximum cluster size =", max(OGs$group_size)), file = sumFile,
    append = T, sep = "\n")
cat(paste("Mean cluster size =", avg), file = sumFile,
    append = T, sep = "\n")
cat(paste("   SD =", sd(OGs$group_size)), file = sumFile,
    append = T, sep = "\n")
cat(paste("Median cluster size =", median(OGs$group_size)), file = sumFile, append = T, sep = "\n")

# Proteins per species
cat("\n##### PROTEIN USAGE #####", file = sumFile, append = T, sep = "\n")
cat(paste("Total amount of proteins:", sum(OGs$group_size)), file = sumFile,
    append = T, sep = "\n")
cat("\n# Proteins per species #", file = sumFile, append = T, sep = "\n")
write.table(df, file = sumFile, append = T, sep = "\t", quote = F, 
            row.names = F)
