# Introduction

CurrikiStudio enables you to create interactive learning content and publish them anywhere like Google Classroom, LMSs etc

# Components

## Applications

Following applications are the part of CurrikiStudio

1. [React Frontend application](https://github.com/ActiveLearningStudio/ActiveLearningStudio-react-client)
2. [Backend API](https://github.com/ActiveLearningStudio/ActiveLearningStudio-API)
3. [Admin Panel](https://github.com/ActiveLearningStudio/ActiveLearningStudio-admin-panel)
4. [Tsugi for LTI](https://github.com/tsugiproject/tsugi)
5. [Trax LRS](https://github.com/trax-project/trax-lrs)

## Databases

1. Postgres (For API, For LRS)
2. MySQL (For Tsugi)

## Searching

1. Elastic Search

# Infrastructure

Our Oracle Infrastructure is composed of three Linux VMs.

1. VM 1: CurrikiStudio Application (From Application Part above - Runnning Docker in swarm mode with single node)
2. VM 2: Databases: Postgres + MySQL (Running Docker)
3. VM 3: Elastic Search (Elastic Search installation on Oracle Linux)

# Deployment of VM1 (Application)


# Minimum Requirements
1. 12GB RAM
2. 2 VCPUs
3. Any of the linux flavours

# Pre-Requisites


1. Docker version 19 or above


# Installation

## Get App from Marketplace

Click on Get App Button on Oracle Marketplace

![Installation](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack1.png)

## Get App from Marketplace
![Installation](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack2.png)

# Database VM

Install [docker compose](https://docs.docker.com/compose/install/)

Run following commands

    git clone https://github.com/ActiveLearningStudio/ActiveLearningStudio-docker-db.git curriki-db
	cd curriki-db
	cp .env.example .env
	sudo mkdir -p /mnt/DBData/currikiprod1-mysqldata
	sudo mkdir -p /mnt/DBData/currikiprod1-postgresdata
	sudo mkdir -p /mnt/DBData/pgadmin1-data
	sudo docker-compose up -d

## Elastic VM

Currently elastic search is manual installation so you should following internet according to your environment

### For Ubuntu 
[https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-18-04](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-18-04)

### For CentOS 7

[https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-centos-7)

## Application VM

### Add DNS records

1. Copy public ip of the VM and put inside the DNS records like this.

Say public ip of your VM is 132.226.36.47

You must create these A records like

    example.currikistudio.org 132.226.36.47
	example-admin.currikistudio.org 132.226.36.47
	example-tsugi.currikistudio.org 132.226.36.47
	example-trax.currikistudio.org 132.226.36.47

This step is necessary to generate letsencrypt certificate which will be discussed later in this section

### Clone Main Repo into some folder

    git clone https://github.com/ActiveLearningStudio/ActiveLearningStudio-docker-containers.git curriki
	cd curriki

Change the values of setup.example.sh variables and run it (The purpose of the setup.example.sh file is to replace all the configuration variables inside the application according to your environment)
	
	sudo ./setup.example.sh
	sudo docker swarm init
	sudo ./init-letsencrypt.sh

init-letsencrypt.sh will generate a certificate and attach to your installation

Once this is run succesfully without errors your studio applicaiton will be on https://example.currikistudio.org

