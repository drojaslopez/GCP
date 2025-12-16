gcloud auth list

gcloud config list project

Tarea 1: Crea varias instancias de servidor web

    gcloud config set compute/region europe-west4  

    gcloud config set compute/zone europe-west4-a


    gcloud compute instances create web1 \
        --zone=europe-west4-a \
        --tags=network-lb-tag \
        --machine-type=e2-small \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
            apt-get update
            apt-get install apache2 -y
            service apache2 restart
            echo "<h3>Web Server: web1</h3>" | tee /var/www/html/index.html'

    gcloud compute instances create web2 \
        --zone=europe-west4-a \
        --tags=network-lb-tag \
        --machine-type=e2-small \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install apache2 -y
    service apache2 restart
    echo "<h3>Web Server: web2</h3>" | tee /var/www/html/index.html'


    gcloud compute instances create web3 \
        --zone=europe-west4-a \
        --tags=network-lb-tag \
        --machine-type=e2-small \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install apache2 -y
    service apache2 restart
    echo "<h3>Web Server: web3</h3>" | tee /var/www/html/index.html'


    gcloud compute firewall-rules create www-firewall-network-lb \
        --target-tags network-lb-tag --allow tcp:80



-------------------------------------------------------------------------

Tarea 2: Configura el servicio de balanceo de cargas

    #IP externa estática 	network-lb-ip-1
    #Grupo de destino 	www-pool
    #Puertos 	80
export REGION=europe-west4
export ZONE=europe-west4-a

# Create a static external IP
gcloud compute addresses create network-lb-ip-1 --region=europe-west4
# Create an HTTP health check
gcloud compute http-health-checks create basic-check
# Create a target pool
gcloud compute target-pools create www-pool \
--region=europe-west4 \
--http-health-check=basic-check
# Add instances to the target pool
gcloud compute target-pools add-instances www-pool \
--instances=web1,web2,web3 \
--instances-zone=europe-west4-a \
--region=europe-west4
# Create a forwarding rule
gcloud compute forwarding-rules create www-rule \
--region=europe-west4 \
--ports=80 \
--address=network-lb-ip-1 \
--target-pool=www-pool


Tarea 3: Create an HTTP load balancer

    # Create an instance template
    gcloud compute instance-templates create lb-backend-template \
    --region=europe-west4 \
    --network=default \
    --subnet=default \
    --tags=allow-health-check \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata startup-script='#!/bin/bash
    apt-get update
    apt-get install apache2 -y
    a2ensite default-ssl
    a2enmod ssl
    vm_hostname="$(curl -H "Metadata-Flavor:Google" \
    <http://169.254.169.254/computeMetadata/v1/instance/name>)"
    echo "Page served from: $vm_hostname" | tee /var/www/html/index.html
    systemctl restart apache2'


    # Create a managed instance group
    gcloud compute instance-groups managed create lb-backend-group \
    --template=lb-backend-template \
    --size=2 \
    --zone=europe-west4-a



    # Create a firewall rule to allow health checks
    gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80



    # Create a health check
    gcloud compute health-checks create http http-basic-check --port=80
    
    # Set named ports for the instance group
    gcloud compute instance-groups managed set-named-ports lb-backend-group \
    --named-ports http:80 \
    --zone=europe-west4-a

    # Create a backend service
    gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

    # Add backend to the backend service
    gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=europe-west4-a \
    --global

    # Create a URL map
    gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

    # Create a target HTTP proxy
    gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

    # Create an external IP address
    gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global

    # Create a forwarding rule
    gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1 \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80