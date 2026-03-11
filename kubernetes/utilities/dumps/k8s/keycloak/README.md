# Keycloak + LDAP Identity Stack for Avika

This deploys a complete identity management stack:
- **OpenLDAP** - Source of truth for users and groups
- **phpLDAPadmin** - Web UI to manage LDAP
- **Keycloak** - Identity provider that federates from LDAP, provides OIDC/SAML

Applications can authenticate via:
- **LDAP directly** - HAProxy, legacy apps
- **OIDC/OAuth2** - Grafana, ArgoCD, modern apps
- **SAML** - Enterprise apps

## Quick Start

```bash
# Deploy everything in order
kubectl apply -f deploy/k8s/keycloak/openldap.yaml
kubectl apply -f deploy/k8s/keycloak/phpldapadmin.yaml
kubectl apply -f deploy/k8s/keycloak/ldap-bootstrap.yaml
kubectl apply -f deploy/k8s/keycloak/keycloak-postgres.yaml
kubectl apply -f deploy/k8s/keycloak/keycloak-realm-config.yaml
kubectl apply -f deploy/k8s/keycloak/keycloak-deployment.yaml

# Wait for Keycloak (takes 2-3 minutes on first start)
kubectl -n avika wait --for=condition=ready pod -l app=keycloak --timeout=300s

# Configure LDAP federation
kubectl apply -f deploy/k8s/keycloak/keycloak-ldap-federation.yaml
kubectl -n avika wait --for=condition=complete job/keycloak-ldap-federation --timeout=120s
```

## Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Keycloak Admin** | `http://<node-ip>:30180` | admin / KeycloakAdmin2024! |
| **phpLDAPadmin** | `http://<node-ip>:30280` | cn=admin,dc=avika,dc=local / LdapAdmin2024! |
| **LDAP** | `ldap://<node-ip>:30389` | cn=admin,dc=avika,dc=local / LdapAdmin2024! |

### Port Forward (alternative)
```bash
# Keycloak
kubectl -n avika port-forward svc/keycloak 8080:8080
# Access at http://localhost:8080

# phpLDAPadmin  
kubectl -n avika port-forward svc/phpldapadmin 8081:80
# Access at http://localhost:8081

# LDAP (for ldapsearch, etc)
kubectl -n avika port-forward svc/openldap 389:389
```

## Pre-configured Users

All users are in the `avika` realm:

| Username | Password | Role | Groups | Description |
|----------|----------|------|--------|-------------|
| `admin` | `admin123` | admin, grafana-admin, argocd-admin | admins | Full access to all systems |
| `developer1` | `dev123` | developer, grafana-editor | developers | Alice - can edit dashboards |
| `developer2` | `dev123` | developer, grafana-editor | developers | Bob - can edit dashboards |
| `viewer1` | `view123` | viewer | viewers | Charlie - read-only access |
| `viewer2` | `view123` | viewer | viewers | Diana - read-only access |

## Pre-configured Client Applications

| Client ID | Secret | Intended For |
|-----------|--------|--------------|
| `grafana` | `grafana-client-secret-2024` | Grafana OIDC |
| `argocd` | `argocd-client-secret-2024` | ArgoCD OIDC |
| `kibana` | `kibana-client-secret-2024` | Kibana/ELK OIDC |
| `haproxy` | `haproxy-client-secret-2024` | HAProxy OAuth2 |

## Grafana Integration

Add this to your Grafana configuration (values.yaml or grafana.ini):

```yaml
# For Helm values.yaml
grafana.ini:
  server:
    root_url: "%(protocol)s://%(domain)s:%(http_port)s/grafana/"
  auth.generic_oauth:
    enabled: true
    name: Keycloak
    allow_sign_up: true
    client_id: grafana
    client_secret: grafana-client-secret-2024
    scopes: openid email profile roles groups
    auth_url: http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/auth
    token_url: http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/token
    api_url: http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/userinfo
    role_attribute_path: contains(roles[*], 'grafana-admin') && 'Admin' || contains(roles[*], 'grafana-editor') && 'Editor' || 'Viewer'
    groups_attribute_path: groups
```

