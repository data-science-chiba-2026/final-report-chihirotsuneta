suppressPackageStartupMessages({
  library(tidyverse)
  library(officer)
  library(flextable)
})

# Load nodes
nodes <- readr::read_csv('output/nodes.csv', show_col_types = FALSE)
smaller <- nodes %>% filter(degree <= 2)

# Create improved bar plot for 'smaller'
p <- ggplot(smaller, aes(x = factor(degree))) +
  geom_bar(fill = 'steelblue') +
  geom_text(stat = 'count', aes(label = ..count..), vjust = -0.5, size = 3) +
  labs(x = 'Degree', y = 'Number of cities', title = 'Distribution of cities with degree <= 2') +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

if(!dir.exists('output')) dir.create('output')

ggsave('output/fewer_twinned.png', p, width = 6, height = 4, dpi = 150)

# Build docx
degree_gt2 <- nrow(nodes %>% filter(degree > 2))
doc <- read_docx()

doc <- doc %>%
  body_add_par('Twinned Cities', style = 'heading 1') %>%
  body_add_par(glue::glue('Total cities: {nrow(nodes)}'), style = 'Normal') %>%
  body_add_par(glue::glue('Cities with >2 connections: {degree_gt2}'), style = 'Normal') %>%
  body_add_par('Distribution (degree <=2)', style = 'heading 2') %>%
  body_add_img(src = 'output/fewer_twinned.png', width = 6, height = 3) %>%
  body_add_par('Top 20 cities by degree', style = 'heading 2') %>%
  body_add_img(src = 'output/top20_degree.png', width = 6, height = 4)

print(doc, target = 'output/assignment_practice.docx')
message('Wrote output/assignment_practice.docx and fewer_twinned.png')
