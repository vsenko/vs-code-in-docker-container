An approach for containerized development.
===========================================

For those situations when there is a need to have separate development environments for different projects a usual solution is to use virtual machines. Virtual machine usage usually induce several weaknesses:
- increased startup time;
- increased memory usage;
- increased disk space usage;
- less responsive GUI (in most scenarios).

This is an attempt to mitigate those weaknesses by means of creating Docker containers for different development environments. The idea is quite straightforward:
- build a base image that all (or most) containers will be based on;
- create containers for different development environments;
- use SSH with X redirection to display IDE on the host;
- use SSH port forwarding feature to obtain access to services in the container if it is necessary.

A Dockerfile for the base image is included in this repo. It is based on Ubuntu 16.04 and includes VS Code as IDE. VS Code has an excellent integrated terminal that is convenient to use to setup the environment.

Build the base image:

    sudo docker build -t vs-code-base - < Dockerfile

Create development environments:

    sudo docker run -p 127.0.0.1:2222:22 --name vs-code-go vs-code-base
    sudo docker run -p 127.0.0.1:2223:22 --name vs-code-node vs-code-base

A simple script to access containerized IDE:

    #!/bin/bash
    sudo docker start vs-code-go
    sleep 5
    ssh -X -p 2222 user@127.0.0.1 code
    sudo docker stop vs-code-go

A script to access containerized IDE and redirect 8080 and 8081 ports to the host:

    #!/bin/bash
    sudo docker start vs-code-node
    sleep 5
    ssh -X -p 2223 -L 8080:127.0.0.1:8080 -L 8081:127.0.0.1:8081 user@127.0.0.1 code
    sudo docker stop vs-code-node

Current implementation has the following drawbacks:
- as long as password auth for SSH is used, the user has to type password each time she wants to access IDE;
- there is no convenient procedure to upload files into containers and vice versa.

Tested on Ubuntu 16.04.