## ArgoCD Integration

Add to ArgoCD ConfigMap (`argocd-cm`):

```yaml
data:
  url: https://argocd.avika.local
  oidc.config: |
    name: Keycloak
    issuer: http://keycloak.avika.svc.cluster.local:8080/realms/avika
    clientID: argocd
    clientSecret: argocd-client-secret-2024
    requestedScopes: ["openid", "profile", "email", "groups"]
```

And ArgoCD RBAC (`argocd-rbac-cm`):

```yaml
data:
  policy.csv: |
    g, admins, role:admin
    g, developers, role:readonly
```

## Adding New Users via UI

1. Go to Keycloak Admin Console: `http://<node-ip>:30180`
2. Login with admin credentials
3. Select `avika` realm (dropdown top-left)
4. Go to **Users** → **Add user**
5. Fill in details and click **Create**
6. Go to **Credentials** tab → **Set password**
7. Go to **Role mapping** tab → Assign roles
8. Go to **Groups** tab → Join groups

## Adding New Users

### Option 1: Via phpLDAPadmin (Recommended)

1. Go to `http://<node-ip>:30280`
2. Login with: `cn=admin,dc=avika,dc=local` / `LdapAdmin2024!`
3. Navigate to `ou=users,dc=avika,dc=local`
4. Click "Create a child entry"
5. Choose "Generic: User Account" template
6. Fill in the details and create

Users added to LDAP are automatically available in Keycloak (on next login or sync).

### Option 2: Via LDAP CLI

```bash
# Port forward to LDAP
kubectl -n avika port-forward svc/openldap 389:389 &

# Add user via ldapadd
cat <<EOF | ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=avika,dc=local" -w 'LdapAdmin2024!'
dn: cn=newuser,ou=users,dc=avika,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: newuser
sn: User
givenName: New
uid: newuser
uidNumber: 2001
gidNumber: 1001
homeDirectory: /home/newuser
mail: newuser@avika.local
userPassword: newpass123
EOF

# Add to a group
cat <<EOF | ldapmodify -x -H ldap://localhost:389 -D "cn=admin,dc=avika,dc=local" -w 'LdapAdmin2024!'
dn: cn=developers,ou=groups,dc=avika,dc=local
changetype: modify
add: member
member: cn=newuser,ou=users,dc=avika,dc=local
EOF
```

### Option 3: Via Keycloak Admin CLI (creates in Keycloak + LDAP)

```bash
# Get Keycloak pod name
KC_POD=$(kubectl -n avika get pod -l app=keycloak -o jsonpath='{.items[0].metadata.name}')

# Authenticate
kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 --realm master --user admin --password 'KeycloakAdmin2024!'

# Create user (will be synced to LDAP since federation is WRITABLE)
kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh create users \
  -r avika \
  -s username=newuser \
  -s email=newuser@avika.local \
  -s firstName=New \
  -s lastName=User \
  -s enabled=true

# Set password
kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh set-password \
  -r avika --username newuser --new-password 'newpass123'
```

## Sync LDAP Users to Keycloak

If you add users directly to LDAP, trigger a sync:

