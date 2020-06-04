![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/labonte/iobroker.svg?logo=docker&logoColor=white)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/labonte/iobroker.svg?logo=docker&logoColor=white)

# ioBroker.docker
Running [ioBroker](https://www.iobroker.net/) in docker using [`node`](https://hub.docker.com/_/node) images as base.

## Available images and their base
| Tag             | Base Image       |
|:----------------|:-----------------|
| `latest`        | `node:12-buster` |
| `node12-alpine` | `node:12-alpine` |
| `node12-buster` | `node:12-buster` |
| `node14-alpine` | `node:14-alpine` |
| `node14-buster` | `node:14-buster` |

## How to?

### Running the image

#### Note
Both are just examples. You might alter the _Dockerfile_, add your own
custom scripts or adapter specific dependencies, expose and/or publish
additional ports (`8081`, `8082`, `8083` and `8084` are already exposed)
or mount volumes (`/opt/iobroker/backups` and `/etc/letsancrypt` would be
the desired ones).

#### Build by your own
```bash
$ git clone https://github.com/ylabonte/ioBroker.docker.git
$ cd ioBroker.docker
$ docker build -t iobroker:latest .
$ docker run -d --name iobroker -p 8081:8081 iobroker:latest
```

#### Use my build on docker hub
```bash
$ docker run -d --name iobroker -p 8081:8081 labonte/iobroker:latest
```
