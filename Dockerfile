FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y build-essential git cmake pkg-config libprotoc-dev libprotobuf8 protobuf-compiler libprotobuf-dev libosmpbf-dev libpng12-dev libbz2-dev libstxxl-dev libstxxl-doc libstxxl1 libxml2-dev libzip-dev libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libluajit-5.1-dev libtbb-dev
RUN apt-get install -y software-properties-common python-software-properties

RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update \
    && apt-get install -y gcc-4.9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 20 \
    && update-alternatives --config gcc

RUN mkdir -p /osrm
RUN git clone git://github.com/Project-OSRM/osrm-backend.git /osrm
RUN mkdir -p /osrm/build
WORKDIR /osrm/build
RUN cmake ..
RUN make
RUN ln -s /osrm/profiles/bicycle.lua profile.lua
RUN ln -s /osrm/profiles/lib/ lib
RUN echo "disk=/tmp/stxxl,0,syscall" > /osrm/build/.stxxl

RUN apt-get --purge remove -y build-essential git cmake pkg-config libprotoc-dev protobuf-compiler libprotobuf-dev libosmpbf-dev libpng12-dev libbz2-dev libstxxl-dev libstxxl-doc libxml2-dev libzip-dev libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libluajit-5.1-dev libtbb-dev
RUN apt-get clean

WORKDIR /osrm/build
ADD map.osm.pbf map.osm.pbf
RUN ./osrm-extract /osrm/build/map.osm.pbf
RUN ./osrm-prepare /osrm/build/map.osrm

EXPOSE 80
CMD ["/osrm/build/osrm-routed", "/osrm/build/map.osrm", "-p", "80"]
