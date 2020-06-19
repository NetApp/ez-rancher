local-hostname: ${hostname}
instance-id: ${hostname}
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: true
      nameservers:
        addresses:
          - 1.1.1.1 # Set DNS ip address here
          - 8.8.8.8
      ${addresses_key} ${addresses_val}
      ${gateway}