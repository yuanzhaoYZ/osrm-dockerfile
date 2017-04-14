## Docker file for OSRM-backend

This project provides a docker file that creates an image with Open Source Routing Machine (OSRM) that uses North-America map.

You can download the pre-built Docker image [here](https://hub.docker.com/r/yuanzhao/osrm_dockerfile/).

The docker image was built on a baremetal CentOS 7 Server with Docker CE 
```
CPUs:	32 CORE
Memory:	64 GB

# uname -r
3.10.0-327.13.1.el7.x86_64

#cat /etc/*-release file
CentOS Linux release 7.2.1511 (Core) 

```

### 1.Prerequisite
## 1.1 Tools and Accounts
- Bluemix account or Docker Hub account
- [Installation of docker to the local](https://docs.docker.com/installation/)
- [Installation of Cloud Foundry plug-in for IBM Containers](https://www.ng.bluemix.net/docs/containers/container_cli_ov.html#container_cli_choosing)

## 1.2 Create a Swap File

Determine the size of the new swap file in megabytes and multiply by 1024 to determine the number of blocks. For example, the block size of a 140000 MB (140GB) swap file is 143360000  (140000*1024).
At a shell prompt as root, type the following command with count being equal to the desired block size:
```
dd if=/dev/zero of=/swapfile bs=1024 count=143360000
chmod 600 /swapfile
```

Setup the swap file with the command:
```
mkswap /swapfile
```

To enable the swap file immediately but not automatically at boot time:
```
swapon /swapfile
```
To remove it 
```
swapoff -v /swapfile
```

To enable it at boot time, edit /etc/fstab to include the following entry:

```
/swapfile          swap            swap    defaults        0 0
```  

The next time the system boots, it enables the new swap file.

After adding the new swap file and enabling it, verify it is enabled by viewing the output of the command 
```
cat /proc/swaps

```
or

```
free
```





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

### 4.How to deploy OSRM image to Docker Hub

1. If you don’t already have a terminal open, open one now.Run docker images to list the images stored locally:

2. Find the image ID for the `osrm_dockerfile` image, in the third column. In this example, the id is `7d9495d03763`, but yours will be different.
```
$ docker images

REPOSITORY           TAG          IMAGE ID            CREATED             SIZE
docker-whale         latest       7d9495d03763        38 minutes ago      273.7 MB
<none>               <none>       5dac217f722c        45 minutes ago      273.7 MB
docker/whalesay      latest       fb434121fc77        4 hours ago         247 MB
hello-world          latest       91c95931e552        5 weeks ago         910 B
```
3. Tag the osrm_dockerfile image using the docker tag command and the image ID.
```
docker tag 7d9495d03763 yuanzhao/osrm_dockerfile:north_america
```

4. Run docker images again to verify that the osrm_dockerfile image has been tagged.
```
$ docker images

REPOSITORY                  TAG       IMAGE ID        CREATED          SIZE
yuanzhao/osrm_dockerfile   latest    7d9495d03763    5 minutes ago    273.7 MB
yuanzhao/osrm_dockerfile   latest    7d9495d03763    2 hours ago      273.7 MB
<none>                      <none>    5dac217f722c    5 hours ago      273.7 MB
docker/whalesay             latest    fb434121fc77    5 hours ago      247 MB
hello-world                 latest    91c95931e552    5 weeks ago      910 B
```
The same image ID actually now exists in two different repositories.


5. Before you can push the image to Docker Hub, you need to log in, using the docker login command. The command doesn’t take any parameters, but prompts you for the username and password, as below:
```
$ docker login

    Username: *****
    Password: *****
    Login Succeeded

```

6. Push your tagged image to Docker Hub, using the docker push command. A lot of output is generated, as each layer is pushed separately. That output is truncated in the example below.
```
$ docker push yuanzhao/osrm_dockerfile

The push refers to a repository [yuanzhao/osrm_dockerfile] (len: 1)
7d9495d03763: Image already exists
...
e9e06b06e14c: Image successfully pushed
Digest: sha256:ad89e88beb7dc73bf55d456e2c600e0a39dd6c9500d7cd8d1025626c4b985011

```

### 5.How to deploy OSRM image to IBM Container and run on Bluemix

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
