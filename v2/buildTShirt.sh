#!/bin/bash

default_tshirt_size=small
default_workload_namespace=workloads
default_rabbit_name=rmq-where-for-dinner
default_db_type=mysql
default_db_name=where-for-dinner
default_redis_name=redis-where-for-dinner
default_gitops_repo_branch=main
accept=no

# Get user input

while [ "$accept" != "yes" ]
do

#
# T-Shirt Size
#
    validSize=no
    while [ "$validSize" != "yes" ]
    do

	   printf '\nT-Shirt Size: small, medium, or large  (default %s): ' "'$default_tshirt_size'"
	
	   read tshirtSize
	
	   if [ -z "$tshirtSize" ]
	   then
	      tshirtSize=$default_tshirt_size
	   fi 

       if [ "$tshirtSize" == "small"  ] || [ "$tshirtSize" == "medium"  ] || [ "$tshirtSize" == "large"  ]
       then
          validSize=yes
       else
	      printf '\nInvalid T-Shirt size.'
          echo ' '
       fi

    done

#
# Registry server and repository
#
   printf 'Registry server: (optional, leave empty to use the supply chain provided server): '
      read registry

   if [ ! -z "$registry" ]
   then
       while [ -z "$repository" ]
       do

	       printf 'Registry repository: '
    
          read repository
    
          if [ -z "$repository" ]
          then
             printf '\nRepository cannot be empty if a registry server is provided.\n'
             echo ' '
          fi
       done
   fi 

#
# GiOps repository
#
   printf 'GitOps repository: (optional, leave empty to use the supply chain provided GitOps repository): '
      read gitOpsRepo

   if [ ! -z "$gitOpsRepo" ]
   then

      printf 'GitOps reposity branch (default %s): ' "'$default_gitops_repo_branch'"

      read gitOpsRepoBranch

      if [ -z "$gitOpsRepoBranch" ]
      then
         gitOpsRepoBranch=$default_gitops_repo_branch
      fi

      printf 'GitOps reposity sub path (if applicable): '

      read gitOpsRepoSubPath

   fi 

#
# Use 'web' workload type
#
   printf 'Use web workload type: yes/no (default %s)? ' "'yes'"

   read useWebType

   if [ -z "$useWebType" ]
   then
      useWebType='yes'
   fi 

#
# Workload build namespace
#
	printf 'Workload Build Namespace: (default %s): ' "'$default_workload_namespace'"
	
	read workloadNamespace
	
	if [ -z "$workloadNamespace" ]
	then
	   workloadNamespace=$default_workload_namespace
	fi
	
#
# RMQ cluster name
#
    printf '(Not Yet Functional) RabbitMQ Cluster Name (default %s): ' "'$default_rabbit_name'"
    
    read rabbitMQName
    
    if [ -z "$rabbitMQName" ];
    then
       rabbitMQName=$default_rabbit_name
    fi
    
#
# Database type; only use database type and instance name if T-Shirt size is medium or large
#
    if [ "$tshirtSize" == "medium" ] || [ "$tshirtSize" == "large" ]
    then
       validDBType=no
       while [ "$validDBType" != "yes" ]
       do

          printf '(Not Yet Functional) Database Type: mysql or postgres: (default %s): ' "'$default_db_type'"
    
          read dbType
    
          if [ -z "$dbType" ]
          then
             dbType=$default_db_type
          fi

          if [ "$dbType" == "mysql"  ] || [ "$dbType" == "postgres"  ] 
          then
             validDBType=yes
          else
             printf '\nInvalid database type.\n'
             echo ' '
          fi
       done

#
# Database instance name 
#
       defaultDBFullName=$dbType'-'$default_db_name

       printf '(Not Yet Functional) Database Instance Name (default %s): ' "'$defaultDBFullName'"
    
       read dbName
    
       if [ -z "$dbName" ]
       then
          dbName=$defaultDBFullName
       fi
    fi

#
# Redis instance name; only use redis instance name if the tshirtSize is large
#
    if [ "$tshirtSize" == "large" ] 
    then
       printf '(Not Yet Functional) Redis Instance Name (default %s): ' "'$default_redis_name'" 
        
       read redisName
    
       if [ -z "$redisName" ]
       then
          redisName=$default_redis_name
       fi
    fi
	
	echo ' '
	echo Configured Options:
   printf '   T-Shirt size: %s\n' "[$tshirtSize]"
   if [ ! -z "$registry" ]
   then
 	   printf '   Registry Server: %s\n' "[$registry]"   
	   printf '   Registry Repository: %s\n' "[$repository]"
	fi  

   if [ ! -z "$gitOpsRepo" ]
   then
 	   printf '   GitOps Repsitory: %s\n' "[$gitOpsRepo]"   
	   printf '   GitOps Repository Branch: %s\n' "[$gitOpsRepoBranch]"
      if [ ! -z "$gitOpsRepoSubPath" ]
      then
         printf '   GitOps Repsitory Sub Path: %s\n' "[$gitOpsRepoSubPath]"   
      fi         
	fi       
   printf '   Use web type: %s\n' "[$useWebType]"
	printf '   Workload Build Namespace: %s\n' "[$workloadNamespace]"
	printf '   RabbitMQ Cluster Name: %s\n' "[$rabbitMQName]"
   if [ "$tshirtSize" == "medium" ] || [ "$tshirtSize" == "large" ]
   then
 	   printf '   Database Type : %s\n' "[$dbType]"   
	   printf '   Database Instance Name: %s\n' "[$dbName]"
	fi
    
   if [ "$tshirtSize" == "large" ] 
   then
       printf '   Redis Instance Name: %s\n' "[$redisName]"
   fi
	
	echo ' '
	printf 'Accept these values: yes/no (default %s)? ' "yes"
	
	read accept
	
	if [ -z "$accept" ]
	then
	   accept=yes
	fi
