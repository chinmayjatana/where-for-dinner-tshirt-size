# V2 Supply Chain

## Description


The output of the V2 scripts are a set of configurations files used to build Carvel packages and a set of configuration that will be part of GitOps
repository for deploying the application to a runtime environment.

## Usage

### Create A Deployment Configuration

To create a set of configurations, clone this repository to your workstation, navigate to the project directory, and run the following command:

```
./buildTShirt.sh
```

This will ask for series of configuration options including the T-Shirt size and namespace where the carvel packages will be built.  The configuration files will be 
output to a new sub-directory using the naming pattern `<size>-<workload namespace>`.  This sub-directory contains everything needed to build the configured instance of 
the Where For Dinner application meaning this sub-directory can be archived for later use.


### Apply Deployment Configuration to you TAP Cluster

You will be given an option to apply the build configuration at the end of the configuration generation process, or you can execute at a later time.  A file named `runInstall.sh` will be created in the new sub directory, and you can execute it by navigating the sub-directory and running the following command:

```
./runInstall.sh
```

This will execute the exact same set of commands had you instructed the configuration build script to install the configuration at the end of the configuration generation script.


### Configuration Options

The install script generates on of three stock configuration `sizes`.  

- **small** - This is the simplest configuration and consists of the following services and workloads:
    - API Gateway workload 
    - Search workload (In memory database)
    - Search Processor workload
    - Availability workload (In memory database)
    - UI workload
    - Configuration for a 1 Node RabbitMQ Cluster
   
- **medium** - This includes all of the services of the `small` size plus the following services and workloads
    - Notify workload
    - Configuration for a Persistent Database (MySQL or Postgres)
   
- **large** - This includes all of the services of the `medium` size the the following services and workloads
    - Crawler Service
    - Configuration For a Redis Instance

    
A lot additional configuration options are mainly service naming.  It is recommended that service names are unique per application configuration.  E

There are three configuration options that are not naming related:

- **Database Type** - For medium and large sizes, the database types of Postgres or MySQL are valid options and the install script will spin up an instance of the selected database type.
- **Use Web Workload Type** - If set to yes, all workloads will use the `web` workload type.  If no, then the server and worker workload types will be applied to 
appropriate workloads.

## Generated Configuration

At the end of the generation process, a series of files are created for building the application's Carvel packages and a set of files that are used at 
deployment time.  Unlike the V1 supply chain, the V2 supply chain does not perform a build and deploy in a single step.  Instead it assumes the following 
workflow:

- Generated build and deployment time configuration.
- Builds the carvel packages using the generated build configuration, and writes the package information to a GitOps repository.
- Places all deployment time configuration in a `<size>-<workload namespace>/gitops` folder.  These files should be moved to your GitOps repository
to be applied at deployment time.

