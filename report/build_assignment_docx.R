suppressPackageStartupMessages({
  library(tidyverse)
  library(officer)
  library(flextable)
})

# Load nodes
nodes <- readr::read_csv('output/nodes.csv', show_col_types = FALSE)
# include cities with degree up to 3 as requested
smaller <- nodes %>% filter(degree <= 3)

# Create line plot for 'smaller'
# compute counts by degree
deg_df <- smaller %>% count(degree) %>% arrange(degree)

p <- ggplot(deg_df, aes(x = degree, y = n)) +
  geom_line(color = 'steelblue', size = 1) +
  geom_point(color = 'steelblue', size = 2) +
  geom_text(aes(label = n), vjust = -0.5, size = 3) +
  scale_x_continuous(breaks = pretty(deg_df$degree)) +
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
