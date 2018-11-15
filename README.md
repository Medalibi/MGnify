# MGnify
Docker files for Metagenomics Bioinformatics MGnify session.

## To run the container for the first time with generic graphics:
```
xhost +
docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix:rw -e DISPLAY=unix$DISPLAY \
-v $HOME/:/home/training/ --device /dev/dri --privileged --name mgnifty \
ebitraining/metagenomics:mgnifty
```
## To run with Nvidia graphics, add the following option:
```
-v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340
```
## To resume using an container:
```
docker exec -it mgnifty /bin/bash
```
## To build the container:
```
docker build -f ./Dockerfile -t mgnifty .
docker tag mgnifty ebitraining/metagenomics:mgnifty
docker push ebitraining/metagenomics:mgnifty
```
