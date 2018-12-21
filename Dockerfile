FROM rocker/tidyverse
RUN R -e "remotes::install_github('jr-packages/jrNotes')"
