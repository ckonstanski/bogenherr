FROM ubuntu:noble
MAINTAINER Carlos Konstanski
ADD tmp/docker-start.tar.xz /
ARG OLO_USERNAME=root
ARG OLO_GROUPNAME=root
ARG OLO_UID=0
ARG OLO_GID=0
RUN data/install-root.sh
USER ${OLO_UID}:${OLO_GID}
RUN data/install-user-sbcl.sh
ENTRYPOINT [ "data/start_app.sh" ]
#ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD []
