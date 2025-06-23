apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: https://${cluster_endpoint}
    certificate-authority-data: ${cluster_ca_cert}
users:
- name: ${user}
  user:
    auth-provider:
      name: gcp
contexts:
- name: ${cluster_name}
  context:
    cluster: ${cluster_name}
    user: ${user}
current-context: ${cluster_name}