done

# Apply user inputs to templates

outputDir=$tshirtSize'_'$workloadNamespace
gitopsDir=$outputDir'/gitops'



if [ ! -d "$outputDir" ]
then
  mkdir -p $gitopsDir
else
  rm -rf ./$outputDir/* -y 
  mkdir -p $gitopsDir  
fi

printf '\nGenerating configuration files into directory %s\n' "'$outputDir'"

ytt -f ./tshirt-templates/common/rmqCluster.yaml -v rabbitMQName=$rabbitMQName -v serviceNamespace=$serviceNamespace >> ./$gitopsDir/rmqCluster.yaml
ytt -f ./tshirt-templates/$tshirtSize/workloads.yaml -v workloadNamespace=$workloadNamespace -v dbType=$dbType -v useWebType=$useWebType -v registry=$registry \
 -v  repository=$repository -v gitOpsRepo=$gitOpsRepo -v gitOpsRepoBranch=$gitOpsRepoBranch -v gitOpsRepoSubPath=$gitOpsRepoSubPath  >> ./$outputDir/workloads.yaml

#
# --- TEMPORARY SERVICE BINDING RESOURCES; WILL MOVE TO ServiceInstanceBinding WHEN AVAILABILE ---
#
serviceType=web;
if [ "$useWebType" != "yes" ] 
then
 serviceType=deployment
fi

ytt -f ./tshirt-templates/common/rmqBindingTemplate.yaml -v name=where-for-dinner-search -v rabbitMQName=$rabbitMQName -v serviceType=$serviceType >> ./$gitopsDir/searchRmqBinding.yaml
ytt -f ./tshirt-templates/common/rmqBindingTemplate.yaml -v name=where-for-dinner-search-proc -v rabbitMQName=$rabbitMQName -v serviceType=$serviceType >> ./$gitopsDir/searchProcRmqBinding.yaml
ytt -f ./tshirt-templates/common/rmqBindingTemplate.yaml -v name=where-for-dinner-availability -v rabbitMQName=$rabbitMQName -v serviceType=$serviceType >> ./$gitopsDir/availabilityRmqBinding.yaml  

if [ "$tshirtSize" == "medium" ] || [ "$tshirtSize" == "large" ]
then
  dbInstanceFile=$dbType'Instance.yaml'
  dbBindingFile=$dbType'BindingTemplate.yaml'

  ytt -f ./tshirt-templates/medium/$dbInstanceFile -v dbName=$dbName -v serviceNamespace=$serviceNamespace >> ./$gitopsDir/$dbInstanceFile
  ytt -f ./tshirt-templates/medium/$dbBindingFile -v name=where-for-dinner-availability -v dbName=$dbName -v serviceType=$serviceType >> ./$gitopsDir/availabilityDbBinding.yaml  
  ytt -f ./tshirt-templates/medium/$dbBindingFile -v name=where-for-dinner-search -v dbName=$dbName -v serviceType=$serviceType >> ./$gitopsDir/searchDbBinding.yaml    
  ytt -f ./tshirt-templates/common/rmqBindingTemplate.yaml -v name=where-for-dinner-notify -v rabbitMQName=$rabbitMQName -v serviceType=$serviceType >> ./$gitopsDir/notifyRmqBinding.yaml  

fi

if [ "$tshirtSize" == "large" ]
then
  ytt -f ./tshirt-templates/large/redis.yaml -v redisName=$redisName -v workloadNamespace=$workloadNamespace >> ./$gitopsDir/redis.yaml
  ytt -f ./tshirt-templates/large/redisBindingTemplate.yaml -v name=where-for-dinner-search-proc -v redisName=$redisName -v serviceType=$serviceType >> ./$gitopsDir/searchProcCacheBinding.yaml    
fi

# Write to an install file
echo "export outputDir=$outputDir
export workloadNamespace=$workloadNamespace
export tshirtSize=$tshirtSize
export redisName=$redisName
export dbInstanceFile=$dbInstanceFile
export dbType=$dbType
export dbName=$dbName
export dbClaimFile=$dbClaimFile
export rabbitMQName=$rabbitMQName

./deployEx.sh"  >> ./$outputDir/runInstall.sh

chmod +x ./$outputDir/runInstall.sh
cp ./tshirt-templates/common/deployEx.sh ./$outputDir/deployEx.sh
chmod +x ./$outputDir/deployEx.sh

# Apply build resources to the cluster

echo ' '
printf 'Apply T-Shirt build resources now: yes/no (default %s)? ' "yes"

read install

if [ -z "$install" ]
then
    install=yes
fi

if [ "$install" == "yes" ] 
then
  cd $outputDir
  ./runInstall.sh
fi

printf "\n\nTo run or re-run the application of the build resources, 'cd' to the %s directory and run './runInstall.sh'" "'$outputDir'"
echo ' '