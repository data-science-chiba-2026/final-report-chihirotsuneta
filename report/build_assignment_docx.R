suppressPackageStartupMessages({
  library(tidyverse)
  library(officer)
  library(flextable)
})

# Load nodes
nodes <- readr::read_csv('output/nodes.csv', show_col_types = FALSE)
smaller <- nodes %>% filter(degree <= 2)

# Create freqpoly for 'smaller'
p <- ggplot(smaller, aes(x = degree)) +
  geom_histogram(binwidth = 1, fill = 'steelblue', color = 'white') +
  labs(x = 'Degree', y = 'Number of cities', title = 'Distribution of cities with degree <= 2') +
  theme_minimal()

if(!dir.exists('output')) dir.create('output')

ggsave('output/fewer_twinned.png', p, width = 8, height = 4, dpi = 150)

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
