library(tidyverse)
library(gwplotting)

setwd("~/Desktop")

sl <- 'alitheaPreferenceAnalysis/gwas/hcyg.info'
ma <- 'alitheaPreferenceAnalysis/gwas/hcyg.to.hmel.ragoo.mapped'

x <- read_table2( 'snps.simple.gz', col_names = c('scaf', 'ps', 'stat') )
x$chr <- 1
#x$id <- x$stat
#x$oripos <- paste0( x$scaf, '.', x$ps )

#oripos <- x[, c('id','oripos')]
#x <- select( x, scaf, ps, stat, chr )

# need bp_cum for each chromosome, not as a whole...
y <- reorder_scaffolds( x, assignments = ma, species = 'hmel' ) %>%
  select( scaf, ps, stat, chr )

# Get SNPs excluded
setdiff( x$stat, y$stat ) -> excluded
write.table( excluded, 'snps.excluded.txt', quote = F, col.names = F,
             row.names = F )
rm(excluded)
rm(x)

# Get cumulative positions per chr


for( i in 1:21 ){
  
  
  z <- y %>% filter( chr == i ) %>%
  get_cumulative_positions( ., scaffold_lengths = sl ) %>%
  select( stat, chr, bp_cum )
  
  write_delim( z, 'reordered.table.txt', delim = " ", append = T, col_names = F )
  cat("Finished ",i," \n")
  
}
  get_cumulative_positions( ., scaffold_lengths = sl ) %>%
  select( stat, chr, bp_cum )

y$oripos <- oripos$oripos[ match( y$stat, oripos$id) ]

gzout <- gzfile( description = "reordering.txt.gz", open = "w" )

write_tsv( y, gzout, col_names = F )
