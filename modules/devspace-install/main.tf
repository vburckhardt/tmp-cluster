### ClusterRoleBinding to allow pulling images from internal registry
resource "kubectl_manifest" "image_puller_clusterrolebinding" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: image-puller-binding
    subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: 'system:authenticated'
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: 'system:image-puller'
  YAML
}

### Custom UDI Image Stream
resource "kubectl_manifest" "udi_custom_image_stream" {
  depends_on = [kubectl_manifest.image_puller_clusterrolebinding]
  
  yaml_body = <<-YAML
    apiVersion: image.openshift.io/v1
    kind: ImageStream
    metadata:
      name: udi-custom
      namespace: ${var.namespace}
    spec:
      lookupPolicy:
        local: false
  YAML
}

### Custom UDI Build Config
resource "kubectl_manifest" "udi_custom_build_config" {
  yaml_body = <<-YAML
    apiVersion: build.openshift.io/v1
    kind: BuildConfig
    metadata:
      name: txchange-tf
      namespace: ${var.namespace}
    spec:
      source:
        type: Dockerfile
        dockerfile: |
          FROM quay.io/devfile/base-developer-image:ubi9-latest

          USER root
          RUN dnf install -y dnf-utils
          RUN dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
          RUN dnf -y install terraform

          RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh | bash

          RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

          # Install the ibmcloud CLI & all plugins
          RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
          ibmcloud config --check-version=false && \
          chmod +x $(which ibmcloud) && \
          ibmcloud plugin install -a -f

          USER 1001  # reset to non-root if required
      strategy:
        type: Docker
        dockerStrategy:
          from:
            kind: DockerImage
            name: quay.io/devfile/base-developer-image:ubi9-latest
      output:
        to:
          kind: ImageStreamTag
          name: udi-custom:latest
      triggers:
        - type: ConfigChange
      runPolicy: Serial
      successfulBuildsHistoryLimit: 5
      failedBuildsHistoryLimit: 5
  YAML
}

### Data source to reference the created image stream
data "kubernetes_resource" "udi_custom_image_stream" {
  depends_on  = [kubectl_manifest.udi_custom_image_stream]
  api_version = "image.openshift.io/v1"
  kind        = "ImageStream"
  metadata {
    name      = "udi-custom"
    namespace = var.namespace
  }
}

########################################################################################################################
# DevSpaces Operators Helm Chart (OLM Subscriptions)
########################################################################################################################
resource "helm_release" "devspaces_operators" {
  name             = "devspaces-operators"
  chart            = "${path.module}/helm-charts/devspaces-operators"
  namespace        = var.namespace
  create_namespace = false
  timeout          = 600
  wait             = true
  recreate_pods    = false
  force_update     = false
  reset_values     = true

  set = [
    {
      name  = "namespace"
      value = var.namespace
    }
  ]
}

########################################################################################################################
# Wait for operators to be ready
########################################################################################################################
resource "time_sleep" "wait_for_operators" {
  depends_on = [helm_release.devspaces_operators]
  
  create_duration = "300s" # Wait 5 minutes for operators to be installed and ready
}

########################################################################################################################
# DevSpaces Configuration Helm Chart (Custom Resources)
########################################################################################################################
resource "helm_release" "devspaces" {
  depends_on = [
    data.kubernetes_resource.udi_custom_image_stream,
    time_sleep.wait_for_operators
  ]

  name             = "devspaces"
  chart            = "${path.module}/helm-charts/devspaces"
  namespace        = var.namespace
  create_namespace = false
  timeout          = 1200
  wait             = true
  recreate_pods    = false
  force_update     = false
  reset_values     = true

  set = [
    {
      name  = "namespace"
      value = var.namespace
    },
    {
      name  = "cluster_id"
      value = var.cluster_id
    },
    {
      name  = "customImage.imageRegistry"
      value = data.kubernetes_resource.udi_custom_image_stream.object.status.dockerImageRepository
    }
  ]
}