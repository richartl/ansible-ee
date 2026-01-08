# Ansible Execution Environment (EE) – ACR: `ansible-ee`

Este repositorio contiene la definición y dependencias para construir un **Ansible Execution Environment** (EE) basado en **Red Hat Ansible Automation Platform 2.6 (RHEL 9)**, incluyendo:

- Azure CLI (`az`)
- IBM Cloud CLI (`ibmcloud`)
- OCI CLI (`oci`)
- Dependencias Python para proveedores de nube
- Dependencias de sistema para RHEL 9 / UBI

La imagen resultante se publica en:

```
ansible-ee:<tag>
```

---

## Requisitos

En la máquina donde se construye la imagen:

- Docker (o Podman)
- `ansible-builder`
- Azure CLI (`az`) para autenticación a ACR
- Acceso a `registry.redhat.io` (para descargar la base image)

### Instalación recomendada de ansible-builder (macOS)

```bash
brew install pipx
pipx ensurepath
pipx install ansible-builder
ansible-builder --version
```

> Nota (Apple Silicon): el build fuerza `linux/amd64` para evitar problemas con binarios de terceros.

---

## Estructura del repositorio

```
.
├── execution-environment.yml
├── requirements.yml
├── requirements.txt
├── bindep.txt
├── ansible.cfg
├── Makefile
└── context/
    ├── Dockerfile
    └── _build/
```

### Descripción de archivos

- `execution-environment.yml`  
  Definición principal del EE (schema v3 de ansible-builder).

- `requirements.yml`  
  Colecciones y roles de Ansible (Galaxy / Automation Hub).

- `requirements.txt`  
  Dependencias Python instaladas con `pip`.

- `bindep.txt`  
  Paquetes de sistema (RHEL 9 / UBI, usando `microdnf`).

- `ansible.cfg`  
  Configuración de Ansible (sin secretos).

- `Makefile`  
  Targets para construir, probar y publicar la imagen.

- `context/`  
  Artefactos generados automáticamente por `ansible-builder`.

---

## Construir la imagen (tag `dev`)

La imagen de desarrollo se construye como:

```
ansible-ee:dev
```

### Build normal

```bash
make build-dev
```

### Build sin cache

```bash
make build-dev-nc
```

---

## Automation Hub (Red Hat)

Este EE está configurado para instalar colecciones desde **Red Hat Automation Hub**.

Variables usadas durante el build:

- `ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_URL`
- `ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_AUTH_URL`
- `ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN`

### Ejemplo de build pasando el token

```bash
export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN="xxxxx"

ansible-builder build   -t ansible-ee:dev   --container-runtime docker   --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN="$ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN"
```

> **Seguridad**  
> Nunca comitees tokens en el repositorio. Usa variables de entorno o secretos del pipeline CI/CD.

---

## Smoke test del Execution Environment

Para validar que el EE contiene todo lo necesario:

```bash
make smoke-dev
```

Este smoke test valida:

- `ansible --version`
- `az version`
- `ibmcloud --version`
- `oci --version`

---

## Login y push a Azure Container Registry (ACR)

### Autenticarse en el ACR

```bash
make login-acr
```

### Push de la imagen `dev`

```bash
make push-dev
```

---

## Publicar una versión (tag)

Para publicar una versión específica:

```bash
make build-tag IMAGE_TAG=ansible-ee:1.0.0
make push-tag  IMAGE_TAG=ansible-ee:1.0.0
```

---

## Uso del EE con ansible-navigator

En el repositorio de playbooks crea un archivo `ansible-navigator.yml`:

```yaml
ansible-navigator:
  mode: stdout
  execution-environment:
    enabled: true
    image: ansible-ee:dev
    container-engine: docker
    pull:
      policy: always
```

Ejecuta el playbook:

```bash
ansible-navigator run site.yml -i inventory.ini
```

---

## Buenas prácticas

### `.gitignore` recomendado

```gitignore
# Artefactos generados por ansible-builder
context/Dockerfile
context/_build/
```

---

### Paquetes de sistema (bindep)

En RHEL 9 / UBI la imagen base ya incluye `curl-minimal`.  
Evita instalar `curl` para no generar conflictos.

Ejemplo recomendado de `bindep.txt`:

```txt
bash
curl-minimal
ca-certificates
tar
gzip
unzip
```

---

### Configuración de `ansible.cfg`

El archivo `ansible.cfg` **no debe contener secretos**.  
Úsalo solo para defaults (callbacks, SSH, etc.).

---

## Notas finales

- Este EE está alineado con **Ansible Automation Platform 2.6**.
- Incluye CLIs oficiales de Azure, IBM Cloud y OCI.
- Está pensado para ejecutarse tanto localmente (`ansible-navigator`) como en **AAP Controller**.
- La publicación se realiza en Azure Container Registry (ACR).
