FROM i386/debian:stretch-backports

################################################################################
### set metadata
ENV TOOL_NAME=CompassXport
ENV TOOL_VERSION=3.0.9.2
ENV CONTAINER_VERSION=0.2
ENV CONTAINER_GITHUB=https://github.com/phnmnl/container-compassxport

LABEL version=0.2
LABEL software.version=3.0.9.2
LABEL software=CompassXport
LABEL base.image="i386/debian:stretch-backports"
LABEL description="Convert Bruker LC/MS files to mzML."
LABEL website=https://github.com/phnmnl/container-compassxport
LABEL documentation=https://github.com/phnmnl/container-compassxport
LABEL license=https://github.com/phnmnl/container-compassxport
LABEL tags="Metabolomics"

# we need wget, bzip2, wine from winehq, 
# xvfb to fake X11 for winetricks during installation,
# and winbind because wine complains about missing 
# unrar from non-free is for the CompassXtract self-extracting archive 
RUN sed -i -e 's/main/main non-free/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get -y install wget gnupg && \
    echo "deb http://dl.winehq.org/wine-builds/debian/ stretch main" >> \
      /etc/apt/sources.list.d/winehq.list && \
    wget http://dl.winehq.org/wine-builds/Release.key -qO- | apt-key add - && \
    apt-get update && \
    apt-get -y --install-recommends --allow-unauthenticated install \
      bzip2 unzip curl \
      winehq-devel \
      winbind \
      xvfb \
      cabextract \
      unrar \
      && \
    apt-get -y clean && \
    rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      && \
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
      -O /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

# Create a 32bit wineprefix 
ENV WINEARCH win32
ENV WINEDEBUG -all,err+all
ENV DISPLAY :0

# To be singularity friendly, avoid installing anything to /root
RUN mkdir /wineprefix/
ENV WINEPREFIX /wineprefix
WORKDIR /wineprefix

## Create non-root user
RUN useradd -ms /bin/bash wineuser
RUN chown -R wineuser /wineprefix

# wineserver needs to shut down properly, so have a script to wait for it
ADD waitonprocess.sh /wineprefix/waitonprocess.sh
RUN chmod +x /wineprefix/waitonprocess.sh

ADD mywine /usr/local/bin/
RUN chmod +x /usr/local/bin/mywine

USER wineuser
WORKDIR /home/wineuser


# Install windows dependencies
RUN winetricks -q win7 && xvfb-run --auto-servernum winetricks -q vcrun2008 vcrun2012 corefonts && xvfb-run --auto-servernum winetricks -q dotnet452 && /wineprefix/waitonprocess.sh wineserver

##
## Now the Bruker libraries
##

# Install CompassXport
COPY CompassXport_3.0.9.2_Setup.exe /tmp
RUN wine wineboot --init \
		&& /wineprefix/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run wine "/tmp/CompassXport_3.0.9.2_Setup.exe" /S /v/qn \
		&& /wineprefix/waitonprocess.sh wineserver

WORKDIR /wineprefix
# Unless copied, this DLL will not be found by CompassXport.exe
RUN cp "/wineprefix/drive_c/windows/winsxs/x86_Microsoft.VC90.MFC_1fc8b3b9a1e18e3b_9.0.30729.6161_x-ww_028bc148/mfc90.dll" "/wineprefix/drive_c/Program Files/Bruker Daltonik/CompassXport/"

WORKDIR /data
ENTRYPOINT [ "wine", "/wineprefix/drive_c/Program Files/Bruker Daltonik/CompassXport/CompassXport.exe" ]





#
# ENTRYPOINT ["/usr/bin/convert2cdf.sh"]