```bash
KC_POD=$(kubectl -n avika get pod -l app=keycloak -o jsonpath='{.items[0].metadata.name}')
kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 --realm master --user admin --password 'KeycloakAdmin2024!'

# Get LDAP component ID
LDAP_ID=$(kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh get components -r avika --query name=ldap-avika --fields id --format csv | tail -1 | tr -d '"')

# Trigger full sync
kubectl -n avika exec $KC_POD -- /opt/keycloak/bin/kcadm.sh create user-storage/${LDAP_ID}/sync -r avika -s action=triggerFullSync
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Users                                 │
│              (browser login to any app)                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Keycloak (IdP)                            │
│              http://keycloak.avika:8080                      │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Realm: avika                                            ││
│  │ - LDAP Federation (syncs users/groups from OpenLDAP)   ││
│  │ - Clients (grafana, argocd, kibana, haproxy)           ││
│  │ - Role mappings for applications                        ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
        ▼                           ▼
┌───────────────────┐     ┌─────────────────────────────────────┐
│    OpenLDAP       │     │         Applications                 │
│  (User Storage)   │     │                                     │
│                   │     │  OIDC/OAuth2         LDAP Direct    │
│  dc=avika,dc=local│     │  ┌────────┐  ┌────────┐  ┌────────┐│
│  ├─ou=users       │◄────│  │Grafana │  │ ArgoCD │  │HAProxy ││
│  │ ├─admin        │     │  └────────┘  └────────┘  └────────┘│
│  │ ├─developer1   │     │  ┌────────┐                        │
│  │ ├─developer2   │     │  │ Kibana │                        │
│  │ ├─viewer1      │     │  └────────┘                        │
│  │ └─viewer2      │     └─────────────────────────────────────┘
│  └─ou=groups      │
│    ├─admins       │
│    ├─developers   │
│    ├─viewers      │
│    ├─grafana-*    │
│    └─argocd-*     │
└───────────────────┘

┌───────────────────┐
│  phpLDAPadmin     │  ◄── Web UI for LDAP management
│  :30280           │
└───────────────────┘
```

## LDAP Structure

```
dc=avika,dc=local
├── ou=users
│   ├── cn=admin        (Admin User, admin@avika.local)
│   ├── cn=developer1   (Alice Developer, dev1@avika.local)
│   ├── cn=developer2   (Bob Developer, dev2@avika.local)
│   ├── cn=viewer1      (Charlie Viewer, viewer1@avika.local)
│   └── cn=viewer2      (Diana Viewer, viewer2@avika.local)
└── ou=groups
    ├── cn=admins           (members: admin)
    ├── cn=developers       (members: developer1, developer2)
    ├── cn=viewers          (members: viewer1, viewer2)
    ├── cn=grafana-admins   (members: admin)
    ├── cn=grafana-editors  (members: developer1, developer2)
    └── cn=argocd-admins    (members: admin)
```

## Endpoints

### Keycloak (OIDC/SAML)

| Endpoint | URL |
|----------|-----|
| Admin Console | `http://<node-ip>:30180` |
| OIDC Discovery | `http://keycloak.avika.svc.cluster.local:8080/realms/avika/.well-known/openid-configuration` |
| Authorization | `http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/auth` |
| Token | `http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/token` |
| UserInfo | `http://keycloak.avika.svc.cluster.local:8080/realms/avika/protocol/openid-connect/userinfo` |

### LDAP

| Endpoint | URL |
|----------|-----|
| LDAP (internal) | `ldap://openldap.avika.svc.cluster.local:389` |
| LDAP (external) | `ldap://<node-ip>:30389` |
| phpLDAPadmin | `http://<node-ip>:30280` |
| Base DN | `dc=avika,dc=local` |
| Users DN | `ou=users,dc=avika,dc=local` |
| Groups DN | `ou=groups,dc=avika,dc=local` |
| Bind DN | `cn=admin,dc=avika,dc=local` |

## Troubleshooting

```bash
# Check logs
kubectl -n avika logs -l app=keycloak -f

# Check postgres logs
kubectl -n avika logs -l app=keycloak-postgres -f

# Restart keycloak (if needed)
kubectl -n avika rollout restart deployment keycloak

# Check realm was imported
kubectl -n avika exec -it deploy/keycloak -- /opt/keycloak/bin/kcadm.sh get realms --server http://localhost:8080 --realm master --user admin --password 'KeycloakAdmin2024!'
```
