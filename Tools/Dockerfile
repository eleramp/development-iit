ARG from=diegoferigo/devenv:latest
FROM ${from}

# Build-time metadata as defined at http://label-schema.org
# ARG BUILD_DATE
# ARG VCS_REF
# ARG VERSION=0.9
LABEL \
    maintainer="Elena Rampone <elena.rampone18@gmail.com>" \
    # org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="tools-cpp" \
    org.label-schema.description="" \
    org.label-schema.url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vendor="" \
    # org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

# Utilities
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        sudo \
        software-properties-common \
        apt-transport-https \
        apt-utils \
        wget \
        nano \
        dbus-x11 \
        tree \
        bash-completion \
        libgnome-keyring0 \
        gnupg2 \
        colordiff \
        octave \
        locales \
        trash-cli \
        xterm \
        curl \
        unzip \
        &&\
    rm -rf /var/lib/apt/lists/*

# Setup locales and tzdata
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen &&\
    locale-gen &&\
    update-locale LANG="en_US.UTF-8" &&\
    export DEBIAN_FRONTEND=noninteractive &&\
    export DEBCONF_NONINTERACTIVE_SEEN=true &&\
    rm -rf /etc/localtime &&\
    rm -rf /etc/timezone &&\
    echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections &&\
    echo 'tzdata tzdata/Zones/Europe select Rome' | debconf-set-selections &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends tzdata &&\
    rm -rf /var/lib/apt/lists/*

# Updated clang ppa
ARG clang_version=9
ENV CLANG_VER=${clang_version}

# Build and development tools
RUN wget -nv -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs`-${CLANG_VER} main" &&\
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ `lsb_release -cs` main" &&\
    apt-get install -y kitware-archive-keyring &&\
    apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA &&\
    add-apt-repository ppa:ubuntu-toolchain-r/test &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        cmake \
        cmake-curses-gui \
        ninja-build \
        gcc-9 \
        g++-9 \
        llvm-${CLANG_VER} \
        clang-${CLANG_VER} \
        lldb-${CLANG_VER} \
        libclang-${CLANG_VER}-dev \
        clang-format-${CLANG_VER} \
        clang-tidy-${CLANG_VER} \
        libclang-common-${CLANG_VER}-dev \
        llvm-${CLANG_VER}-dev \
        libllvm${CLANG_VER} \
        gdb \
        valgrind \
        valkyrie \
        kcachegrind \
        ccache \
        cppcheck \
        doxygen \
        graphviz \
        lsof \
        net-tools \
        iputils-ping \
        strace \
        &&\
    rm -rf /var/lib/apt/lists/*

# Install and setup python tools
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python3-wheel \
        python3-pygments \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip3 install \
        python-language-server[all] \
        colour-valgrind \
        mkdocs \
        mkdocs-material

# Setup HW Acceleration for Intel graphic cards
RUN apt-get update &&\
    apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri &&\
    rm -rf /var/lib/apt/lists/*

# Packages with no ppa
# ====================

# QtCreator
ARG QTCREATOR_VERSION=4.11.1
COPY QtCreatorSetup.js /tmp/QtCreatorSetup.js
COPY qtaccount.ini /root/.local/share/Qt/qtaccount.ini
RUN cd /tmp &&\
    wget http://download.qt.io/official_releases/qtcreator/${QTCREATOR_VERSION%.*}/${QTCREATOR_VERSION}/qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run &&\
    chmod +x qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run &&\
    ./qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run --platform minimal --script QtCreatorSetup.js &&\
    rm /tmp/qt-creator-opensource-linux-x86_64-${QTCREATOR_VERSION}.run /tmp/QtCreatorSetup.js &&\
    ln -s /opt/qtcreator/bin/qtcreator.sh /usr/bin/qtcreator &&\
    rm /root/.local/share/Qt/qtaccount.ini

# Gitkraken
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        gconf2 \
        libgtk2.0-0 \
        gvfs-bin \
        libnotify4 \
        libnss3 \
        libxtst6 \
        libxkbfile1 \
        xdg-utils \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /tmp &&\
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb &&\
    apt install /tmp/gitkraken-amd64.deb &&\
    rm /tmp/gitkraken-amd64.deb

# rr
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        ccache \
        cmake \
        make \
        g++-multilib \
        gdb \
        pkg-config \
        python3-pexpect \
        manpages-dev \
        git \
        ninja-build \
        capnproto \
        libcapnp-dev \
	policykit-1 &&\
    rm -rf /var/lib/apt/lists/*

## Atom
ARG ATOM_VERSION=v1.40.1
ARG ATOM_PKG_TMP=/tmp/atom_packages.txt

RUN curl -L https://github.com/atom/atom/releases/download/${ATOM_VERSION}/atom-amd64.deb > /tmp/atom.deb && \
    dpkg -i /tmp/atom.deb && \
    rm -f /tmp/atom.deb && \
    echo "tool-bar" >> ${ATOM_PKG_TMP} &&\
    echo "indent-detective" >> ${ATOM_PKG_TMP} &&\
    echo "latex-completions" >> ${ATOM_PKG_TMP} &&\
    echo "hyperclick" >> ${ATOM_PKG_TMP} &&\ 
    apm install --packages-file ${ATOM_PKG_TMP} &&\
    cp -r /root/.atom /opt/dotatom &&\
    find /opt/dotatom -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# Extra tools
RUN \
    # Enable bash completion
    LINESTART=$(grep -nr "if ! shopt -oq posix; then" /etc/bash.bashrc | cut -d : -f1) &&\
    LINEEND=$((LINESTART+6)) &&\
    sed -i "$LINESTART,$LINEEND s/#*//" /etc/bash.bashrc

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM=1

# Setup an additional entrypoint script
COPY setup.sh /usr/sbin/setup_tools.sh
COPY entrypoint.sh /usr/sbin/entrypoint_tools.sh
RUN chmod 755 /usr/sbin/setup_tools.sh
RUN chmod 755 /usr/sbin/entrypoint_tools.sh
ENTRYPOINT ["/usr/sbin/entrypoint_tools.sh"]
CMD ["bash"]
