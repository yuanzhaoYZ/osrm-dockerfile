FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y build-essential git cmake pkg-config \
libbz2-dev libstxxl-dev libstxxl1v5 libxml2-dev \
libzip-dev libboost-all-dev lua5.2 liblua5.2-dev libtbb-dev

RUN mkdir -p /osrm
RUN git clone git://github.com/Project-OSRM/osrm-backend.git /osrm
RUN mkdir -p /osrm/build
WORKDIR /osrm/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN cmake --build .
RUN cmake --build . --target install
RUN ln -s /osrm/profiles/car profile.lua
RUN ln -s /osrm/profiles/lib/ lib
RUN echo "disk=/tmp/stxxl,0,syscall" > /osrm/build/.stxxl


WORKDIR /osrm/build
ADD map.osm.pbf map.osm.pbf
RUN ./osrm-extract /osrm/build/map.osm.pbf
RUN ./osrm-prepare /osrm/build/map.osrm

EXPOSE 5000
CMD ["/osrm/build/osrm-routed", "/osrm/build/map.osrm", "-p", "5000"]
