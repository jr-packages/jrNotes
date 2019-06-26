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
    
RUN apt-get update && apt-get install -y \
    python-pip python-dev \
    build-essential libffi-dev \
    libssl-dev gcc libc-dev \
    make apt-transport-https \
    ca-certificates \
    curl gnupg-agent \
    software-properties-common && \
    pip install docker-compose
 
## Add docker
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable" && \
   apt-get update && \
   apt-get -y install docker-ce
# Base jrNotes package
RUN R -e "remotes::install_github('jr-packages/jrNotes', dependencies = TRUE)"
