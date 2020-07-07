network:
  version: 2
  ethernets:
    ens192:
      dhcp4: ${dhcp_enabled}
      nameservers:
        ${dns_servers}
      ${addresses}
      ${gateway}
