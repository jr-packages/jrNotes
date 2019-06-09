FROM rocker/verse
RUN apt-get update && apt-get install -y \
    fonts-linuxlibertine

RUN R -e "remotes::install_github('jr-packages/jrNotes')"

RUN tlmgr install tufte-latex && \
    tlmgr install hardwrap && \
    tlmgr install xltxtra && \
    tlmgr install realscripts && \
    tlmgr install titlesec && \
    tlmgr install textcase && \
    tlmgr install setspace && \
    tlmgr install xcolor && \
    tlmgr install fancyhdr && \
    tlmgr install ulem && \
    tlmgr install morefloats && \
    tlmgr install microtype
