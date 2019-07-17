# XXX: This provides packages that are pre-build
# XXX: In theory this could mean we omit a required pkg from jrXXX and not be aware.
# XXX: The alternative is to use rocker/r-base and build everything by hand. 
FROM rocker/verse:3.5

## Hack to get github package installed
## Once countdown is on CRAN, then update jrPres and remove this line
RUN Rscript -e 'if (!require(countdown)) remotes::install_github("gadenbuie/countdown")'

# Fonts required for notes
# curl for tagging step
# ffmpeg for animations in slides
RUN apt-get update && apt-get install -y  \
    fonts-linuxlibertine curl \ 
    python3-pip python3-venv libffi-dev \
    ffmpeg \
    # virtual env
    && pip3 install virtualenv \
    ## Link to update.r for gitlab runner
    && ln -s /usr/local/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
    ## Latex packages for notes
    && tlmgr update --self \
    && tlmgr install tufte-latex hardwrap xltxtra realscripts \
              titlesec textcase setspace xcolor fancyhdr ulem morefloats \
              microtype ms units xkeyval tools\
    #
    # R Package directories
    && mkdir rpackages && chmod a+r rpackages \
    # Packages stored in /rpackages for everyone
    && echo "R_LIBS=/rpackages/" >> /usr/local/lib/R/etc/Renviron.site \
    # Need for littler
    && echo ".libPaths('/rpackages/')" >> /usr/local/lib/R/etc/Rprofile.site \
    && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/', \
            jrpackages = 'https://jr-packages.github.io/drat/'))" >> /usr/local/lib/R/etc/Rprofile.site \
    #
    ## Install jrNotes jrPresentation
    ## XXX: If jrPres is updated, this docker image is __not__ automatically updated
    && install2.r -n -1 -d TRUE -l /rpackages/ --error jrNotes jrPresentation \
    ## Clean-up; reduce docker size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/downloaded_packages/

 
