suppressPackageStartupMessages({
  library(tidyverse)
})

# Read nodes (expects analysis script has produced output/nodes.csv)
nodes <- read_csv('output/nodes.csv', show_col_types = FALSE)

# Compute degree distribution
deg_dist <- nodes %>% count(degree) %>% arrange(degree)

# Plot: bar chart (degree on x, number of cities on y)
p <- ggplot(deg_dist, aes(x = degree, y = n)) +
  geom_col(fill = 'steelblue') +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(x = 'Degree (number of sister cities)', y = 'Number of cities',
       title = 'Degree distribution of sister-city network') +
  theme_minimal()

if(!dir.exists('output')) dir.create('output')

ggsave('output/degree_distribution.png', p, width = 8, height = 5, dpi = 150)
write_csv(deg_dist, 'output/degree_distribution.csv')
message('Wrote output/degree_distribution.png and output/degree_distribution.csv')
