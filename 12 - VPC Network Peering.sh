 VPC Network Peering 

 gcloud auth list
 gcloud config list project


 gcloud config set project qwiklabs-gcp-00-e0b9436f28e1

 gcloud config set project qwiklabs-gcp-01-8976bf6c2cc3

 gcloud compute networks create network-a --subnet-mode custom

 gcloud compute networks subnets create network-a-subnet --network network-a --range 10.0.0.0/16 --region us-east1