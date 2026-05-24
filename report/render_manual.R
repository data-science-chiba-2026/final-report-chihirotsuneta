# Simple manual renderer: create PNG network plot and HTML report using outputs from analysis
suppressPackageStartupMessages({
  library(tidyverse)
  library(tidygraph)
  library(ggraph)
  library(knitr)
})

graph <- readRDS('output/graph.rds')
nodes <- as_tibble(graph, what = 'nodes')

# save network plot
png(filename = 'output/network.png', width = 1600, height = 1000, res = 150)
set.seed(42)
ggraph(graph, layout = 'fr') +
  geom_edge_link(alpha = 0.4) +
  geom_node_point(aes(size = degree), color = 'steelblue') +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  theme_void()
dev.off()

# build simple HTML
top_tbl <- nodes %>% arrange(desc(degree)) %>% slice_head(n = 20)
html_table <- knitr::kable(top_tbl, format = 'html', table.attr = 'class="table"')

# compute degree summary
degree1 <- sum(nodes$degree == 1, na.rm = TRUE)
degree2 <- sum(nodes$degree == 2, na.rm = TRUE)
degree3 <- sum(nodes$degree == 3, na.rm = TRUE)
degree_summary <- tibble(metric = c('degree_1','degree_2','degree_3'), count = c(degree1, degree2, degree3))
if(!dir.exists('output')) dir.create('output')
readr::write_csv(degree_summary, 'output/degree_summary.csv')

html <- paste0(
  "<html>\n<head><meta charset=\"utf-8\"><title>Sister Cities manual report</title></head>\n<body>\n",
  "<h1>Sister Cities: Connections</h1>\n",
  "<h2>Top cities by degree</h2>\n",
  html_table,
  "\n<h2>Network plot</h2>\n",
  "<img src=\"network.png\" alt=\"network\" style=\"max-width:100%;height:auto;\"/>\n",
  "\n<h2>Degree distribution</h2>\n",
  "<img src=\"degree_distribution.png\" alt=\"degree distribution\" style=\"max-width:100%;height:auto;\"/>\n",
  "\n<h2>Top 20 cities by degree</h2>\n",
  "<img src=\"top20_degree.png\" alt=\"top20 degree\" style=\"max-width:100%;height:auto;\"/>\n",
  "\n<h2>Degree summary</h2>\n",
  "<p>Number of cities with degree 1: ", degree1, "<br/>Number of cities with degree 2: ", degree2, "<br/>Number of cities with degree 3: ", degree3, "</p>\n",
  "\n<p>Download degree data: <a href=\"degree_distribution.csv\">degree_distribution.csv</a>, top20: <a href=\"top20_degree.csv\">top20_degree.csv</a>, and summary: <a href=\"degree_summary.csv\">degree_summary.csv</a></p>\n",
  "</body>\n</html>\n"
)


writeLines(html, con = 'output/sister_cities_manual.html')
message('Wrote output/sister_cities_manual.html and network.png')
