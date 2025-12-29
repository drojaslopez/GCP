gcloud auth list

gcloud config list project


gcloud config set compute/region Region

gcloud config set compute/zone ZONE

gcloud storage cp -r gs://spls/gsp053/kubernetes .
cd kubernetes

gcloud container clusters create bootcamp \
  --machine-type e2-small \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"


kubectl explain deployment

kubectl explain deployment --recursive

kubectl explain deployment.metadata.name

cat deployments/fortune-app-blue.yaml

kubectl create -f deployments/fortune-app-blue.yaml

kubectl get deployments

kubectl get replicasets

kubectl get pods

kubectl create -f services/fortune-app.yaml

curl http://<EXTERNAL-IP>/version

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version