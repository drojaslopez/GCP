gcloud auth list

gcloud config list project




Create Firewall Rule.

gcloud compute --project=qwiklabs-gcp-01-696b50636283 firewall-rules create app-allow-http --direction=INGRESS --priority=1000 --network=my-internal-app --action=ALLOW --rules=tcp:80 --source-ranges=10.10.0.0/16 --target-tags=lb-backend


gcloud compute --project=qwiklabs-gcp-01-696b50636283 firewall-rules create app-allow-health-check --direction=INGRESS --priority=1000 --network=my-internal-app --action=ALLOW --rules=PROTOCOL:PORT,... --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=lb-backend


gcloud compute instance-templates create instance-template-1 --project=qwiklabs-gcp-01-696b50636283 --machine-type=e2-micro --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=subnet-a --metadata=startup-script-url=gs://spls/gsp216/startup.sh,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=365455368838-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --region=us-east4 --tags=lb-backend --create-disk=auto-delete=yes,boot=yes,device-name=instance-template-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any



gcloud beta compute instance-groups managed create instance-group-1 --project=qwiklabs-gcp-01-696b50636283 --base-instance-name=instance-group-1 --template=projects/qwiklabs-gcp-01-696b50636283/global/instanceTemplates/instance-template-1 --size=1 --zone=us-east4-b --default-action-on-vm-failure=repair --action-on-vm-failed-health-check=default-action --on-repair-allow-changing-zone=no --no-force-update-on-repair --standby-policy-mode=manual --list-managed-instances-results=pageless && gcloud beta compute instance-groups managed set-autoscaling instance-group-1 --project=qwiklabs-gcp-01-696b50636283 --zone=us-east4-b --mode=on --min-num-replicas=1 --max-num-replicas=1 --target-cpu-utilization=0.8 --cpu-utilization-predictive-method=none --cool-down-period=45



gcloud compute instances create utility-vm --project=qwiklabs-gcp-01-696b50636283 --zone=us-east4-b --machine-type=e2-micro --network-interface=network-tier=PREMIUM,private-network-ip=10.10.20.50,stack-type=IPV4_ONLY,subnet=subnet-a --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=365455368838-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=utility-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any && printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml && gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-us-east4-b --project=qwiklabs-gcp-01-696b50636283 --zone=us-east4-b --file=config.yaml && gcloud compute resource-policies create snapshot-schedule default-schedule-1 --project=qwiklabs-gcp-01-696b50636283 --region=us-east4 --max-retention-days=14 --on-source-disk-delete=keep-auto-snapshots --daily-schedule --start-time=12:00 && gcloud compute disks add-resource-policies utility-vm --project=qwiklabs-gcp-01-696b50636283 --zone=us-east4-b --resource-policies=projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/resourcePolicies/default-schedule-1




POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/backendServices
{
  "backends": [
    {
      "balancingMode": "CONNECTION",
      "failover": false,
      "group": "projects/qwiklabs-gcp-01-696b50636283/zones/us-east4-b/instanceGroups/instance-group-1"
    },
    {
      "balancingMode": "CONNECTION",
      "failover": false,
      "group": "projects/qwiklabs-gcp-01-696b50636283/zones/us-east4-a/instanceGroups/instance-group-2"
    }
  ],
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "description": "",
  "failoverPolicy": {},
  "healthChecks": [
    "projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/healthChecks/my-ilb-health-check"
  ],
  "loadBalancingScheme": "INTERNAL",
  "logConfig": {
    "enable": false
  },
  "name": "my-ilb",
  "network": "projects/qwiklabs-gcp-01-696b50636283/global/networks/my-internal-app",
  "networkPassThroughLbTrafficPolicy": {
    "zonalAffinity": {
      "spillover": "ZONAL_AFFINITY_DISABLED"
    }
  },
  "protocol": "TCP",
  "region": "projects/qwiklabs-gcp-01-696b50636283/regions/us-east4",
  "sessionAffinity": "NONE"
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/forwardingRules
{
  "IPAddress": "10.10.30.5",
  "IPProtocol": "TCP",
  "allowGlobalAccess": false,
  "backendService": "projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/backendServices/my-ilb",
  "description": "",
  "ipVersion": "IPV4",
  "loadBalancingScheme": "INTERNAL",
  "name": "my-ilb-forwarding-rule",
  "networkTier": "PREMIUM",
  "ports": [
    "80"
  ],
  "region": "projects/qwiklabs-gcp-01-696b50636283/regions/us-east4",
  "subnetwork": "projects/qwiklabs-gcp-01-696b50636283/regions/us-east4/subnetworks/subnet-b"
}