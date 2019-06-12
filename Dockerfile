#########
#
#     Dockerfile for Metagenomics Bioinformatics MGnify session
#
### To run the container for the first time with generic graphics:
# xhost +
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw --privileged -e DISPLAY=unix$DISPLAY \
# -v $HOME/:/home/training/ --device /dev/dri --privileged --name mgnify ebitraining/metgenomics:mgnify
#
## To run with Nvidia graphics, add the following option:
# "-v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340"
#
### To resume using an container:
# docker exec -it mgnify /bin/bash
#
### To build the container:
# docker build -f ./Dockerfile -t mgnify .
# docker tag mgnify ebitraining/metagenomics:mgnify
# docker push ebitraining/metagenomics:mgnify
#
#########

FROM ubuntu:16.04
LABEL author="Mohamed Alibi" \
description="Docker image for Metagenomics Bioinformatics MGnify session." \
maintainer="Mohamed Alibi <alibi@ebi.ac.uk>"

# Pre requirements
########
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --reinstall language-pack-en \
    && apt-get install -y gnupg gdebi expect \
    && locale-gen en_GB.UTF-8

ADD https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.1335-amd64.deb /usr/local/rstudio.deb
RUN echo "deb http://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

RUN apt-get update; apt-get install -y build-essential ca-certificates libbz2-dev liblzma-dev gfortran \
    libncurses5-dev libncursesw5-dev zlib1g-dev automake pkg-config unzip openjdk-8-jre-headless perl-base \
    git wget sudo autoconf make xml2 locales libjpeg-dev zlibc libjpeg62 libxslt1.1 nano openjdk-8-jre \
    libxcomposite1 libtiff5 libqt5widgets5 libqt5webkit5 libssl-dev python3 mesa-common-dev libxml2-dev \
    libcurses-ocaml-dev libgl1-mesa-dri libgl1-mesa-glx mesa-utils fcitx-frontend-qt5 libqt5gui5 gdebi \
    fcitx-modules fcitx-module-dbus libedit2 libqt5core5a libqt5dbus5 libqt5network5 libqt5printsupport5 \
    default-jre default-jre-headless expect libcurl4-openssl-dev python-pip python3-pip curl \
    libopenblas-base libgsl-dev liblapacke liblapacke-dev openjfx libopenblas-dev \
    openssl libssl-dev manpages vim libgtk2.0-dev libglib2.0-dev libreadline6-dev libsqlite3-dev \
    && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
    && echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_GB.utf8 \
    && /usr/sbin/update-locale LANG=en_GB.UTF-8

# Install mg-toolkit
########
RUN pip3 install -U mg-toolkit

# Install R CRAN
########
RUN apt-get update; apt-get install -y r-base r-base-core r-recommended \
    && gdebi -n /usr/local/rstudio.deb \
    && rm -rf /usr/local/*.deb \
    && ln -f -s /usr/lib/rstudio/bin/rstudio /usr/bin/rstudio \
    && apt-get install -fy

# Set default CRAN repo
########
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
    && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
    && chmod 777 -R /usr/local/lib/R/ \
    && chmod 777 -R /usr/lib/R/ \
    && chmod 777 -R /usr/share/R/

# Install R downloaded_packages
########
COPY ./soil_comparison.R /usr/local/soil_comparison.R
COPY ./pkg_install.R /usr/local/pkg_install.R
RUN Rscript /usr/local/pkg_install.R \
    && chmod 777 /usr/local/soil_comparison.R \
    && ln -s /usr/local/soil_comparison.R /usr/local/bin/ \
    && chmod 777 -R /usr/local/lib/R/ \
    && chmod 777 -R /usr/lib/R/ \
    && chmod 777 -R /usr/share/R/

# Install Perl libs
########
RUN cpan install JSON:API DDP; exit 0

# Install SeqTools
########
COPY ./seqtools-4.44.1.tar.gz /usr/local/seqtools-4.44.1.tar.gz
RUN tar xvf /usr/local/seqtools-4.44.1.tar.gz -C /usr/local/ \
    && chmod 777 -R /usr/local/seqtools-4.44.1 \
    && cd /usr/local/seqtools-4.44.1 \
    && ./configure \
    && make \
    && make install \
    && rm /usr/local/seqtools-4.44.1.tar.gz

# Install MEGAN6 Community
########
ADD http://ab.inf.uni-tuebingen.de/data/software/megan6/download/MEGAN_Community_unix_6_15_2.sh /usr/local/MEGAN.sh
RUN chmod 777 /usr/local/MEGAN.sh \
    && /usr/local/MEGAN.sh -q -dir /usr/local/MEGAN \
    && ln -s /usr/local/MEGAN/MEGAN /usr/local/bin/megan \
    && chmod 777 -R /usr/local/MEGAN/ \
    && rm /usr/local/MEGAN.sh

## Create user training
########
RUN useradd -r -s /bin/bash -U -m -d /home/training -p '' training

# Setup the user envirenment
########
ENV HOME /home/training
RUN chown -R training:training $HOME \
    && usermod -aG sudo,audio,video training \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR $HOME
USER training
