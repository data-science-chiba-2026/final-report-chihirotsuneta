# Helper: load, clean, and build network for TidyTuesday sister-cities (2026-05-12)
# Writes output/nodes.csv, output/edges.csv, output/graph.rds
suppressPackageStartupMessages({
  library(tidyverse)
  library(tidytuesdayR)
  library(tidygraph)
  library(igraph)
  library(stringr)
})

message('Loading TidyTuesday data...')
# try tt_load, fallback to readr if needed
ok <- try({tuesdata <- tt_load('2026-05-12'); TRUE}, silent = TRUE)
if(!isTRUE(ok)){
  stop('tt_load failed; ensure internet access and tidytuesdayR package are installed')
}

data <- tuesdata[[1]]
message('Columns: ', paste(names(data), collapse=', '))

# Heuristic detection of pair columns
cols <- names(data)
city_cols <- cols[str_detect(cols, regex('city|town|name', ignore_case=TRUE))]
country_cols <- cols[str_detect(cols, regex('country', ignore_case=TRUE))]

if(length(city_cols) >= 2) {
  city1_col <- city_cols[1]
  city2_col <- city_cols[2]
} else {
  city1_col <- cols[1]
  city2_col <- cols[2]
}

country1_col <- ifelse(length(country_cols) >= 1, country_cols[1], NA)
country2_col <- ifelse(length(country_cols) >= 2, country_cols[2], country1_col)

edges <- tibble(
  city1 = as.character(data[[city1_col]]),
  city2 = as.character(data[[city2_col]]),
  country1 = if(!is.na(country1_col)) as.character(data[[country1_col]]) else NA_character_,
  country2 = if(!is.na(country2_col)) as.character(data[[country2_col]]) else NA_character_
)

normalize <- function(x) {
  x %>% as.character() %>% str_squish() %>% tolower() %>% str_to_title()
}

edges <- edges %>%
  mutate(city1 = normalize(city1),
         city2 = normalize(city2),
         country1 = ifelse(is.na(country1), '', normalize(country1)),
         country2 = ifelse(is.na(country2), '', normalize(country2))
  ) %>%
  filter(!is.na(city1) & !is.na(city2)) %>%
  filter(!(city1 == '' | city2 == '')) %>%
  filter(city1 != city2) %>%
  distinct()

edges <- edges %>%
  mutate(id1 = ifelse(country1 == '', city1, paste(city1, country1, sep = ', ')),
         id2 = ifelse(country2 == '', city2, paste(city2, country2, sep = ', '))
  )

nodes <- tibble(id = unique(c(edges$id1, edges$id2))) %>%
  mutate(name = id)

edges_tbl <- edges %>%
  transmute(from = match(id1, nodes$id), to = match(id2, nodes$id))

graph <- tbl_graph(nodes = nodes, edges = edges_tbl, directed = FALSE)

# compute degree
graph <- graph %>% activate(nodes) %>% mutate(degree = centrality_degree())

# save outputs
if(!dir.exists('output')) dir.create('output')
write_csv(as_tibble(graph %>% activate(nodes) %>% as_tibble()), file = 'output/nodes.csv')
write_csv(as_tibble(graph %>% activate(edges) %>% as_tibble()), file = 'output/edges.csv')
saveRDS(graph, file = 'output/graph.rds')

message('Saved processed nodes and graph to output/')
