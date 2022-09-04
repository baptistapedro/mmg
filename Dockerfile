FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libjpeg-dev libpng-dev libssl-dev freeglut3-dev
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.1/cmake-3.20.1.tar.gz
RUN tar xvfz cmake-3.20.1.tar.gz
WORKDIR /cmake-3.20.1
RUN ./bootstrap
RUN make
RUN make install
WORKDIR /
RUN git clone https://github.com/Kitware/VTK.git
WORKDIR /VTK
RUN mkdir build
WORKDIR /VTK/build
RUN cmake ..
RUN make
RUN make install
WORKDIR /
RUN git clone https://github.com/MmgTools/mmg.git
WORKDIR /mmg
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN make install
RUN mkdir /mmgCorpus
RUN cp ./libexamples/mmg/adaptation_example0_cpp/cube.meshb /mmgCorpus

ENTRYPOINT ["afl-fuzz", "-m", "2048", "-i", "/mmgCorpus", "-o", "/mmgOut"]
CMD ["/mmg/bin/mmgs_O3", "@@"]
