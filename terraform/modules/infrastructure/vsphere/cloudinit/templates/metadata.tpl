local-hostname: ${hostname}
instance-id: ${hostname}
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: true
      nameservers:
        ${dns_servers}
      ${addresses_key} ${addresses_val}
      ${gateway}