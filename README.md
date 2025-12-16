# Google Cloud Platform (GCP) - Laboratorios y Prácticas

Este repositorio contiene una colección de laboratorios y ejercicios prácticos para Google Cloud Platform (GCP), enfocados en redes, balanceo de carga y configuración de VPC.

## 📋 Contenido

1. [Descripción General](#-descripción-general)
2. [Estructura del Repositorio](#-estructura-del-repositorio)
3. [Requisitos Previos](#-requisitos-previos)
4. [Configuración Inicial](#-configuración-inicial)
5. [Laboratorios](#-laboratorios)
6. [Scripts Útiles](#-scripts-útiles)
7. [Recursos Adicionales](#-recursos-adicionales)

## 🌟 Descripción General

Este repositorio está diseñado para ayudarte a practicar conceptos clave de Google Cloud Platform, incluyendo:

- Configuración de balanceadores de carga
- Redes VPC
- Balanceo de carga en Compute Engine
- Control de acceso en redes VPC

## 📁 Estructura del Repositorio

```
GCP/
├── 1-Configura balanceadores de cargas de aplicaciones
├── 2-Usa un balanceador de cargas de aplicaciones interno
├── 3-Implementa el balanceo de cargas en Compute Engine
├── 4-Implementa el balanceo de cargas en Compute Engine (copia)
├── 5-Multiple VPC Networks
├── 6-VPC Networks - Controlling Access
├── 7-
├── gsp315.sh
└── README.md
```

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener:

- Una cuenta de Google Cloud Platform (GCP)
- Google Cloud SDK instalado y configurado
- Permisos suficientes para crear y administrar recursos en GCP
- Conocimientos básicos de redes y sistemas distribuidos

## ⚙️ Configuración Inicial

1. Autentícate en Google Cloud:
   ```bash
   gcloud auth login
   ```

2. Configura tu proyecto de GCP:
   ```bash
   gcloud config set project [TU_PROYECTO_ID]
   ```

3. Habilita las APIs necesarias:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable deploymentmanager.googleapis.com
   ```

## 🧪 Laboratorios

### 1. Configuración de Balanceadores de Carga
- Aprende a configurar balanceadores de carga de aplicaciones
- Implementa balanceo de tráfico HTTP/HTTPS

### 2. Balanceo de Carga Interno
- Configura balanceadores de carga para tráfico interno
- Aprende sobre redes privadas en GCP

### 3-4. Balanceo de Carga en Compute Engine
- Implementa balanceo de carga para instancias de Compute Engine
- Configura grupos de instancias administradas

### 5-6. Redes VPC
- Crea y configura múltiples redes VPC
- Implementa controles de acceso y seguridad

## 🛠️ Scripts Útiles

- `gsp315.sh`: Script de automatización para configuraciones comunes en GCP

## 📚 Recursos Adicionales

- [Documentación oficial de Google Cloud](https://cloud.google.com/docs)
- [Google Cloud Free Tier](https://cloud.google.com/free)
- [Google Cloud Training](https://cloud.google.com/training)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

Desarrollado con ❤️ para el aprendizaje de Google Cloud Platform