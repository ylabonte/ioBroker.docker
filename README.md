[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/labonte/iobroker.svg?style=flat-square&logo=docker&logoColor=white)](https://hub.docker.com/r/labonte/iobroker/tags)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/labonte/iobroker.svg?style=flat-square&logo=docker&logoColor=white)](https://hub.docker.com/r/labonte/iobroker/builds)

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
docker run -d --name iob-temp -p 8081:8081 labonte/iobroker:node12-buster
docker exec -it iob-temp /bin/bash
```

The above will launch a container from my iobroker debian buster image with 
node 12. Inside the container you can do what you want to do... eg. install
ffmpeg inside the running container and do a little cleanup (that should
include removing the `~/.restore` which would cause the entrypoint script to 
skip the auto-run of the restore script on fist startup):

```bash
apt update && apt install -y ffmpeg && apt clean -y
rm ~/.restore
exit
```

And then commit running container state as your custom image (in this case we
tag it as `iobroker:latest`) and run the optimized image in detached mode for
_production_. 

```bash
docker container commit iob-temp iobroker:latest
docker container rm -f iob-temp
docker run -d --name iobroker -p 8081:8081 iobroker:latest
```


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
git clone https://github.com/ylabonte/ioBroker.docker.git
cd ioBroker.docker
docker build -t iobroker:latest .
docker run -d --name iobroker -p 8081:8081 iobroker:latest
```


#### ...directly from docker hub

I would only suggest this for testing reasons or if you want to build your
own image from a running container [as described above](#iobrokerdocker).

```bash
docker run -d --name iobroker -p 8081:8081 labonte/iobroker:latest
```


#### ...on your (Qnap) NAS with Container Station

It's not really restricted to Qnap NAS, but the example values are taken
from there and it's meant as inspiration for those who has a NAS with
Container Station or a similar product, that wraps a more or less user
friendly gui (that you do not want to use). Or anybody else who wants to
run the image _exposed to his lan instead of publishing single ports_.

See: [example-run-qnap.sh](./example-run-qnap.sh)


### Mounting volumes

#### Which type of volume/mount to use

The recommended docker mount type would be a (named) `volume`. This way you
will avoid trouble regarding permissions, because everything will be handled
within the docker ecosystem and will not influence your host filesystem.  
The counter part might be the lack of accessibility from host-system 
perspective. If you prefer to have easy access to the files inside a specific
volume, you should use a bind mount. So you will have to decide by your own,
which best suits your needs.

If you do not specify anything for the volumes defined in the Dockerfile,
docker will automatically create these volumes using random names, that look
like some cryptographic hash values. To list all volumes of your docker host,
you can run `docker volume ls`.

**Hint:** Think of a re-deployment! If you are using the volumes - which means
using the ioBroker backup in case of the _/opt/iobroker/backups_ volume and
respectivly using letsencrypt for _/etc/letsencrypt_ - you definitely should
specify the corresponding mount, because you at least have to, when re-
deploying a container that should make use of the persistent data.


#### (Named) volume mounts

As simple as the name suggests, you must only specify a name to make use of a
named volume. There are more things, you can do, but you should consult the
official documentation for further information.

The simplest way to run the image using named volumes would look like this:

```bash
docker run -d --name iobroker -p 8081:8081 \
    -v iob-backups:/opt/iobroker/backups \
    -v letsencrypt:/etc/letsencrypt \
    labonte/iobroker:latest
```


If you have files - let us say existing _ioBroker backups_ - on your host
system, you can run a tmp container mounting the volume and the director with
your existing backups, copy your backups from one to the other volume and then
launch your iobroker container. (This example assumes, you are using a 
node:12-buster based iobroker image... won't mess up your image cache with
unnecessary images.)

```bash
docker run -it --rm --entrypoint /bin/bash \
    -v iob-backups:/mnt/iob-backups \
    -v <path to your backups>:/mnt/old-backups \
    node:12-buster \
    -c 'cp -rf /mnt/old-backups/* /mnt/iob-backups/.'
```

Afterward you can run the your ioBroker container with your named volume and the
existing backups inside it.

```bash
docker run -d --name iobroker \
    -v iob-backups:/opt/iobroker/backups \
    -p 8081:8081 \
    labonte/iobroker:latest
```


#### Bind mounts

For some reason you might want to use a `bind` mount (specify the full path
of a file or directory on the host-system). 
The latter might cause problems regarding the directory ownership. You have
to so solve this problems by your own, if they occur...  
(Please consider this example assumes you have your backup dir located at 
_/mnt/backups_ on your host system.)

```bash
docker run -d --name iobroker \
    -v /mnt/backups:/opt/iobroker/backups \
    -p 8081:8081 \
    labonte/iobroker:latest
```


## License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
