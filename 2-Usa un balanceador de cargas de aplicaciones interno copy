
gcloud auth list
gcloud config list project

gcloud config set compute/region us-east1

gcloud config set compute/zone us-east1-c



sudo apt-get install -y virtualenv

python3 -m venv venv

source venv/bin/activate




gcloud services enable cloudaicompanion.googleapis.com

touch ~/backend.sh

sudo chmod -R 777 /usr/local/sbin/
sudo cat << EOF > /usr/local/sbin/serveprimes.py
import http.server

def is_prime(a): return a!=1 and all(a % i for i in range(2,int(a**0.5)+1))

class myHandler(http.server.BaseHTTPRequestHandler):
  def do_GET(s):
    s.send_response(200)
    s.send_header("Content-type", "text/plain")
    s.end_headers()
    s.wfile.write(bytes(str(is_prime(int(s.path[1:]))).encode('utf-8')))

http.server.HTTPServer(("",80),myHandler).serve_forever()
EOF
nohup python3 /usr/local/sbin/serveprimes.py >/dev/null 2>&1 &


gcloud compute instance-templates create primecalc \
--metadata-from-file startup-script=backend.sh \
--no-address --tags backend --machine-type=e2-medium

gcloud compute firewall-rules create http --network default --allow=tcp:80 \
--source-ranges 10.142.0.0/20 --target-tags backend



gcloud compute instance-groups managed create backend \
--size 3 \
--template primecalc \
--zone us-east1-c


gcloud compute health-checks create http ilb-health --request-path /2


gcloud compute backend-services create prime-service \
--load-balancing-scheme internal --region=us-east1 \
--protocol tcp --health-checks ilb-health

gcloud compute backend-services add-backend prime-service \
--instance-group backend --instance-group-zone=us-east1-c \
--region=us-east1


gcloud compute forwarding-rules create prime-lb \
--load-balancing-scheme internal \
--ports 80 --network default \
--region=us-east1 --address 10.142.0.10 \
--backend-service prime-service




gcloud compute instances create testinstance \
--machine-type=e2-standard-2 --zone us-east1-c

gcloud compute ssh testinstance --zone us-east1-c
curl 10.142.0.10/2