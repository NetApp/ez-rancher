apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: ca-issuer
  namespace: default
spec:
  ca:
    secretName: ca-key-pair

---

apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: acme-crt
spec:
  secretName: acme-crt-secret
  dnsNames:
  - foo.example.com
  - bar.example.com
  issuerRef:
    name: ca-issuer
    # We can reference ClusterIssuers by changing the kind here.
    # The default value is Issuer (i.e. a locally namespaced Issuer)
    kind: Issuer
    group: cert-manager.io
