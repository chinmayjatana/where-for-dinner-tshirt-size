echo "Applying build resource configuration to the cluster"

kubectl create ns $workloadNamespace

kubectl apply -f ./workloads.yaml

echo "Finished applying build resources to the cluster"