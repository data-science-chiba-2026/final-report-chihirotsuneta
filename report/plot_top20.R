suppressPackageStartupMessages({
  library(tidyverse)
})

# Read nodes (expects analysis script has produced output/nodes.csv)
nodes <- read_csv('output/nodes.csv', show_col_types = FALSE)

# Top 20 by degree
top20 <- nodes %>% arrange(desc(degree)) %>% slice_head(n = 20)
write_csv(top20, 'output/top20_degree.csv')

# Plot: horizontal bar chart
p <- ggplot(top20, aes(x = reorder(name, degree), y = degree)) +
  geom_col(fill = 'steelblue') +
  coord_flip() +
  labs(x = NULL, y = 'Degree (number of sister cities)',
       title = 'Top 20 cities by number of sister-city links') +
  theme_minimal()

if(!dir.exists('output')) dir.create('output')

ggsave('output/top20_degree.png', p, width = 8, height = 6, dpi = 150)
message('Wrote output/top20_degree.png and output/top20_degree.csv')
