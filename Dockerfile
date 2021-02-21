##################################
# Build
##################################
FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
COPY /build/install-pkgs.sh /install-pkgs.sh
RUN bash /install-pkgs.sh

ENV gvm_libs_version="v20.8.0" \
    openvas_scanner_version="v20.8.0" \
    gvmd_version="v20.8.0" \
    gsa_version="v20.8.0" \
    openvas_smb="v1.0.5"

RUN echo "Building..." && mkdir /build && mkdir /install

FROM build as build-gvm_libs
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/gvm-libs/archive/$gvm_libs_version.tar.gz && \
    tar -zxf $gvm_libs_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
RUN cd /install && \
    tar cvzf gvm_libs.tar.gz /usr/local/

FROM build as build-openvas_smb
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/openvas-smb/archive/$openvas_smb.tar.gz && \
    tar -zxf $openvas_smb.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
RUN cd /install && \
    tar cvzf openvas_smb.tar.gz /usr/local/

# Requires gvm_libs as dependency
FROM build-gvm_libs as build-gvmd
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/gvmd/archive/$gvmd_version.tar.gz && \
    tar -zxf $gvmd_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
RUN cd /install && \
    tar cvzf gvmd.tar.gz /usr/local/

# Requires gvm_libs as dependency
FROM build-gvm_libs as build-openvas_scanner
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/openvas-scanner/archive/$openvas_scanner_version.tar.gz && \
    tar -zxf $openvas_scanner_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
RUN cd /install && \
    tar cvzf openvas_scanner.tar.gz /usr/local/

# Requires gvm_libs as dependency
FROM build-gvm_libs as build-gsa
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/gsa/archive/$gsa_version.tar.gz && \
    tar -zxf $gsa_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
RUN cd /install && \
    tar cvzf gsa.tar.gz /usr/local/


FROM ubuntu:20.04
RUN mkdir /install && \
    mkdir /install/gvm_libs && \
    mkdir /install/openvas_smb && \
    mkdir /install/gvmd && \
    mkdir /install/openvas_scanner && \
    mkdir /install/gsa
COPY --from=build-gvm_libs /usr/local/ /install/gvm_libs
COPY --from=build-openvas_smb /usr/local/ /install/openvas_smb
COPY --from=build-gvmd /usr/local/ /install/gvmd
COPY --from=build-openvas_scanner /usr/local/ /install/openvas_scanner
COPY --from=build-gsa /usr/local/ /install/gsa



##################################
# Base
##################################
FROM ubuntu:20.04 
RUN bash /base/install-pkgs.sh
RUN bash /base/baseenv.sh
COPY --from=SCS-labs/gvm:build-20.8 /install/gvm_libs/ /usr/local/
COPY --from=SCS-labs/gvm:build-20.8 /install/gvmd/bin/gvm-manage-certs /usr/local/bin/gvm-manage-certs
COPY modules/base/root/ /

##################################
# GVM
##################################
FROM SCS-labs/gvm:openvas-20.8
RUN bash /gvm/install-pkgs.sh
COPY --from=SCS-labs/gvm:build-20.8 /install/gvmd/ /install/gsa/ /usr/local/
#Grab report_formats from previous version so they can be migrated in case of an upgrade
COPY --from=SCS-labs/gvm:gvm-11 /usr/local/share/gvm/gvmd/report_formats/ /usr/local/share/gvm/gvmd/report_formats/
RUN echo "abc ALL=(ALL) NOPASSWD: /usr/local/sbin/gsad" >> /etc/sudoers
COPY modules/gvm/root/ /

##################################
# OpenVAS
##################################
FROM SCS-labs/gvm:base-20.8
RUN bash /openvas/install-pkgs.sh
COPY --from=SCS-labs/gvm:build-20.8 /install/openvas_smb/ /install/openvas_scanner/ /usr/local/
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openvas.conf && ldconfig
RUN echo "abc ALL=(ALL) NOPASSWD: /usr/local/sbin/openvas" >> /etc/sudoers
COPY modules/openvas/root/ /










