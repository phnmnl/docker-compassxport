# CompassXport Docker Buildfile

The first step in a metabolomics data processing workflow with Open
Source tools is the conversion to an open raw data format like
[mzML]:https://github.com/HUPO-PSI/mzML/ .

For Bruker instruments, one option is to use the CompassXport
command line tool available from the vendor. For licensing reasons,
we can not provide all files required to build this Docker image.
(The LICENSE file here only refers to the Dockerfile and build instructions,
not any files provided by Bruker)

Please head over to
https://www.bruker.com/service/support-upgrades/software-downloads/mass-spectrometry.html
to obtain the required CompassXport_3.0.9.2_Setup.exe installer, and
place it into this directory prior to running e.g.  `docker build -t
phnmnl/compassxport:3092-0.1 .`. **Update 2022**: Seems that CompassXport 
is not available from the Bruker website anymore. In case you find 
that file somewhere, make sure it was not maliciously modified. 
The checksum `sha256sum CompassXport_3.0.9.2_Setup.exe` should be 
`bc23a53f477548f45d7dfe3e73bb93490318a1e79f803c2e80a2d58d6ba2888c`.

Please also take note that CompassXport is a tool unsupported by
Bruker. You are welcome to use the product, but Bruker Daltonik
Technical Support cannot provide support for the troubleshooting,
see below for an excerpt from their ReleaseNotes, and check the
installation package CompassXport_*_Setup.exe for the full information.

After building the image, the conversion can be started with e.g. 

`docker run -v $PWD:/data phnmnl/compassxport:3092-0.1 -multi /data/neg-MM8_1-A,1_01_376.d/ -o
/data`

`docker run -v $PWD:/data --rm -it sneumann/compassxport:3092-0.2 -multi z:/data/neg-MM8_1-A,1_01_376.d -mode 2`

Excerpt from the Bruker ReleaseNotes:

````
CompassXport is not Freeware. After unpacking you will find the
License text in the ReadMe.txt file. The right to use the Software is
provided only on the condition that you ("Licensee") agree to this
Agreement.  If you do not agree to the terms of this Agreement, you
may not install the Software. However, installing the Software
indicates your acceptance of this Agreement.

CompassXport is an unsupported tool. You are welcome to use the
product, but Bruker Daltonik Technical Support cannot provide support
for the troubleshooting of CompassXport. We cannot guarantee that
we'll be able to respond to all requests and fix all
issues. Nevertheless, if you ever get into difficulties using
CompassXport you may find helpful information in an FAQ document
provided on our CompassXport download site.

CompassXport is a 'raw data' export tool, and supports 
different XML formats.

Export is currently provided for the following Bruker Daltonics MS raw data
formats:

- analysis.baf (instrument families: APEX, micrOTOF, micOTOF-Q, ...)
- analysis.yep (esquire instrument family)
- AutoXecute run for LCMaldi (instrument family: autoFlex, ultraFlex, ...)
- fid files (flex instrument family)

````


