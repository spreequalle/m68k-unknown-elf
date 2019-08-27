FROM alpine:3.10

ENV wd_build /build
ARG prefix='/opt/m68k-unknown-elf'
ENV PATH="${PATH}:${prefix}/bin"

ENV src_binutils 'https://ftp.gnu.org/gnu/binutils/binutils-2.28.1.tar.bz2'
ENV src_gcc 'https://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2'

# add native toolchain
RUN apk --update add build-base texinfo gmp-dev mpc1-dev mpfr-dev

CMD mkdir -p ${wd_build}
WORKDIR ${wd_build}

# download toolchain sources
RUN wget ${src_binutils} && wget ${src_gcc}

# build binutils
RUN tar xf $(basename ${src_binutils}) && \
mkdir binutils && cd binutils && \
../$(basename ${src_binutils} .tar.bz2)/configure --prefix=${prefix} --target=m68k-unknown-elf && \
make -s -j$(nproc) && make install

# build gcc
RUN tar xf $(basename ${src_gcc}) && \
mkdir gcc && cd gcc && \
../$(basename ${src_gcc} .tar.bz2)/configure --prefix=${prefix} --target=m68k-unknown-elf --enable-languages=c --disable-libssp && \
make -s -j$(nproc) && make install

# cleanup
RUN apk del build-base texinfo && rm -rf ${wd_build}
