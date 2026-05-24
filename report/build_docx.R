suppressPackageStartupMessages({
  library(tidyverse)
  library(officer)
  library(flextable)
})

# Use existing outputs
nodes <- readr::read_csv('output/nodes.csv', show_col_types = FALSE)
degree_summary <- readr::read_csv('output/degree_summary.csv', show_col_types = FALSE)

top20 <- nodes %>% arrange(desc(degree)) %>% slice_head(n = 20)

# build docx
doc <- read_docx()

doc <- doc %>%
  body_add_par('Sister Cities: Connections', style = 'heading 1') %>%
  body_add_par('Top cities by degree', style = 'heading 2') %>%
  body_add_flextable(flextable(top20) %>% autofit()) %>%
  body_add_par('Top 20 chart', style = 'heading 2') %>%
  body_add_img(src = 'output/top20_degree.png', width = 6, height = 4) %>%
  body_add_par('Degree distribution', style = 'heading 2') %>%
  body_add_img(src = 'output/degree_distribution.png', width = 6, height = 4) %>%
  body_add_par('Network plot', style = 'heading 2') %>%
  body_add_img(src = 'output/network.png', width = 6, height = 4) %>%
  body_add_par('Degree summary', style = 'heading 2') %>%
  body_add_flextable(flextable(degree_summary) %>% autofit())

print(doc, target = 'output/sister_cities.docx')
message('Wrote output/sister_cities.docx')
