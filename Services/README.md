# Services layout

Services are grouped by role:

- `Platform/`: cluster platform components that other services depend on, such as
  Argo CD, cert-manager, DNS automation, Longhorn, observability, and CI/CD.
- `Security/`: security and compliance services, such as Falco, Trivy Operator,
  Wazuh, and identity/security tooling.
- `Utilities/`: user-facing utility applications, such as Dionysus and Mealie.
- `Media/`: media-management workloads.

Argo CD `Application` wrappers should live in the category that owns the service.
The platform root may include category kustomizations, but individual service
wrappers should not be left under `Platform/` unless they are platform services.
