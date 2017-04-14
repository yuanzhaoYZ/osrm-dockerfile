## Docker file for OSRM-backend

This project provides a docker file that creates an image with Open Source Routing Machine (OSRM) that uses North-America map.

[Docker Image](https://hub.docker.com/r/yuanzhao/osrm_dockerfile/)
### 1.Prerequisite

- Bluemix account
- [Installation of docker to the local](https://docs.docker.com/installation/)
- [Installation of Cloud Foundry plug-in for IBM Containers](https://www.ng.bluemix.net/docs/containers/container_cli_ov.html#container_cli_choosing)

### 2.How to create container image

1. Clone this project to local.

```
$ git clone https://github.com/yuanzhaoYZ/osrm-dockerfile
```

2. Download OSM File

```

cd osrm-dockerfile
wget http://download.geofabrik.de/north-america-latest.osm.pbf
```

3. Create OSRM image.

  ```
  $ docker build -t osrm .
  (take a little time)
  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
  osrm                latest              f72ec144195e        23 seconds ago      806.6 MB
  ```

Note: If you get errors like this `Error processing tar file(exit status 1): write /map.osm.pbf: no space left on device`, you might need to delete some unsed images in docker to make some room for the OSRM image.
```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
```

If the issue persists, you can delete this file providing you aren't worried about loosing any containers/images, and restart Docker. This should get you back on track.

```
rm ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2
restart docker
```

4. Run OSRM image at local.

  ```
  $ docker run -t -d -p 5000:5000 osrm
  ```

5. Check IP address of your local docker machine.

  ```
  $ docker-machine ip default
  [IP address of your docker machine]
  ```

6. Check API response by opening the following link with your browser.

  URL: http://[ IP address of your docker machine ]/viaroute

  Response: {} (Blank JSON object)

### 3.How to deploy OSRM image to IBM Container and run on Bluemix

1. Install Bluemix CLI

If you haven't already, download the [BluemixCLI](http://clis.ng.bluemix.net/ui/home.html)

2. Install the Bluemix Containers Plugin

```
bluemix plugin install IBM-Containers -r Bluemix

```

3. Log in to Bluemix API

```
bluemix login -a https://api.ng.bluemix.net
```

4. Set a namespace

```
bx ic namespace-set zhaoy_ibm
```

5. Initialize containers plug-in
```
bluemix ic init
```

6. Deploy the OSRM image to IBM Container repositry

```
docker tag zhaoy/osrm registry.ng.bluemix.net/zhaoy_ibm/osrm
docker push registry.ng.bluemix.net/zhaoy_ibm/osrm
```

7. Verify that the image exists in your image registry by running the bx ic images command.

```
bx ic images
```

8. Run the OSRM image on IBM Container

  3. Login to Bluemix and select "Containers" on dashboard
  3. Click the "osrm" image from "Container images" and deploy a single container by checking as follows:
    - Container type: Single Container
    - Space: [Default]
    - Container name: osrm
    - Size: Small (1GB Memory, 64 GB Storage)
    - Public IP address: Request and Bind Public IP
    - Public ports: 80
  3. Click "CREATE" button

9. Check API response by opening the following link with your browser.

  URL: http://[ assigned Pubic IP address ]/viaroute

  Response: {} (Blank JSON object)



### References

- [Open Street Map](http://www.openstreetmap.org/#map=5/51.500/-0.100)

- [Open Source Routing Machine](https://github.com/Project-OSRM/osrm-backend)

- [Bicycle road OSM data at NYC](http://download.bbbike.org/osm/bbbike/NewYork/)

- [Docker file for OSRM-backend on Bluemix](https://hub.jazz.net/project/masanobu/osrm-dockerfile/overview)

- [No space left on device error](https://forums.docker.com/t/no-space-left-on-device-error/10894/2)
