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
    - certFile: "/etc/certs/DOMAIN.crt"
      keyFile: "/etc/certs/DOMAIN.key"
