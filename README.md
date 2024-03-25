# where-for-dinner-tshirt-size

## Description

Where For Dinner T-Shirt sizing is a set of scripts and templates for creating a stock sized configuration for the Where For Dinner application.  The scripts allows for one 
of three sizes to be created along with a few customizations such as workload and service name spaces, service names, and database type.  


The output of the scripts are a set 
of configurations files for a give size and workload name space to deploy the application in along with a `install1` script to deploy the application which can executed 
either at the same time the configurations files are created or at a later time.  The output configuration files can also be archived for later use.

## Usage

The sizing scripts categorized by the version of the Supply Chain that you are using which can have a profound effect on the expected build and deployment flow.
See the links below for instructions for your specific version of the Supply Chain.


* [v1](./v1/README.md)
* [v2](./v2/README.md)
