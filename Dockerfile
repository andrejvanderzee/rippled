FROM ubuntu:18.10

ARG CMAKE_VERSION=3.13.3
ARG BOOST_VERSION=1.67.0

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

WORKDIR /usr/local
RUN apt-get -y install git pkg-config protobuf-compiler libprotobuf-dev libssl-dev wget
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    sh cmake-$CMAKE_VERSION-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir
RUN BOOST_HANDLE=boost_$(echo $BOOST_VERSION | sed 's/\./_/g') && \
    wget https://dl.bintray.com/boostorg/release/$BOOST_VERSION/source/$BOOST_HANDLE.tar.gz && \
    tar xvzf $BOOST_HANDLE.tar.gz && \
    cd $BOOST_HANDLE && \
    ./bootstrap.sh && \
    ./b2 -j 4
ENV BOOST_ROOT=/usr/local/$BOOST_HANDLE

RUN apt-get -y install git pkg-config protobuf-compiler libprotobuf-dev libssl-dev wget
RUN groupadd -g 1000 -r ripple && \
    useradd -u 1000 -m -d /home/ripple -r -g ripple ripple
USER ripple
WORKDIR /home/ripple

RUN git clone https://github.com/ripple/rippled.git && \
    cd rippled && \
    git checkout master && \
    git log -1
WORKDIR rippled
RUN mkdir my_build && \
    cd my_build && \
    cmake ..  && \
    cmake --build .

USER root
RUN apt-get install -y build-essential vim python3-dev libclang-7-dev doxygen graphviz tree

ARG GO_VERSION=1.12.6
RUN cd /usr/local && \
    wget -q https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz && \
    tar -xzf  go$GO_VERSION.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

USER ripple
COPY vimrc /home/ripple/.vimrc
RUN mkdir -p /home/ripple/.vim/bundle && \
    git clone https://github.com/VundleVim/Vundle.vim.git /home/ripple/.vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall && \
    cd /home/ripple/.vim/bundle/YouCompleteMe && \
    python3 install.py --clang-completer --go-completer

#USER root
#RUN apt-get install -y clang git python python-dev ctags ncurses-term libxt6 libx11-6 nodejs \
#    make libxpm-dev libx11-dev libxt-dev ncurses-dev curl npm
#RUN cd /usr/local && \
#    git clone --depth=1 https://github.com/vim/vim && \
#    cd /usr/local/vim && \
#    ./configure --with-features=big \
#                --enable-multibyte \
#                --enable-pythoninterp \
#                --with-python-config-dir=/usr/lib/python2.7/config \
#                --disable-gui \
#                --disable-netbeans \
#                --prefix /usr && \
#    make install

USER ripple
WORKDIR /home/ripple
