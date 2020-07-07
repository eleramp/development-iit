ARG from=eleramp/tools:latest
FROM ${from}

# Install ROS Desktop Full
# ========================

# https://github.com/osrf/docker_images/blob/master/ros/
ENV ROS_DISTRO melodic

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
                --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 &&\
    echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" \
        > /etc/apt/sources.list.d/ros-latest.list
RUN apt-get update &&\
    apt-get install --no-install-recommends -y \
        python-rosdep \
        python-rosinstall \
        python-vcstools \
        &&\
    rm -rf /var/lib/apt/lists/* &&\
    rosdep init &&\
    rosdep update
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        # ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-desktop-full \
        #ros-${ROS_DISTRO}-fake-localization \
        #ros-${ROS_DISTRO}-map-server \
        &&\
    rm -rf /var/lib/apt/lists/*

# Install libraries and tools
# ===========================

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        gcc-8 \
        g++-8 \
        # libfranka
        libeigen3-dev \
        libpoco-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        python-yaml \
        python-numpy \
        python-setuptools \
        # MoveIt
        python-wstool \
        python-catkin-tools \
        clang-format-3.9 \
        # ipopt
        file \
        gfortran \
        # swig
        autotools-dev \
        automake \
        bison \
        libpcre3-dev \
        &&\
    rm -rf /var/lib/apt/lists/*


# Install Panda related libs: franka, franka_ros and MoveIt
# =========================================================

# Environment setup of the robotology repositories
# ------------------------------------------------

ENV IIT_DIR=/iit
ENV CATKIN_WS_DIR=/catkin_ws
ENV IIT_INSTALL=${IIT_DIR}/local
ENV IIT_SOURCES=${IIT_DIR}/sources
ARG IIT_BIN=${IIT_INSTALL}/bin

# Download all sources with git
# -----------------------------

# Use docker cache for steps above
ARG IIT_DOCKER_SOURCES="20200217"

ENV CC="gcc-8"
ENV CXX="g++-8"

# Libs to control Panda robot
# ===========================


RUN apt-get update &&\
    apt install -y --no-install-recommends \
        ros-${ROS_DISTRO}-libfranka \
        ros-${ROS_DISTRO}-franka-ros \
        ros-${ROS_DISTRO}-moveit &&\
    rm -rf /var/lib/apt/lists/*


# Install superquadric-lib and its dependencies: VTK, ipopt, SWIG
# ===============================================================

# VTK
RUN mkdir -p ${IIT_SOURCES} && cd ${IIT_SOURCES} &&\
    git clone https://gitlab.kitware.com/vtk/vtk.git && \
    cd vtk && git checkout tags/v8.2.0 &&\
    mkdir -p build && cd build && \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
      -DVTK_PYTHON_VERSION=3 \
      -DVTK_WRAP_PYTHON=ON \
      .. && \
    cmake --build . --target install -j8 &&\
    rm -rf ${IIT_SOURCES}/vtk &&\
    find ${IIT_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

# SWIG
RUN cd ${IIT_SOURCES} &&\
    curl https://netcologne.dl.sourceforge.net/project/swig/swig/swig-4.0.1/swig-4.0.1.tar.gz | tar xvz &&\
    cd swig-4.0.1 &&\
    ./configure && \
    make -j2 &&\
    make install &&\
    rm -r ${IIT_SOURCES}/swig-4.0.1


# IPOPT
RUN mkdir -p ${IIT_SOURCES}/ipopt_tmp && cd ${IIT_SOURCES}/ipopt_tmp &&\
    curl -o coinbrew https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew &&\
    chmod +x coinbrew &&\
    ./coinbrew fetch Ipopt:releases/3.13.0 --no-prompt &&\
    ./coinbrew build Ipopt --prefix=${IIT_INSTALL} --no-prompt &&\
    ./coinbrew install Ipopt --no-prompt && \
    rm -rf ${IIT_SOURCES}/ipopt_tmp &&\
    find ${IIT_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+


ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${IIT_INSTALL}/lib
ENV IPOPT_DIR=${IIT_INSTALL}

#COPY FindIPOPT.cmake ${IIT_SOURCES}/superquadric-lib/src/SuperquadricLib/SuperquadricModel/cmake/FindIPOPT.cmake

# Install superquadric-lib
RUN cp ${IIT_INSTALL}/include/coin-or/* ${IIT_INSTALL}/include/coin/ && \
    cd ${IIT_SOURCES} &&\
    git clone -b bindings https://github.com/eleramp/superquadric-lib.git && \
    cd ${IIT_SOURCES}/superquadric-lib &&\
    mkdir -p build && cd build &&\
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
        -DENABLE_BINDINGS=ON \
        -DYARP_EXE=OFF \
        -DVTK_DIR=${IIT_INSTALL}/lib/cmake/vtk-8.2 \
        .. &&\
    cmake --build . --target install -j8 &&\
    find ${IIT_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${IIT_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+

ENV PYTHONPATH=${PYTHONPATH}:${IIT_INSTALL}/lib/superquadriclib/bindings


# =============
# FIX OWNERSHIP
# =============

RUN find ${IIT_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${IIT_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+


# Misc setup of the image
# =======================

# Include a custom bashrc
COPY bashrc /usr/etc/skel/bashrc-dev
COPY bashrc-colors /usr/etc/skel/bashrc-colors
COPY bashrc-functions /usr/etc/skel/bashrc-functions

# Include an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint_development.sh
COPY setup.sh /usr/sbin/setup_development.sh
RUN chmod 755 /usr/sbin/entrypoint_development.sh && \
    chmod 755 /usr/sbin/setup_development.sh
ENTRYPOINT ["/usr/sbin/entrypoint_development.sh"]
CMD ["bash"]
