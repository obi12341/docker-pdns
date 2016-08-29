PowerDNS Authoritative server and Poweradmin
===========
[![](https://badge.imagelayers.io/secns/pdns:latest.svg)](https://imagelayers.io/?images=secns/pdns:latest 'Get your own badge on imagelayers.io')

# Quickstart

```wget https://raw.githubusercontent.com/obi12341/docker-pdns/master/docker-compose.yml && docker-compose up -d```

# Running

Just use this command to start the container. PowerDNS will listen on port 53/tcp, 53/udp and 8080/tcp.

```docker run --name pdns-master --link mysql:db -d -p 53:53/udp -p 53:53 -p 8080:80 secns/pdns:4.0.1```

Login:
``` admin / admin ```

# Configuration
These options can be set:

- **PDNS_ALLOW_AXFR_IPS**: restrict zonetransfers to originate from these IP addresses. Enter your slave IPs here. (Default: "127.0.0.1", Possible Values: "IPs comma seperated")
- **PDNS_MASTER**: act as master (Default: "yes", Possible Values: "yes, no")
- **PDNS_SLAVE**: act as slave (Default: "no", Possible Values: "yes, no")
- **PDNS_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "20", Possible Values: "<integer>")
- **PDNS_DISTRIBUTOR_THREADS**: Default number of Distributor (backend) threads to start (Default: "3", Possible Values: "<integer>")
- **PDNS_RECURSIVE_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "10", Possible Values: "<integer>")

- **PDNS_WEBSERVER**: Set it to "yes" to enable PowerDNS own webserver (Default: "no")
- **PDNS_WEBSERVER_PASSWORD**: If you set webserver=yes do not forget to set password
- **PDNS_API**: Set it to "yes" to enable PowerDNS own api. For this to work you have to enable WEBSERVER (Default: "no", Possible Values: "<integer>")
- **PDNS_API_KEY**: Key will be required by api as Header "X-API-Key"
- **PDNS_API_READONLY**: Set it to "yes" to enable api for updates (Default: "no")
- **PDNS_CARBON_SERVER**: Carbon server to collect stats (see docker-compose.yml file for example)

- **POWERADMIN_HOSTMASTER**: default hostmaster (Default: "", Possible Values: "<email>")
- **POWERADMIN_NS1**: default Nameserver 1 (Default: "", Possible Values: "<domain>")
- **POWERADMIN_NS2**: default Nameserver 2 (Default: "", Possible Values: "<domain>")
