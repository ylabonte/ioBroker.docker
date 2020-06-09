[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/labonte/iobroker.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/labonte/iobroker/tags)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/labonte/iobroker.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/labonte/iobroker/builds)

# ioBroker.docker
This is an example for running [ioBroker](https://www.iobroker.net/) in a 
docker container using [`node`](https://hub.docker.com/_/node) images as base.

I kept it slim and simple, so you can add your individual customizations eg.
install dependencies for a specific adapters. You can do so by extending the
Dockerfile or using one of my images to apply your changes to the running 
instance and aferwards create an image of that optimized container. The 
latter could look something like this (for the first one 
[see below](#built-by-your-own)):

```bash
$ docker run --name iob-temp -p 8081:8081 labonte/iobroker:node12-buster
$ docker exec -it iob-temp /bin/bash
# apt-get update && apt-get install -y ffmpeg && apt-get clean
# exit
$ docker container commit iob-temp iobroker:latest
$ docker container rm -f iob-temp
$ docker run --name iobroker -p 8081:8081 iobroker:latest
```

This would launch a container from my iobroker debian buster image with 
node 12, install ffmpeg inside the running container, do a little cleanup,
create a new local image called `iobroker:latest` from the running container,
removes the temporary container and finally relaunches ioBroker using the 
modified image.  
You could also add a `-c "<your-commands>"` to the second line, if you know
all necessary commands and want to automate the process with a script or
something like that.


## Available images and their base

Images are automatically built, when a base image is updated or there's a
new commit on one of the following Git branches in my repo.

| Git Branch       | Docker Image                     | Base Image       |
|:-----------------|:---------------------------------|:-----------------|
| `master`         | `labonte/iobroker:latest`        | `node:12-buster` |
| `node/12-alpine` | `labonte/iobroker:node12-alpine` | `node:12-alpine` |
| `node/12-buster` | `labonte/iobroker:node12-buster` | `node:12-buster` |
| `node/14-alpine` | `labonte/iobroker:node14-alpine` | `node:14-alpine` |
| `node/14-buster` | `labonte/iobroker:node14-buster` | `node:14-buster` |


## Contribution and help

Feel free to fork, suggest improvements or ask questions using 
[issues](https://github.com/ylabonte/ioBroker.docker/issues)
or share your knowledge, use cases, adaptions/customizations and other
suggestions using the [wiki](https://github.com/ylabonte/ioBroker.docker/wiki).


### Running the image...

**Note**  
Both are just examples. You might alter the _Dockerfile_, add your own
custom scripts or adapter specific dependencies, expose and/or publish
additional ports (`8081`, `8082`, `8083` and `8084` are already exposed)
or mount volumes (`/opt/iobroker/backups` and `/etc/letsencrypt` would be
the desired ones in my Dockerfile).


#### ...built by your own

I suggest, you just clone or fork the repo as a starting point for your
own image. I jsut wanted to keep it small and simple, so it is easy to
understand and adapt. So you may add your dependencies and maybe further
customizations between lines 2 and 3.

```bash
$ git clone https://github.com/ylabonte/ioBroker.docker.git
$ cd ioBroker.docker
$ docker build -t iobroker:latest .
$ docker run -d --name iobroker -p 8081:8081 iobroker:latest
```


#### ...directly from docker hub

I only suggest this for testing reasons or if you want to build  your own
image from a running container [as described above](#iobrokerdocker).

```bash
$ docker run -d --name iobroker -p 8081:8081 labonte/iobroker:latest
```
