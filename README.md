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

## Enter OCI Variables

Choose compartment, compute shapes, Availability Domain, Paste public keys (to connect to intances), VCN Settings

![OCI Variables](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack2.png)

Choose site urls settings like on which URL you want your studio to setup. Here you must provide all of your sites like (main site, admin site, tsugi site, trax site)

![Site URLs settings](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack3.png)


Enter MySQL Settings (MySQL is used with Tsugi), like passwords, ports. We are also setting up PhpMyAdmin with MySQl so that you can use GUI

![MySQL Settings](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack4.png)

Enter ElasticSearch and postgres settings like username and passwords

![MySQL Settings](https://raw.githubusercontent.com/ActiveLearningStudio/ActiveLearningStudio-oracle-terraform/master/images/stack5.png)


## Add DNS records

1. Copy public ip of the application server and put inside the DNS records like this.

Say public ip of your VM is 132.226.36.47

You must create these A records like

    example.currikistudio.org 132.226.36.47
	example-admin.currikistudio.org 132.226.36.47
	example-tsugi.currikistudio.org 132.226.36.47
	example-trax.currikistudio.org 132.226.36.47

This step is necessary to generate letsencrypt certificate which will be discussed later in this section


### Installation of https and other settings

Note: Add DNS Record is must for generating SSL

Once stack has been successfully run, you need to ssh into the application server. (You can get ip from outputs)

> ssh opc@ip-of-application-server
> cd /curriki

Run init-generate-ssl.sh file with sudo rights. It will ask few different parameters like email, smtp details etc. (Leave blank if you dont know yet. They can be manually configurable later)

> sudo ./init-generate-ssl.sh
This will generate ssl from letsencrypt


