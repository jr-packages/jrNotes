# XXX: This provides packages that are pre-build
# XXX: In theory this could mean we omit a required pkg
# XXX: from jrXXX and not be aware.
FROM rocker/verse

# Required for notes
RUN apt-get update && apt-get install -y \
    fonts-linuxlibertine && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/downloaded_packages/

# Tex packages for notes
RUN tlmgr install tufte-latex hardwrap xltxtra realscripts \
    titlesec textcase setspace xcolor fancyhdr ulem morefloats \
    microtype ms units

RUN mkdir rpackages \
  && chmod a+r rpackages \
  # Packages stored in /rpackages for everyone
  && echo "R_LIBS=/rpackages/" >> /usr/local/lib/R/etc/Renviron.site \
  && echo "options(repos = c(CRAN = "https://cran.rstudio.com/", 
            jrpackages = "https://jr-packages.github.io/drat/"))" >> /usr/local/lib/R/etc/Rprofile.site \
  &&  install2.r -l /rpackages/ --error jrNotes 
