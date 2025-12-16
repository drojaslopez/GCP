gcloud auth list

gcloud config list project




Create Firewall Rule.


gcloud compute --project=qwiklabs-gcp-00-5aa8d2f19b34 firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default \
    --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

Create the health check firewall rules


  gcloud compute --project=qwiklabs-gcp-00-5aa8d2f19b34 firewall-rules create default-allow-health-check \
  --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=PROTOCOL:PORT,... \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server




  gcloud compute instance-templates create us-central1-template --project=qwiklabs-gcp-00-5aa8d2f19b34 --machine-type=e2-micro --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=startup-script-url=gs://spls/gsp215/gcpnet/httplb/startup.sh,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=519896600758-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --region=us-central1 --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=us-central1-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

  gcloud compute instance-templates create europe-west4-template --project=qwiklabs-gcp-00-5aa8d2f19b34 --machine-type=e2-micro --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script-url=gs://spls/gsp215/gcpnet/httplb/startup.sh,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=519896600758-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --region=europe-west4 --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=europe-west4-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

  gcloud beta compute instance-groups managed create us-central1-mig \
    --project=qwiklabs-gcp-00-5aa8d2f19b34 \
    --base-instance-name=us-central1-mig \
    --template=projects/qwiklabs-gcp-00-5aa8d2f19b34/global/instanceTemplates/us-central1-template \
    --size=1 \
    --zones=us-central1-c,us-central1-f,us-central1-b \
    --target-distribution-shape=BALANCED \
    --instance-redistribution-type=none \
    --default-action-on-vm-failure=repair \
    --action-on-vm-failed-health-check=default-action \
    --on-repair-allow-changing-zone=no \
    --no-force-update-on-repair \
    --standby-policy-mode=manual \
    --list-managed-instances-results=pageless \
    && \
    gcloud beta compute instance-groups managed set-autoscaling us-central1-mig \
        --project=qwiklabs-gcp-00-5aa8d2f19b34 \
        --region=us-central1 \
        --mode=on \
        --min-num-replicas=1 \
        --max-num-replicas=2 \
        --target-cpu-utilization=0.8 \
        --cpu-utilization-predictive-method=none \
        --cool-down-period=45  


