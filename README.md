# Multi-Architecture Docker Build with Buildx + Kubernetes

This project demonstrates building a simple C "Hello World" program for multiple architectures (x86_64,
aarch64, s390x, ppc64le) using Docker Buildx with a Kubernetes backend.

Files

- hello.c - Simple C hello world program
- Dockerfile - Multi-stage Dockerfile that builds static binaries for each target architecture
- docker-bake.hcl - Docker bake configuration for multi-arch builds
- hello-world.tar - Built OCI image tarball containing all architectures

Prerequisites

- Docker with Buildx plugin
- Kubernetes/OpenShift cluster access
- kubectl or oc CLI

Setup

1. Create the Buildx Kubernetes Builder

```bash
namespace=docker-multiarch-testing
serviceaccount=buildx-privileged
oc project $namespace

oc create serviceaccount $serviceaccount
oc adm policy add-scc-to-user privileged -z buildx-privileged

docker buildx create \
  --name kube \
  --driver kubernetes \
  --driver-opt rootless=true \
  --driver-opt serviceaccount=$serviceaccount \
  --driver-opt requests.ephemeral-storage=128Gi \
  --bootstrap \
  --driver-opt qemu.install=true
```

> Note: The buildx-privileged service account needs the privileged SecurityContextConstraint (SCC) on OpenShift

2. Patch the BuildKit Deployment (OpenShift)

The default AppArmor settings can cause permission issues. Patch the deployment:

```bash
oc patch deployment kube0 --type='json' -p='[
  {"op": "remove", "path":
"/spec/template/metadata/annotations/container.apparmor.security.beta.kubernetes.io~1buildkitd"},
  {"op": "add", "path": "/spec/template/spec/securityContext", "value": {
    "seLinuxOptions": {
      "user": "system_u",
      "role": "system_r",
      "type": "spc_t",
      "level": "s0"
    }
  }}
]'
```

Wait for the new pod to be ready:

```bash
kubectl get pods -w
```

3. Verify Builder Status

```bash
docker buildx ls
```

You should see the kube builder with status running and support for multiple platforms.

Building

Build All Architectures (OCI Tarball)

```bash
docker buildx ls
docker buildx bake -f docker-bake.hcl --builder kube multiarch
```

docker buildx ls

This creates hello-world.tar containing images for:

- linux/amd64
- linux/arm64
- linux/s390x
- linux/ppc64le

Build Single Architecture (Local Docker)

# Build for local testing (amd64 only)

docker buildx bake -f docker-bake.hcl --builder kube local

# Or apply the OpenShift patch from step 2 above to adjust SELinux context.

### Builder Not Running

Check the buildkit pod status:

````bash
kubectl get pods -l app=buildkit
kubectl logs -l app=buildkit
QEMU Emulation Issues

Ensure QEMU is installed in the builder:

```bash
docker buildx ls
docker buildx create --name kube --driver kubernetes --driver-opt qemu.install=true --bootstrap
", filename="docker-buildx-multiarch-poc/4. Build Individual Architectures
docker buildx bake -f docker-bake.hcl --builder kube amd64
docker buildx bake -f docker-bake.hcl --builder kube arm64
docker buildx bake -f docker-bake.hcl --builder kube s390x
docker buildx bake -f docker-bake.hcl --builder kube ppc64le
````

Push to Registry

To push to a registry instead of creating a local tarball, edit docker-bake.hcl and change:

```
output = ["type=image,push=true"]
tags = ["quay.io/youruser/hello-world:latest"]
```

Then run:

```bash
docker buildx bake -f docker-bake.hcl --builder kube
```

```bash
# Remove the builder
docker buildx rm kube
# Remove built images
docker rmi hello-world:local hello-world:amd64 hello-world:arm64 hello-world:s390x hello-world:ppc64le
```

#Troubleshooting

##Permission Denied on /dev/pts

If you see errors like:

```
error mounting "devpts" to rootfs at "/dev/pts": mount src=devpts, dst=/dev/pts, ... permission denied
```

Apply the OpenShift patch from step 2 above to adjust SELinux context.

## Builder Not Running

Check the buildkit pod status:

```bash
kubectl get pods -l app=buildkit
kubectl logs -l app=buildkit
```

QEMU Emulation Issues

Ensure QEMU is installed in the builder:

```bash
docker buildx create --name kube --driver kubernetes --driver-opt qemu.install=true --bootstrap
```

```

```
