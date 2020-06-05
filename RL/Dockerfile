ARG from=diegoferigo/development:nvidia-master
FROM ${from}

# Build-time metadata as defined at http://label-schema.org
# ARG BUILD_DATE
# ARG VCS_REF
# ARG VERSION=0.9
LABEL \
    maintainer="Elena Rampone <elena.rampone18@gmail.com>" \
    # org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="rl" \
    org.label-schema.description="" \
    org.label-schema.url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vendor="" \
    # org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

ENV RL_DIR=/rl
ENV RL_INSTALL=${RL_DIR}/local
ENV RL_SOURCES=${RL_DIR}/sources
ENV DEVENV_PATH=${RL_INSTALL}/bin:${DEVENV_PATH}
ENV CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:${RL_INSTALL}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${RL_INSTALL}/lib

ENV CC="gcc-8"
ENV CXX="g++-8"

# Common tools
RUN apt-get update &&\
    export DEBIAN_FRONTEND=noninteractive &&\
    export DEBCONF_NONINTERACTIVE_SEEN=true &&\
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        apt-utils \
        gnupg \
        gnupg2 \
        locales \
        curl \
        lsb-release \
        software-properties-common \
        wget \
        libxml2-dev \
        python3-tk \
        ssh \
        &&\
    rm -rf /var/lib/apt/lists/*

# Development tools
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - &&\
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ `lsb_release -cs` main" &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        cmake-curses-gui \
        build-essential \
        gcc-8 \
        g++-8 \
        ninja-build \
        mercurial \
        python3-pip \
        xvfb \
        python-setuptools \
        python3-setuptools \
        libpython-dev \
        libpython3-dev \
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


# Create a new runtimeusers group (it might be already present)
RUN groupadd runtimeusers || true

# ===========================
# Setup the python virtualenv
# ===========================

ENV VIRTUAL_ENV=/rl/ve
ENV DEVENV_PATH=${VIRTUAL_ENV}/bin:$DEVENV_PATH
RUN pip3 install urllib3 && pip3 install virtualenv

RUN virtualenv ${VIRTUAL_ENV} &&\
    ${VIRTUAL_ENV}/bin/pip3 install \
	setuptools \
        gym \
        pybullet \
        matplotlib \
        pandas \
        ruamel.yaml \
        tensorflow==1.* \
        stable_baselines \
        numpy \
        numpy-quaternion \
        trimesh \
        seaborn \
        baselines \
        imageio \
        mpi4py \
        &&\
    #${VIRTUAL_ENV}/bin/pip3 install git+https://github.com/tensorflow/agents &&\#
    #${VIRTUAL_ENV}/bin/pip3 install --upgrade --force-reinstall tb-nightly &&\#
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# ===============
# Install PyCharm
# ===============

ARG PYCHARM_VER=2019.3.3
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        python-setuptools \
        python3-setuptools \
        libpython-dev \
        libpython3-dev \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    cd /opt && mkdir pycharm && cd pycharm &&\
    curl -L https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VER}.tar.gz -o /opt/pycharm/installer.tgz &&\
    tar --strip-components=1 -xzf installer.tgz &&\
    rm installer.tgz &&\
    python2 /opt/pycharm/plugins/python-ce/helpers/pydev/setup_cython.py build_ext --inplace &&\
    python3 /opt/pycharm/plugins/python-ce/helpers/pydev/setup_cython.py build_ext --inplace &&\
    ln -s /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm


# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    sudo apt-get install git-lfs &&\
    git lfs install


# =======================
# Install projects for RL
# =======================

# THINGS TO INSTALL:
# pybullet-robot-envs
# robot-agents
# ycb-objects-models-sim
# icub-model-pybullet

# Install pybullet-robot-envs
RUN mkdir -p ${RL_SOURCES} && cd ${RL_SOURCES} &&\
    git clone -b devel_sq_rl https://github.com/eleramp/pybullet-robot-envs.git &&\
    cd pybullet-robot-envs && ${VIRTUAL_ENV}/bin/pip3 install -e . &&\
    find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# Install robot-agents
RUN cd ${RL_SOURCES} &&\
    git clone https://github.com/eleramp/robot-agents.git &&\
    cd robot-agents && ${VIRTUAL_ENV}/bin/pip3 install -e . &&\
    find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# Install pybullet-object-models
RUN cd ${RL_SOURCES} &&\
    git clone https://github.com/eleramp/pybullet-object-models.git &&\
    cd pybullet-object-models && ${VIRTUAL_ENV}/bin/pip3 install -e . &&\
    cd ${RL_SOURCES}/pybullet-object-models/pybullet_object_models/superquadric_objects/ &&\
    ${VIRTUAL_ENV}/bin/python generate_urdf_model.py &&\
    ${VIRTUAL_ENV}/bin/python generate_dataset.py && \
    find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ 

# Install icub-model-pybullet
RUN cd ${RL_SOURCES} &&\
    git clone https://github.com/eleramp/icub-model-pybullet.git &&\
    cd icub-model-pybullet && ${VIRTUAL_ENV}/bin/pip3 install -e . &&\
    find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+



# =============
# FIX OWNERSHIP
# =============

RUN find ${RL_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${VIRTUAL_ENV} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# ====================
# Image initialization
# ====================

COPY setup.sh /usr/sbin/setup_rl.sh
COPY entrypoint.sh /usr/sbin/entrypoint_rl.sh
RUN chmod 755 /usr/sbin/setup_rl.sh
RUN chmod 755 /usr/sbin/entrypoint_rl.sh
ENTRYPOINT ["/usr/sbin/entrypoint_rl.sh"]
CMD ["bash"]
