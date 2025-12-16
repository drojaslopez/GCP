gcloud auth list

gcloud config list project

gcloud config set compute/region us-west1

gcloud config set compute/zone us-west1-b

Task 1: Create a Bucket for Photo Storage


  gcloud storage buckets create gs://qwiklabs-gcp-01-128c86cadc97-bucket



Task 2: Create a Pub/Sub Topic


gcloud pubsub topics create topic-memories-993

export USER_2=student-01-c894584fef99@qwiklabs.net
export ZONE=us-west1-b
export TOPIC=topic-memories-972
export FUNCTION=memories-thumbnail-generator


curl -LO raw.githubusercontent.com/chayandeokar/Cloud-Skills-2025/refs/heads/master/Set%20Up%20an%20App%20Dev%20Environment%20on%20Google%20Cloud%20Challenge%20Lab%20/gsp315.sh

sudo chmod +x gsp315.sh

./gsp315.sh