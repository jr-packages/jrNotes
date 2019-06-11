# XXX: This provides packages that are pre-build
# XXX: In theory this could mean we omit a required pkg
# XXX: from jrXXX and not be aware.
FROM rocker/verse

# Required for notes
RUN apt-get update && apt-get install -y \
    fonts-linuxlibertine

# Tex packages for notes
RUN tlmgr install tufte-latex hardwrap xltxtra realscripts \
    titlesec textcase setspace xcolor fancyhdr ulem morefloats \
    microtype ms units

# Base jrNotes package
RUN R -e "remotes::install_github('jr-packages/jrNotes', dependencies = TRUE)"
