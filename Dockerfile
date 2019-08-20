FROM jumpingrivers/base-image
# docker run --rm -ti jrpackages/jrnotes /bin/bash

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/', \
            jrpackages = 'https://jr-packages.github.io/drat/'))" >> /usr/lib/R/etc/Rprofile.site

## Hack to get github package installed
## Once countdown is on CRAN, then update jrPres and remove this line
RUN install2.r --error -n -1 remotes
RUN Rscript -e 'if (!require(countdown)) remotes::install_github("gadenbuie/countdown")'

## Install jrNotes jrPresentation
## XXX: If jrPres is updated, this docker image is __not__ automatically updated
RUN install2.r -n -1 -d TRUE --error jrNotes jrPresentation \
    ## && update.r -l /usr/local/lib/R/site-library -n -1 \
    ## Clean-up; reduce docker size
    && rm -rf  /tmp/downloaded_packages/