Configure the Application Load Balancer

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/securityPolicies
{
  "description": "Default security policy for: http-backend",
  "name": "default-security-policy-for-backend-service-http-backend",
  "rules": [
    {
      "action": "allow",
      "match": {
        "config": {
          "srcIpRanges": [
            "*"
          ]
        },
        "versionedExpr": "SRC_IPS_V1"
      },
      "priority": 2147483647
    },
    {
      "action": "throttle",
      "description": "Default rate limiting rule",
      "match": {
        "config": {
          "srcIpRanges": [
            "*"
          ]
        },
        "versionedExpr": "SRC_IPS_V1"
      },
      "priority": 2147483646,
      "rateLimitOptions": {
        "conformAction": "allow",
        "enforceOnKey": "IP",
        "exceedAction": "deny(403)",
        "rateLimitThreshold": {
          "count": 500,
          "intervalSec": 60
        }
      }
    }
  ]
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/backendServices
{
  "backends": [
    {
      "balancingMode": "RATE",
      "capacityScaler": 1,
      "group": "projects/qwiklabs-gcp-00-5aa8d2f19b34/regions/us-central1/instanceGroups/us-central1-mig",
      "maxRatePerInstance": 50
    },
    {
      "balancingMode": "UTILIZATION",
      "capacityScaler": 1,
      "group": "projects/qwiklabs-gcp-00-5aa8d2f19b34/regions/europe-west4/instanceGroups/europe-west4-mig",
      "maxUtilization": 0.8
    }
  ],
  "cdnPolicy": {
    "cacheKeyPolicy": {
      "includeHost": true,
      "includeProtocol": true,
      "includeQueryString": true
    },
    "cacheMode": "CACHE_ALL_STATIC",
    "clientTtl": 3600,
    "defaultTtl": 3600,
    "maxTtl": 86400,
    "negativeCaching": false,
    "serveWhileStale": 0
  },
  "compressionMode": "DISABLED",
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "description": "",
  "enableCDN": true,
  "healthChecks": [
    "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/healthChecks/http-health-check"
  ],
  "iap": {
    "enabled": false
  },
  "ipAddressSelectionPolicy": "IPV4_ONLY",
  "loadBalancingScheme": "EXTERNAL_MANAGED",
  "localityLbPolicy": "ROUND_ROBIN",
  "logConfig": {
    "enable": true,
    "optionalMode": "EXCLUDE_ALL_OPTIONAL",
    "sampleRate": 1
  },
  "name": "http-backend",
  "portName": "http",
  "protocol": "HTTP",
  "securityPolicy": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/securityPolicies/default-security-policy-for-backend-service-http-backend",
  "sessionAffinity": "NONE",
  "timeoutSec": 30
}

POST https://compute.googleapis.com/compute/v1/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/backendServices/http-backend/setSecurityPolicy
{
  "securityPolicy": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/securityPolicies/default-security-policy-for-backend-service-http-backend"
}

POST https://compute.googleapis.com/compute/v1/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/urlMaps
{
  "defaultService": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/backendServices/http-backend",
  "name": "http-lb"
}

POST https://compute.googleapis.com/compute/v1/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/targetHttpProxies
{
  "name": "http-lb-target-proxy",
  "urlMap": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/urlMaps/http-lb"
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/forwardingRules
{
  "IPProtocol": "TCP",
  "ipVersion": "IPV4",
  "loadBalancingScheme": "EXTERNAL_MANAGED",
  "name": "http-lb-forwarding-rule",
  "networkTier": "PREMIUM",
  "portRange": "80",
  "target": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/targetHttpProxies/http-lb-target-proxy"
}

POST https://compute.googleapis.com/compute/v1/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/targetHttpProxies
{
  "name": "http-lb-target-proxy-2",
  "urlMap": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/urlMaps/http-lb"
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/global/forwardingRules
{
  "IPProtocol": "TCP",
  "ipVersion": "IPV6",
  "loadBalancingScheme": "EXTERNAL_MANAGED",
  "name": "http-lb-forwarding-rule-2",
  "networkTier": "PREMIUM",
  "portRange": "80",
  "target": "projects/qwiklabs-gcp-00-5aa8d2f19b34/global/targetHttpProxies/http-lb-target-proxy-2"
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/regions/europe-west4/instanceGroups/europe-west4-mig/setNamedPorts
{
  "namedPorts": [
    {
      "name": "http",
      "port": 80
    }
  ]
}

POST https://compute.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-5aa8d2f19b34/regions/us-central1/instanceGroups/us-central1-mig/setNamedPorts
{
  "namedPorts": [
    {
      "name": "http",
      "port": 80
    }
  ]
}

export LB_IP=34.149.95.188:80 
34.149.95.188:80 

35.231.210.15




















  /*
  Crea la regla de firewall de HTTP

  Crea una regla de firewall para permitir el tráfico HTTP a los backends.

      En la consola de Cloud, navega al menú de navegación () > Red de VPC > Firewall.

      Observa las reglas de firewall existentes de ICMP, internas, RDP y SSH.

      Cada proyecto de Google Cloud comienza con la red predeterminada y estas reglas de firewall.

      Haz clic en Crear regla de firewall.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Nombre 	default-allow-http
      Red 	default
      Destinos 	Etiquetas de destino especificadas
      Etiquetas de destino 	http-server
      Filtro de origen 	Rangos de IPv4
      Rangos de IPv4 de origen 	0.0.0.0/0
      Protocolos y puertos 	Protocolos y puertos especificados; marca TCP y escribe 80

    Asegúrate de incluir el valor /0 en Rangos de IPv4 de origen para especificar todas las redes.

      Haz clic en Crear.

  
  Crea las reglas de firewall de verificación de estado

    Las verificaciones de estado determinan qué instancias de un balanceador de cargas pueden recibir conexiones nuevas. En el balanceo de cargas de aplicaciones, los sondeos de verificación de estado de tus instancias de balanceo de cargas provienen de las direcciones dentro de los rangos 130.211.0.0/22 y 35.191.0.0/16. Tus reglas de firewall deben permitir esas conexiones.

        En la página Políticas de firewall, haz clic en Crear regla de firewall.

        Establece los siguientes valores y deja el resto con la configuración predeterminada:
        Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
        Nombre 	default-allow-health-check
        Red 	default
        Destinos 	Etiquetas de destino especificadas
        Etiquetas de destino 	http-server
        Filtro de origen 	Rangos de IPv4
        Rangos de IPv4 de origen 	130.211.0.0/22, 35.191.0.0/16
        Protocolos y puertos 	Protocolos y puertos especificados; marca TCP
        Nota: Asegúrate de ingresar los dos rangos IPv4 de origen, uno a la vez, y de agregar un ESPACIO entre ellos.

        Haz clic en Crear.

    Haz clic en Revisar mi progreso para verificar el objetivo.

    Configurar reglas de firewall de HTTP y de verificación de estado
  Tarea 2: Configura las plantillas de instancias y crea los grupos de instancias

  Un grupo de instancias administrado usa una plantilla de instancias para crear un grupo de instancias idénticas. Úsalas para crear los backends del balanceador de cargas de aplicaciones.
  Configura las plantillas de instancias

  Una plantilla de instancias es un recurso de API que puedes usar para crear instancias de VM y grupos de instancias administrados. Las plantillas de instancias definen el tipo de máquina, la imagen de disco de arranque, la subred, las etiquetas y otras propiedades de las instancias.

  Crea una plantilla de instancias para Region 1 y una para Region 2.

      En la consola de Cloud, ve al menú de navegación () > Compute Engine > Plantillas de instancia y, luego, haz clic en Crear plantilla de instancias.

      En Nombre, escribe Region 1-template.

      En Ubicación, selecciona Global.

      En Serie, selecciona E2.

      En Tipo de máquina, selecciona e2-micro.

      Haz clic en Opciones avanzadas.

      Haz clic en Herramientas de redes. Establece el siguiente valor y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Etiquetas de red 	http-server

      Haz clic en default en Interfaces de red. Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Red 	default
      Subred 	default Region 1

      Haz clic en Listo.

  La etiqueta de red http-server garantiza que las reglas de firewall de HTTP y de verificación de estado se apliquen a estas instancias.

      Haz clic en la pestaña Administración.

      En Metadatos, haz clic en AGREGAR ELEMENTO y especifica lo siguiente:
      Clave 	Valor
      startup-script-url 	gs://spls/gsp215/gcpnet/httplb/startup.sh

  La clave startup-script-url especifica una secuencia de comandos que se ejecuta cuando se inician las instancias. Esta secuencia de comandos instala Apache y cambia la página de bienvenida para incluir la IP de cliente y el nombre, la región y la zona de la instancia de VM. Puedes explorar esta secuencia de comandos.

      Haz clic en Crear.
      Espera a que se cree la plantilla de instancias.

  Ahora copia Region 1-template y crea así otra plantilla de instancias para subnet-b:

      Haz clic en Region 1-template y, luego, en la opción +CREAR UNA SIMILAR de la parte superior.
      En Nombre, escribe Region 2-template.
      Asegúrate de que en Ubicación esté seleccionada la opción Global.
      Haz clic en Opciones avanzadas.
      Haz clic en Herramientas de redes.
      Asegúrate de agregar http-server como una etiqueta de red.
      En Interfaces de red, selecciona default (Region 2) para Subred.
      Haz clic en Listo.
      Haz clic en Crear.

  Crea los grupos de instancias administrados

  Crea un grupo de instancias administrado en Region 1 y uno en Region 2.

      En Compute Engine, haz clic en Grupos de instancias, en el menú de la izquierda.

      Haz clic en Crear grupo de instancias.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Nombre 	Region 1-mig (si es necesario, quita los espacios adicionales del nombre)
      Plantilla de instancia 	Region 1-template
      Ubicación 	Varias zonas
      Región 	Region 1
      Número mínimo de instancias 	1
      Número máximo de instancias 	2
      Indicadores de ajuste de escala automático > haz clic en el menú desplegable > Tipo de indicador 	Uso de CPU
      Uso de CPU objetivo 	80, haz clic en Listo.
      Período de inicialización 	45

  Los grupos de instancias administrados ofrecen funciones de ajuste de escala automático que te permiten agregar o quitar esas instancias automáticamente, según los aumentos o las disminuciones de la carga. El ajuste de escala automático ayuda a tus aplicaciones a administrar correctamente los aumentos en el tráfico y a reducir los costos cuando la necesidad de recursos es menor. Solo debes definir la política de ajuste de escala automático, y el escalador automático realiza el ajuste según la carga medida.

      Haz clic en Crear.

  Ahora repite el mismo procedimiento para crear un segundo grupo de instancias para Region 2-mig en Region 2:

      Haz clic en Crear grupo de instancias.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Nombre 	Region 2-mig
      Plantilla de instancia 	Region 2-template
      Ubicación 	Varias zonas
      Región 	Region 2
      Número mínimo de instancias 	1
      Número máximo de instancias 	2
      Indicadores de ajuste de escala automático > haz clic en el menú desplegable > Tipo de indicador 	Uso de CPU
      Uso de CPU objetivo 	80, haz clic en Listo.
      Período de inicialización 	45

      Haz clic en Crear.

  Haz clic en Revisar mi progreso para verificar el objetivo.

  Configurar las plantillas y los grupos de instancias
  Verifica los backends

  Verifica que las instancias de VM se creen en ambas regiones y accede a sus sitios HTTP.

      En Compute Engine, haz clic en Instancias de VM, en el menú de la izquierda.

      Toma nota de las instancias que comienzan con Region 1-mig y Region 2-mig.

      Estas forman parte de los grupos de instancias administrados.

      Haz clic en la IP externa de una instancia de Region 1-mig.

      Deberías ver la IP de cliente (tu dirección IP), el Nombre de host (comienza con Region 1-mig) y la Ubicación del servidor (una zona en Region 1).

      Haz clic en la IP externa de una instancia de Region 2-mig.

      Deberías ver la IP de cliente (tu dirección IP), el Nombre de host (comienza con Region 2-mig) y la Ubicación del servidor (una zona en Region 2).

  Nota: Los valores de Nombre de host y Ubicación del servidor identifican a dónde envía el tráfico el balanceador de cargas de aplicaciones.

  Which of these fields identify the region of the backend?
  Client IP
  Server Location
  Hostname
  Tarea 3: Configura el balanceador de cargas de aplicaciones

  Configura el balanceador de cargas de aplicaciones para balancear el tráfico entre los dos backends (Region 1-mig en Region 1 y Region 2-mig en Region 2), como se ilustra en el diagrama de red:

  Inicia la configuración

      En la consola de Cloud, haz clic en el menú de navegación () > VER TODOS LOS PRODUCTOS > Herramientas de redes > Servicios de red > Balanceo de cargas.

      Haz clic en Crear balanceador de cargas.

      En Balanceador de cargas de aplicaciones HTTP(S), haz clic en Siguiente.

      En Orientado al público o para uso interno, selecciona Orientado al público (externo) y haz clic en Siguiente.

      En Implementación global o de una sola región, selecciona Ideal para cargas de trabajo globales y haz clic en Siguiente.

      En Generación de balanceadores de cargas, selecciona Balanceador de cargas de aplicaciones externo global y haz clic en Siguiente.

      En Crear balanceador de cargas, haz clic en Configurar.

      Establece Nombre del balanceador de cargas como http-lb.

  Configura el frontend

  Las reglas de host y ruta de acceso determinan cómo se dirigirá tu tráfico. Por ejemplo, puedes dirigir el tráfico de video a un backend y el tráfico estático a otro. Sin embargo, no configuraremos dichas reglas en este lab.

      Haz clic en Configuración de frontend.

      Especifica los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Protocolo 	HTTP
      Versión de IP 	IPv4
      Dirección IP 	Efímera
      Puerto 	80

      Haz clic en Listo.

      Haz clic en Agregar IP y puerto de frontend.

      Especifica los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Protocolo 	HTTP
      Versión de IP 	IPv6
      Dirección IP 	Asignación automática
      Puerto 	80

      Haz clic en Listo.

  El balanceo de cargas de aplicaciones admite direcciones IPv4 e IPv6 para el tráfico de clientes. Las solicitudes de clientes IPv6 terminan en la capa del balanceo de cargas global y, luego, son dirigidas a través de proxy de IPv4 a tus backends.
  Configura el backend

  Los servicios de backend dirigen el tráfico entrante a uno o más backends adjuntos. Cada backend está compuesto por un grupo de instancias y metadatos con capacidad de entrega adicional.

      Haz clic en Configuración de backend.

      En Servicios y buckets de backend, haz clic en Crear un servicio de backend.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (selecciona la opción como se especifica)
      Nombre 	http-backend
      Grupo de instancias 	Region 1-mig
      Números de puerto 	80
      Modo de balanceo 	Tasa
      Máximo de RPS 	50
      Capacidad 	100

  Esta configuración significa que el balanceador de cargas intentará mantener cada instancia de Region 1-mig con 50 solicitudes por segundo (RPS) o menos.

      Haz clic en Listo.

      Haz clic en Agregar un backend.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (selecciona la opción como se especifica)
      Grupo de instancias 	Region 2-mig
      Números de puerto 	80
      Modo de balanceo 	Utilización
      Utilización máxima del backend 	80
      Capacidad 	100

  Esta configuración significa que el balanceador de cargas intentará mantener cada instancia de Region 2-mig con un uso de CPU del 80% o menos.

      Haz clic en Listo.

      En Verificación de estado, selecciona Crear una verificación de estado.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (selecciona la opción como se especifica)
      Nombre 	http-health-check
      Protocolo 	TCP
      Puerto 	80

  Las verificaciones de estado determinan qué instancias reciben conexiones nuevas. Esta verificación de estado HTTP sondea las instancias cada 5 segundos, espera hasta 5 segundos para recibir una respuesta y considera que 2 intentos exitosos o 2 intentos con errores indican que están en buen estado o en mal estado, respectivamente.

      Haz clic en Guardar.
      Marca la casilla Habilitar registro.
      Configura la Tasa de muestreo como 1.
      Haz clic en Crear para crear el servicio de backend.
      Haz clic en Aceptar.

  Revisa y crea el balanceador de cargas de aplicaciones

      Haz clic en Revisar y finalizar.
      Revisa los servicios de Backend y Frontend.
      Haz clic en Crear.
      Espera a que se cree el balanceador de cargas.
      Haz clic en el nombre del balanceador de cargas (http-lb).
      Toma nota de las direcciones IPv4 e IPv6 del balanceador de cargas para la siguiente tarea. Se llamarán [LB_IP_v4] y [LB_IP_v6], respectivamente.

  Nota: La dirección IPv6 es la que está en formato hexadecimal.

  Haz clic en Revisar mi progreso para verificar el objetivo.

  Configurar el balanceador de cargas de aplicaciones
  Tarea 4: Prueba el balanceador de cargas de aplicaciones

  Ahora que creaste el balanceador de cargas de aplicaciones para tus backends, verifica que el tráfico se desvíe al servicio de backend.

  The Application Load Balancer should forward traffic to the region that is closest to you.
  Verdadero
  Falso
  Accede al balanceador de cargas de aplicaciones

  Para probar el acceso de IPv4 al balanceador de cargas de aplicaciones, abre una nueva pestaña en tu navegador y ve a http://[LB_IP_v4]. Asegúrate de reemplazar [LB_IP_v4] por la dirección IPv4 del balanceador de cargas.
  Nota: Puedes tardar hasta 5 minutos en acceder al balanceador de cargas de aplicaciones. Mientras tanto, es probable que recibas errores 404 o 502. Sigue intentando hasta que veas la página de uno de los backends.
  Nota: Según tu proximidad a Region 1 y Region 2, el tráfico se desviará a una instancia Region 1-mig o Region 2-mig.

  Si tienes una dirección IPv6 local, prueba la dirección IPv6 del balanceador de cargas de aplicaciones. Para ello, navega a http://[LB_IP_v6]. Asegúrate de reemplazar [LB_IP_v6] por la dirección IPv6 del balanceador de cargas.
  Somete el balanceador de cargas de aplicaciones a una prueba de esfuerzo

  Crea una VM nueva para simular una carga en el balanceador de cargas de aplicaciones con siege. Luego, determina si el tráfico se balancea entre ambos backends cuando la carga es alta.

      En la consola, ve al menú de navegación () > Compute Engine > Instancias de VM.

      Haz clic en Crear instancia.

      Haz lo siguiente en Configuración de la máquina:

      Selecciona los siguientes valores:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Nombre 	siege-vm
      Región 	Region 3
      Zona 	Zone 3
      Serie 	E2

  Dado que Region 3 está más cerca de Region 1 que de Region 2, el tráfico solo se debería desviar a Region 1-mig (a menos que la carga sea muy alta).

      Haz clic en Crear.
      Espera a que se cree la instancia siege-vm.
      En siege-vm, haz clic en SSH para iniciar una terminal y conectarse.
      Ejecuta el siguiente comando para instalar siege:

  sudo apt-get -y install siege

  Se copió correctamente

      Para almacenar la dirección IPv4 del balanceador de cargas de aplicaciones en una variable de entorno, ejecuta el siguiente comando y reemplaza [LB_IP_v4] por la dirección IPv4:

  export LB_IP=[LB_IP_v4]

  Se copió correctamente

      Para simular una carga, ejecuta el siguiente comando:

  siege -c 150 -t120s http://$LB_IP

  Se copió correctamente

      En la consola de Cloud, haz clic en el menú de navegación () > VER TODOS LOS PRODUCTOS > Herramientas de redes > Servicios de red > Balanceo de cargas.

      Haz clic en Backends.

      Haz clic en http-backend.

      Navega a http-lb.

      Haz clic en la pestaña Monitoring.

      Supervisa el valor de Ubicación de frontend (tráfico total entrante) entre Norteamérica y los dos backends durante 2 o 3 minutos.

  Primero, el tráfico se dirige solo a Region 1-mig. Sin embargo, a medida que aumentan las RPS, también se dirige a Region 2.

  Esto demuestra que el tráfico se desvía al backend más cercano de forma predeterminada. Sin embargo, si la carga es muy alta, el tráfico puede distribuirse en los backends.

      Regresa a la terminal SSH de siege-vm.
      Presiona CTRL+C para detener siege si se sigue ejecutando.

  El resultado debería verse así:

  New configuration template added to /home/student-02-dd02c94b8808/.siege
  Run siege -C to view the current settings in that file
  {       "transactions":                        24729,
          "availability":                       100.00,
          "elapsed_time":                       119.07,
          "data_transferred":                     3.77,
          "response_time":                        0.66,
          "transaction_rate":                   207.68,
          "throughput":                           0.03,
          "concurrency":                        137.64,
          "successful_transactions":             24729,
          "failed_transactions":                     0,
          "longest_transaction":                 10.45,
          "shortest_transaction":                 0.03
  }

  Tarea 5: Agrega siege-vm a la lista de bloqueo

  Usa Cloud Armor para incluir siege-vm en la lista de bloqueo y evitar que acceda al balanceador de cargas de aplicaciones.
  Crea la política de seguridad

  Crea una política de seguridad de Cloud Armor con una regla de lista de bloqueo para siege-vm.

      En la consola, ve al menú de navegación () > Compute Engine > Instancias de VM.
      Toma nota de la IP externa de siege-vm. Se llamará [SIEGE_IP].

  Nota: Existen maneras de identificar la dirección IP externa de un cliente que intenta acceder a tu balanceador de cargas de aplicaciones. Por ejemplo, puedes examinar el tráfico capturado por los registros de flujo de VPC en BigQuery para determinar un alto volumen de solicitudes entrantes.

      En la consola de Cloud, haz clic en el menú de navegación () > VER TODOS LOS PRODUCTOS > Herramientas de redes > Seguridad de red > Políticas de Cloud Armor.

      Haz clic en Crear política.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Nombre 	denylist-siege
      Acción de la regla predeterminada 	Permitir

      Haz clic en Próximo paso.

      Haz clic en Agregar una regla.

      Establece los siguientes valores y deja el resto con la configuración predeterminada:
      Propiedad 	Valor (escribe el valor o selecciona la opción como se especifica)
      Condición > Coincidencia 	Ingresa la SIEGE_IP.
      Acción 	Rechazar
      Código de respuesta 	403 (Prohibido)
      Prioridad 	1000

      Haz clic en Guardar cambio en la regla.

      Haz clic en Próximo paso.

      Haz clic en Agregar destino.

      En Tipo, selecciona Servicio de backend (balanceador de cargas de aplicaciones externo).

      En Destino, selecciona http-backend y, si se te solicita, confirma Reemplazar.

      Haz clic en Crear política.

  Nota: De manera alternativa, puedes configurar la regla predeterminada como Rechazar y solo permitir tráfico proveniente de las direcciones IP o los usuarios autorizados.

      Espera a que se cree la política antes de continuar con el siguiente paso.

  Haz clic en Revisar mi progreso para verificar el objetivo.

  Agregar siege-vm a la lista de bloqueo
  Verifica la política de seguridad

  Verifica que siege-vm no pueda acceder al balanceador de cargas de aplicaciones.

      Regresa a la terminal SSH de siege-vm.
      Para acceder al balanceador de cargas, ejecuta el siguiente comando:

  curl http://$LB_IP

  Se copió correctamente

  El resultado debería verse así:

  <!doctype html><meta charset="utf-8"><meta name=viewport content="width=device-width, initial-scale=1"><title>403</title>403 Forbidden

  Nota: Es posible que la política de seguridad tarde unos minutos en aplicarse. Si puedes acceder a los backends, sigue intentando hasta que aparezca el error 403 Forbidden.

      Abre una pestaña nueva en tu navegador y ve a http://[LB_IP_v4]. Asegúrate de reemplazar [LB_IP_v4] por la dirección IPv4 del balanceador de cargas.

  Nota: Puedes acceder al balanceador de cargas de aplicaciones desde tu navegador debido a la regla predeterminada que permite el tráfico; sin embargo, no puedes acceder desde siege-vm a causa de la regla para rechazar que implementaste.

      En la terminal SSH de siege-vm, ejecuta el siguiente comando para simular una carga:

  siege -c 150 -t120s http://$LB_IP

  Se copió correctamente

  Este comando no generará ningún resultado.

  Explora los registros de la política de seguridad para determinar si también se bloquea este tráfico.

      En la consola, ve al menú de navegación > Seguridad de red > Políticas de Cloud Armor.
      Haz clic en denylist-siege.
      Haz clic en Registros.
      Haz clic en Ver registros de políticas.
      En la página de Logging, asegúrate de borrar todo el texto en la Vista previa de la consulta. Selecciona el recurso para el Balanceador de cargas de aplicaciones > http-lb-forwarding-rule > http-lb, luego, haz clic en Aplicar.
      Haz clic en Ejecutar consulta.
      Expande una entrada de registro en Resultados de la consulta.
      Expande httpRequest.

  La solicitud debería ser de la dirección IP de siege-vm. Si no es así, expande otra entrada de registro.

      Expande jsonPayload.
      Expande enforcedSecurityPolicy.
      Ten en cuenta que configuredAction se configuró como DENY para el nombre denylist-siege.

  Las políticas de seguridad de Cloud Armor crean registros que puedes explorar para determinar cuándo se rechaza o permite el tráfico, además de conocer su origen.

*/