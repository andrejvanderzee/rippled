FROM ubuntu:18.10

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get -y install git pkg-config protobuf-compiler libprotobuf-dev libssl-dev wget
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3-Linux-x86_64.sh && \
    sh cmake-3.13.3-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir
RUN wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz && \
    tar xvzf boost_1_67_0.tar.gz && \
    cd boost_1_67_0 && \
    ./bootstrap.sh && \
    ./b2 -j 4
ENV BOOST_ROOT=/boost_1_67_0

RUN git clone https://github.com/ripple/rippled.git && \
    cd rippled && \
    git checkout master && \
    git log -1
WORKDIR rippled
RUN mkdir my_build && \
    cd my_build && \
    cmake ..  && \
    cmake --build .
