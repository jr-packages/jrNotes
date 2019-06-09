FROM rocker/verse
RUN apt-get update && apt-get install -y \
    fonts-linuxlibertine
RUN R -e "remotes::install_github('jr-packages/jrNotes')"


