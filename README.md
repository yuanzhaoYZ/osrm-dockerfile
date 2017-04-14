## Docker file for OSRM-backend

This project provides a docker file that creates an image with Open Source Routing Machine (OSRM) that uses NY bicycle map.

### Prerequisite

- Bluemix account
- [Installation of docker to the local](https://docs.docker.com/installation/)
- [Installation of Cloud Foundry plug-in for IBM Containers](https://www.ng.bluemix.net/docs/containers/container_cli_ov.html#container_cli_choosing)

### How to create container image

1. Clone this project to local.

  ```
  $ git clone https://hub.jazz.net/git/masanobu/osrm-dockerfile
  ```

1. Download bicycle Open Street Map data of NYC, and rename this to "map.osm.pbf".

  ```
  $ cd osrm-dockerfile
  $ wget -O map.osm.pbf http://download.bbbike.org/osm/bbbike/NewYork/NewYork.osm.pbf
  ```

1. Create OSRM image.

  ```
  $ docker build -t osrm .
  (take a little time)
  $ docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
  osrm                latest              f72ec144195e        23 seconds ago      806.6 MB
  ```

1. Run OSRM image at local.

  ```
  $ docker run -t -d -p 80:80 osrm
  ```

1. Check IP address of your local docker machine.

  ```
  $ docker-machine ip default
  [IP address of your docker machine]
  ```

1. Check API response by opening the following link with your browser.

  URL: http://[ IP address of your docker machine ]/viaroute

  Response: {} (Blank JSON object)
  
### How to deploy OSRM image to IBM Container and run on Bluemix

2. Login to Bluemix

  ```
  $ cf login
  ```

2. Login to IBM Container

  ```
  $ cf ic login
  ```

2. Set up the namespace on IBM Container (for the first time)

  ```
  $ cf ic namespace set [your namespace on IBM Container]
  ```

2. Set the tag name of OSRM image for the deployment to IBM Container repositry

  ```
  $ docker tag osrm registry.ng.bluemix.net/[your namespace on IBM Container]/osrm
  ```
  
2. Deploy the OSRM image to IBM Container repositry

  ```
  $ docker push registry.ng.bluemix.net/[your namespace on IBM Container]/osrm
  (take a little time)
  ```

2. Run the OSRM image on IBM Container

  3. Login to Bluemix and select "Containers" on dashboard
  3. Click the "osrm" image from "Container images" and deploy a single container by checking as follows:
    - Container type: Single Container
    - Space: [Default]
    - Container name: osrm
    - Size: Small (1GB Memory, 64 GB Storage)
    - Public IP address: Request and Bind Public IP
    - Public ports: 80
  3. Click "CREATE" button

2. Check API response by opening the following link with your browser.

  URL: http://[ assigned Pubic IP address ]/viaroute

  Response: {} (Blank JSON object)


### References

- [Open Street Map](http://www.openstreetmap.org/#map=5/51.500/-0.100)

- [Open Source Routing Machine](https://github.com/Project-OSRM/osrm-backend)

- [Bicycle road OSM data at NYC](http://download.bbbike.org/osm/bbbike/NewYork/)
