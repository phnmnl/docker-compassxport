`singularity exec -B $PWD/:/data -B `mktemp -d /dev/shm/wineXXX`:/mywineprefix /vol/kubernetes/Singularity/images/sneumann_compassxport_3092-0.2-2019-05-28-a9d49c801c88.simg mywine "/wineprefix/drive_c/Program Files/Bruker Daltonik/CompassXport/CompassXport.exe" -multi z:/data/89_Col0_S_CSH_neg_swath_81118_RC5_01_12292.d  -mode 2`

Build:
`docker build -t sneumann/compassxport:3092-0.2 .`
`docker run -v /var/run/docker.sock:/var/run/docker.sock -v /vol/kubernetes/Singularity/images/:/output --privileged -t --rm   singularityware/docker2singularity sneumann/compassxport:3092-0.2`

Run:
`singularity exec -B $PWD/:/data -B `mktemp -d /dev/shm/wineXXX`:/mywineprefix /vol/kubernetes/Singularity/images/sneumann_compassxport_3092-0.2-2019-05-28-e6c4157ba445.simg xvfb-run mywine "/wineprefix/drive_c/Program Files/Bruker Daltonik/CompassXport/CompassXport.exe" -a z:/data/neg-MM8_1-A,1_01_376.d -mode 2 -o z:/data `