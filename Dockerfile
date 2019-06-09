FROM rocker/verse
RUN apt-get update && apt-get install -y \
    fonts-linuxlibertine

RUN R -e "remotes::install_github('jr-packages/jrNotes')"

RUN tlmgr install tufte-latex hardwrap xltxtra realscripts \
    titlesec textcase setspace xcolor fancyhdr ulem morefloats \
    microtype ms
