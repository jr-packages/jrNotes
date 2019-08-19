# XXX: This provides packages that are pre-build
# XXX: In theory this could mean we omit a required pkg from jrXXX and not be aware.
# XXX: The alternative is to use rocker/r-base and build everything by hand. 
# XXX: Not using rocker/verse - funny tinytex things that mess things up.
FROM rocker/tidyverse:3.6

RUN  apt-get update \
     && apt-get install -y --no-install-recommends \
     ## used by some base R plots
     ghostscript \
     ## used to build rJava and other packages
     libbz2-dev libicu-dev liblzma-dev \
     ## system dependency of hunspell (devtools)
     libhunspell-dev \
     ## system dependency of hadley/pkgdown
     libmagick++-dev \
     ## rdf, for redland / linked data
     librdf0-dev \
     ## for V8-based javascript wrappers
     libv8-dev \
     ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
     qpdf \
     ## For building PDF manuals
     texinfo \
     ## for git via ssh key
     ssh \
     ## just because
     less vim \
     ## parallelization
     libzmq3-dev libopenmpi-dev \
     ## spatial
     libudunits2-dev libgdal-dev \
     ## Tex
     texlive texlive-xetex texlive-generic-recommended latexmk \
     ## Fonts
     fonts-linuxlibertine fonts-roboto texlive-fonts-extra \
     # curl for tagging step
     curl \
     # python
     python3-pip python3-venv libffi-dev \
     # ffmpeg for animations in slides
     ffmpeg \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

## Hack to get github package installed
## Once countdown is on CRAN, then update jrPres and remove this line
RUN Rscript -e 'if (!require(countdown)) remotes::install_github("gadenbuie/countdown")'

RUN pip3 install virtualenv \
    # ## Link to update.r for gitlab runner
    &&  ln -s /usr/local/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
    # # R Package directories
    #&& mkdir rpackages && chmod a+r rpackages \
    # Packages stored in /rpackages for everyone
    #&& echo "R_LIBS=/rpackages/" >> /usr/local/lib/R/etc/Renviron.site \
    # Need for littler
    #&& echo ".libPaths('/rpackages/')" >> /usr/local/lib/R/etc/Rprofile.site \
    && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/', \
            jrpackages = 'https://jr-packages.github.io/drat/'))" >> /usr/local/lib/R/etc/Rprofile.site
  
## Install jrNotes jrPresentation
## XXX: If jrPres is updated, this docker image is __not__ automatically updated
RUN  install2.r -n -1 -d TRUE --error jrNotes jrPresentation \
    ## && update.r -l /usr/local/lib/R/site-library -n -1 \
    ## Clean-up; reduce docker size
    && rm -rf  /tmp/downloaded_packages/

