FROM debian:latest
# Install other dependencies
RUN apt update && apt upgrade
RUN apt-get install -y bash make nasm

# Download gcc dependencies 
RUN apt-get install -y wget gcc build-essential	bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev
RUN mkdir /opt/cross && mkdir /source && mkdir /source/build-binutils

# Build binutils
WORKDIR /source/build-binutils

RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz
RUN tar -xzf binutils-2.40.tar.gz && rm *.tar.gz

WORKDIR binutils-2.40
RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && ./configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
RUN make -j 4 && make install -j 4

# Build gcc
WORKDIR /source/build-gcc
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz
RUN tar -xzf gcc-13.1.0.tar.gz && rm *.tar.gz

RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && ./gcc-13.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && make all-gcc -j 6
RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && make all-target-libgcc -j 4 
RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && make install-gcc -j 4 
RUN export PREFIX="/bin" && export TARGET=amd64-elf && export PATH="$PREFIX/bin:$PATH" && make install-target-libgcc -j 4

WORKDIR /
RUN rm -rf /source
RUN mkdir melonos && mkdir melonos/kernel && mkdir melonos/bootloader
WORKDIR /melonos