FROM rocker/r-ubuntu:18.04

# docker run --rm -ti jrpackages/jrnotes /bin/bash

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
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
     texlive texlive-xetex texlive-generic-recommended latexmk pandoc \
     ## Fonts
     fonts-linuxlibertine fonts-roboto texlive-fonts-extra \
     # curl & git for tagging step
     curl git \
     # python
     python3-pip python3-venv libffi-dev \
     # ffmpeg for animations in slides
     ffmpeg \
     # ssl for R packages
     libssl-dev \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

RUN pip3 install virtualenv \
    # ## Link to update.r for gitlab runner
    &&  ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
    # Need for littler
    && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/', \
            jrpackages = 'https://jr-packages.github.io/drat/'))" >> /usr/lib/R/etc/Rprofile.site

RUN install2.r --error -n -1 remotes 


## Hack to get github package installed
## Once countdown is on CRAN, then update jrPres and remove this line
RUN Rscript -e 'if (!require(countdown)) remotes::install_github("gadenbuie/countdown")'


## Install jrNotes jrPresentation
## XXX: If jrPres is updated, this docker image is __not__ automatically updated
RUN  install2.r -n -1 -d TRUE --error jrNotes jrPresentation \
    ## && update.r -l /usr/local/lib/R/site-library -n -1 \
    ## Clean-up; reduce docker size
    && rm -rf  /tmp/downloaded_packages/

