FROM suchja/wine:dev

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

# Install CompassXport
# https://www.bruker.com/de/service/support-upgrades/software-downloads/mass-spectrometry.html
COPY CompassXport_3.0.9.2_Setup.exe /tmp

# unfortunately we later need to wait on wineserver.
# Thus a small script for waiting is supplied.
USER root
COPY waitonprocess.sh /scripts/
RUN chmod +x /scripts/waitonprocess.sh

## Freshen package index
RUN apt-get update

## Get dummy X11 server
RUN apt-get install -y xvfb winbind cabextract

# You might need a proxy:
# ENV http_proxy http://www-cache.ipb-halle.de:3128

# WINE does not like running as root
USER xclient

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# Install Visual Runtime
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run winetricks --unattended vcrun2008 \
		&& /scripts/waitonprocess.sh wineserver

# Install Visual Runtime
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run winetricks --unattended msxml3 \
		&& /scripts/waitonprocess.sh wineserver

# Install .NET Framework 3.5sp1
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run winetricks --unattended dotnet35sp1 \
		&& /scripts/waitonprocess.sh wineserver

# Install .NET Framework 4.0
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run winetricks --unattended dotnet40 dotnet_verifier \
		&& /scripts/waitonprocess.sh wineserver

# Install CompassXport
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& /usr/bin/xvfb-run wine "/tmp/CompassXport_3.0.9.2_Setup.exe" /S /v/qn \
		&& /scripts/waitonprocess.sh wineserver

# Unless copied, this DLL will not be found by CompassXport.exe
RUN cp ".wine/drive_c/windows/winsxs/x86_Microsoft.VC90.MFC_1fc8b3b9a1e18e3b_9.0.30729.6161_x-ww_028bc148/mfc90.dll" "/home/xclient/.wine/drive_c/Program Files/Bruker Daltonik/CompassXport/"

WORKDIR /data
ENTRYPOINT [ "wine", "/home/xclient/.wine/drive_c/Program Files/Bruker Daltonik/CompassXport/CompassXport.exe" ]
