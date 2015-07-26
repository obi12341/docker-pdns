PowerDNS Master and Poweradmin installed
===========
[![](https://badge.imagelayers.io/writl/unbound:latest.svg)](https://imagelayers.io/?images=writl/pdns-master:latest 'Get your own badge on imagelayers.io')

# Quickstart

```wget https://raw.githubusercontent.com/obi12341/docker-pdns-master/master/docker-compose.yml
docker-compose up -d```

# Running

Just use this command to start the container. PowerDNS will listen on port 53/tcp, 53/udp and 8080/tcp.

```docker run --name pdns-master --link mysql:db -d -p 53:53/udp -p 53:53 -p 8080:80 writl/pdns-master```

# Configuration
These options can be set:

- **DO_IPV6**: Enable or disable ipv6. (Default: "yes", Possible Values: "yes, no")
