#!/bin/bash

#export REGION="${ZONE%-*}"

gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; 




#-------------------------------------------------start--------------------------------------------------#
export NETWORK_TAG_1=permit-ssh-iap-ingress-ql-889
export NETWORK_TAG_2=permit-http-ingress-ql-889
export NETWORK_TAG_3=permit-ssh-internal-ingress-ql-889
export ZONE=us-west1-b

#Task 1 :: Remove the overly permissive rules:

gcloud compute firewall-rules delete open-access



#Task 2 :: Start the bastion host instance:

#Go to Compute Engine and start Bastion instance.
gcloud compute instances start bastion --zone=$ZONE



#Task 3 : Create a firewall rule that allows SSH (tcp/22) from the IAP service and add network tag on bastion:

#***Replace the "[NETWORK TAG]" with the network tag provided in the lab.***

gcloud compute firewall-rules create ssh-ingress --allow=tcp:22 --source-ranges 35.235.240.0/20 --target-tags $NETWORK_TAG_1 --network acme-vpc

gcloud compute instances add-tags bastion --tags=$NETWORK_TAG_1 --zone=$ZONE



#Task 4 : Create a firewall rule that allows traffic on HTTP (tcp/80) to any address and add network tag on juice-shop:

gcloud compute firewall-rules create http-ingress --allow=tcp:80 --source-ranges 0.0.0.0/0 --target-tags $NETWORK_TAG_2 --network acme-vpc

gcloud compute instances add-tags juice-shop --tags=$NETWORK_TAG_2 --zone=$ZONE



#Task 5 : Create a firewall rule that allows traffic on SSH (tcp/22) from acme-mgmt-subnet network address and add network tag on juice-shop:

gcloud compute firewall-rules create internal-ssh-ingress --allow=tcp:22 --source-ranges 192.168.10.0/24 --target-tags $NETWORK_TAG_3 --network acme-vpc

gcloud compute instances add-tags juice-shop --tags=$NETWORK_TAG_3 --zone=$ZONE



#Task 6 : SSH to bastion host via IAP and juice-shop via bastion:

#In Compute Engine -> VM Instances page, click the SSH button for the bastion host. Then SSH to juice-shop by

ssh [Internal IP address of juice-shop]
#-----------------------------------------------------end----------------------------------------------------------#
