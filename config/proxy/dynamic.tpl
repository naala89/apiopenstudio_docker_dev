http:
  routers:
    traefik:
      rule: "Host(`PROXY_DOMAIN`)"
      service: "api@internal"
      tls:
        domains:
          - main: "DOMAIN"
            sans:
              - "*.DOMAIN"

tls:
  certificates:
    - certFile: "/etc/certs/DOMAIN.pem"
      keyFile: "/etc/certs/DOMAIN-key.pem"
