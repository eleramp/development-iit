ARG from=eleramp/tools:latest
FROM ${from}

# Build-time metadata as defined at http://label-schema.org
# ARG BUILD_DATE
# ARG VCS_REF
# ARG VERSION=0.9
LABEL \
    maintainer="Elena Rampone <elena.rampone18@gmail.com>" \
    # org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="development" \
    org.label-schema.description="" \
    org.label-schema.url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/eleramp/development-iit" \
    # org.label-schema.vendor="" \
    # org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

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

ENV CC=clang-${CLANG_VER}
ENV CXX=clang++-${CLANG_VER}

# LIBFRANKA
RUN mkdir -p ${IIT_SOURCES} &&\
    cd ${IIT_SOURCES} &&\
    git clone --recursive https://github.com/frankaemika/libfranka && \
    cd libfranka && \
    mkdir -p build && cd build && \
    cmake \
    -DCMAKE_INSTALL_PREFIX=${IIT_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target install -j8 &&\
    find ${IIT_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    find ${IIT_INSTALL} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+


# FRANKA_ROS
RUN /bin/bash -c "apt-get update &&\
    mkdir -p ${CATKIN_WS_DIR}/src && \
    cd ${CATKIN_WS_DIR} && \
    source /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_init_workspace src && \
    git clone --recursive https://github.com/frankaemika/franka_ros src/franka_ros && \
    rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys libfranka && \
    catkin config --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=Release -DFranka_DIR:PATH=${IIT_SOURCES}/libfranka/build &&\
    catkin build &&\
    find ${CATKIN_WS_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    echo 'source ${CATKIN_WS_DIR}/devel/setup.sh' >> /etc/bash.bashrc"


# MOVE-IT
RUN /bin/bash -c "apt-get update &&\
    apt-get install -y libomp-dev &&\
    cd ${CATKIN_WS_DIR} && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    wstool init src && \
    wstool merge -t src https://raw.githubusercontent.com/ros-planning/moveit/master/moveit.rosinstall && \
    wstool update -t src &&\
    rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} &&\
    catkin config --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=Release &&\
    catkin config --blacklist \
            moveit_ros_robot_interaction \
            moveit_ros_benchmarks \
            moveit_controller_manager_example \
            moveit_ros_perception \
            moveit_ros_manipulation \
            moveit_ros_warehouse &&\
    catkin build moveit &&\
    find ${CATKIN_WS_DIR} -not -group runtimeusers -exec chgrp runtimeusers {} \; -exec chmod g+rw {} \+ &&\
    echo 'source ${CATKIN_WS_DIR}/devel/setup.bash' >> /etc/bash.bashrc"

# Install superquadric-lib and its dependencies: VTK, ipopt, SWIG
# ==========================================

ENV CC="gcc-8"
ENV CXX="g++-8"

# VTK
RUN cd ${IIT_SOURCES} &&\
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

# SWIG
RUN cd ${IIT_SOURCES} &&\
    curl https://netcologne.dl.sourceforge.net/project/swig/swig/swig-4.0.1/swig-4.0.1.tar.gz | tar xvz &&\
    cd swig-4.0.1 &&\
    ./configure && \
    make -j2 &&\
    make install &&\
    rm -r ${IIT_SOURCES}/swig-4.0.1

# COPY FindIPOPT.cmake ${IIT_SOURCES}/superquadric-lib/src/SuperquadricLib/SuperquadricModel/cmake/FindIPOPT.cmake

# Install superquadric-lib
RUN mv ${IIT_INSTALL}/include/coin-or/ ${IIT_INSTALL}/include/coin/ && \
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
RUN chmod 755 /usr/sbin/entrypoint_development.sh
RUN chmod 755 /usr/sbin/setup_development.sh
ENTRYPOINT ["/usr/sbin/entrypoint_development.sh"]
CMD ["bash"]
