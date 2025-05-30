---
title: "Using Containers with WSL, Apptainer, and Docker"
date: 2025-05-23
draft: false
---


## Install WSL

1. Log in as admin PowerShell (need to request).
2. Run the command:  
   ```bash
   wsl --install  
   ```

    https://learn.microsoft.com/en-us/windows/wsl/setup/environment  
    might also need to separately install linux Distro  
    ```bash
    . wsl.exe  --list --online (pick the version you like)
    . wsl.exe  --install Ubuntu-24.04 
    ```

3. if run into: **Logon failure: the user has not been granted the requested logon type at this computer.**   try the following:   
    - Search (Windows) for and open "Turn Windows features on or off"   
    - Check the box next to Hyper-V   
    - Restart your system  
    - Try 2) again   



## Install Apptainer (Singularity) in WSL  

1. wsl (open a terminal)
2. Run this command
    ```bash
    sudo apt update && sudo apt install -y \
        build-essential \
        libseccomp-dev \
        pkg-config \
        squashfs-tools \
        cryptsetup \
        uidmap \
        git \
        wget \
        curl \
        gnupg \
        lzip \
        tar  
    ``` 
3. Install Go (required for Apptainer)  
    ```bash
    wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
    ```
    (if run into issue, go to: https://go.dev/dl/, and click on download), and
    it will be saved at: /mnt/c/Users/YourUserID/Downloads  
    ```bash
    sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    ```


4. Install Apptainer (Singularity)
    ```bash
    export VERSION=1.4.1 # or the latest
    wget \ https://github.com/apptainer/apptainer/releases/download/v${VERSION}/apptainer-${VERSION}.tar.gz  
    tar -xzf apptainer-${VERSION}.tar.gz  
    or  
    tar --no-same-owner --no-same-permissions  -xzf apptainer-${VERSION}.tar.   
    (might get a lot of tar errors, even it says fail in the end, just ignore them)  
    ```
    **you might need to do the following steps in your 'native  WSL file system'**, for example your home drive, and then copy the apptainer-${VERSION}
    there and do the following:
    ```
    cd apptainer-${VERSION}
    ./mconfig && \
        make -C builddir && \
        sudo make -C builddir install
    ```

5. Build the sif image
    ```
    apptainer build  mycontainer.sif  mycontainer.def
    ```

## DOCKER / Docker Desktop - install and convert singularity sif image to OCI

1. install Docker Desktop --need Admin access (password), (after WSL2 installation, so that Docker and WSL2 are integrated)  

    https://docs.docker.com/desktop/features/wsl/


2. Add your user to the docker group  

    ```
    sudo usermod -aG docker $USER
    ```

    restart WSL and verify docker run works by: 
    ```
    docker run hello-world
    ```
3. Convert .sif → Docker (OCI)

    - Use apptainer build to convert .sif to a sandbox (directory)
        ```
        apptainer build --sandbox hmas2_sandbox hmas2.sif
        ```

    -  Use Docker to import the sandbox into an image
        ```
        cd hmas2_sandbox
        tar -c . | docker import - hmas2:latest
        ```

    -  Verify Docker image
        ```
        docker images
        ```

## DOCKER - build OCI from scratch (assume docker already installed)

1. need the Dockerfile (similar to singularity/apptainer def file). If you have available the binary files of your packages, try avoid using conda to slim down image size.  
    ```
    docker build -t jinfinance/hmas2:v1.1 -f Dockerfile.hmas.v1.1  .
    ```
    in the folder where all necessary binary files and Dockerfile exist. (*jinfinance/hmas2*  is your DockerHub repository name, and *Dockerfile.hmas.v1.1* is your Dockerfile name. And the dot at the end represents the current folder)

  

2. push to Docker Hub  
    ```
    docker push jinfinance/hmas2:v1.1
   ```
