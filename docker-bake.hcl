# docker-bake.hcl

variable "IMAGE_NAME" {
  default = "hello-world"
}

variable "REGISTRY" {
  default = "localhost"
}

variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["multiarch"]
}

target "multiarch" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/s390x",
    "linux/ppc64le"
  ]
  tags = ["${IMAGE_NAME}:${TAG}"]
  output = ["type=oci,dest=./hello-world.tar"]
}

target "local" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["${IMAGE_NAME}:local"]
  output = ["type=docker"]
}

# Individual architecture targets for local testing
target "amd64" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["${IMAGE_NAME}:amd64"]
  output = ["type=docker"]
}

target "arm64" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/arm64"]
  tags = ["${IMAGE_NAME}:arm64"]
  output = ["type=docker"]
}

target "s390x" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/s390x"]
  tags = ["${IMAGE_NAME}:s390x"]
  output = ["type=docker"]
}

target "ppc64le" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/ppc64le"]
  tags = ["${IMAGE_NAME}:ppc64le"]
  output = ["type=docker"]
}
