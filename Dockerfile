FROM centos:5
RUN rm -f /etc/yum.repos.d/*
ADD CentOS-Vault.repo /etc/yum.repos.d/
RUN echo 'exclude = *.i?86' >> /etc/yum.conf
RUN echo /usr/local/lib > /etc/ld.so.conf.d/local.conf && echo /usr/local/lib64 >> /etc/ld.so.conf.d/local.conf
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig
ARG NUM_CPU=24
RUN yum install -y curl bzip2 gcc-c++ make m4 file pkgconfig perl expat-devel zlib-devel gettext \
    which openssh-clients rsync bzip2-devel readline-devel mesa-libGLU-devel man xz \
    && yum clean all && rm -rf /usr/share/locale
ADD clean /root/
WORKDIR /tmp

# OpenSSL
RUN curl https://www.openssl.org/source/openssl-1.0.2n.tar.gz | tar xz \
    && cd * \
    && ./config --prefix=/usr/local --openssldir=/usr/local shared \
    && make && make install \
    && rm /usr/local/lib64/libcrypto.a /usr/local/lib64/libssl.a \
    && /root/clean

# Curl
RUN curl http://cdn-fastly.deb.debian.org/debian/pool/main/c/curl/curl_7.56.1.orig.tar.gz | tar xz \
    && cd * && ./configure --disable-static && make -j $NUM_CPU && make install \
    && yum remove -y curl expat-devel && /root/clean \
    && curl https://curl.haxx.se/ca/cacert.pem -o /etc/pki/tls/certs/ca-bundle.crt

# Binutils
RUN curl https://ftp.gnu.org/gnu/binutils/binutils-2.29.1.tar.bz2 | tar xj \
    && mkdir build && cd build && ../binutils-2.29.1/configure \
    && make -j $NUM_CPU && make install && /root/clean

# GMP
RUN curl https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2 | tar xj \
    && mkdir build && cd build && ../gmp-6.1.2/configure \
    && make -j $NUM_CPU install && /root/clean

# mpfr
RUN curl https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.bz2 | tar xj \
    && mkdir build && cd build && ../mpfr-3.1.6/configure \
    && make -j $NUM_CPU install && /root/clean

# mpc
RUN curl http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz | tar xz \
    && mkdir build && cd build && ../mpc-1.0.3/configure \
    && make -j $NUM_CPU install && /root/clean

# gcc
RUN curl http://nl.mirror.babylon.network/gcc/releases/gcc-5.5.0/gcc-5.5.0.tar.gz | tar xz \
    && mkdir build && cd build \
    && ../gcc-5.5.0/configure --enable-languages=c,c++,fortran --disable-multilib \
    && make -j $NUM_CPU && make install \
    && strip /usr/local/libexec/gcc/x86_64-unknown-linux-gnu/5.5.0/* || true \
    && yum remove -y binutils libstdc++-devel \
    && cd /usr/local/bin && ln -s gcc cc && /root/clean

# python
RUN curl https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz | tar xz \
    && cd * && ./configure --enable-shared && make -j $NUM_CPU \
    && make install && /root/clean
# cmake
RUN curl https://cmake.org/files/v3.10/cmake-3.10.2.tar.gz | tar xz \
    && cd * && ./bootstrap && make -j $NUM_CPU \ 
    && make install && /root/clean
# chrpath
RUN curl https://alioth.debian.org/frs/download.php/file/3979/chrpath-0.16.tar.gz | tar xz \
    && cd * && ./configure && make install && /root/clean

# Git
RUN curl https://www.kernel.org/pub/software/scm/git/git-2.16.2.tar.gz | tar xz \
    && cd * && ./configure --prefix=/usr/local && make -j $NUM_CPU  \
    && make NO_INSTALL_HARDLINKS=YesPlease install && /root/clean

# Swig
RUN curl https://superb-dca2.dl.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz | tar xz \
    && cd * && ./configure --without-pcre && make -j $NUM_CPU && make install && /root/clean

# Autotools

RUN curl http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz | tar xz \
    && cd * && ./configure && make -j $NUM_CPU && make install && /root/clean
RUN curl https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz | tar xz \
    && cd * && ./configure && make -j $NUM_CPU && make install && /root/clean
RUN curl https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz | tar xz \
    && cd * && ./configure && make -j $NUM_CPU && make install && /root/clean

# hwloc
RUN curl https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.9.tar.bz2 | tar xj \
    && cd * && ./configure && make -j $NUM_CPU && make install && /root/clean

# nproc
RUN curl https://ftp.gnu.org/gnu/coreutils/coreutils-8.19.tar.xz | unxz | tar x \
    && cd * && FORCE_UNSAFE_CONFIGURE=1 ./configure && make -j $NUM_CPU \
    && cp src/nproc /usr/local/bin/ \
    && /root/clean
