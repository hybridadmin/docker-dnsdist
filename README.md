# PowerDNS Dnsdist Docker Image

![github ci](https://github.com/hybridadmin/docker-dnsdist/workflows/ci/badge.svg?branch=main) ![Docker Pulls](https://img.shields.io/docker/pulls/hybridadmin/dnsdist)

## Supported tags and respective `Dockerfile` links

- [`master`](https://github.com/hybridadmin/docker-dnsdist/tree/main/master/Dockerfile)
- [`1.5.0`, `latest`](https://github.com/hybridadmin/docker-dnsdist/tree/main/1.5.0/Dockerfile)
- [`1.4.0`](https://github.com/hybridadmin/docker-dnsdist/tree/main/1.4.0/Dockerfile)

## What is Dnsdist?

dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer.
> [`dnsdist.org`](https://dnsdist.org/)

## Usage

### docker-compose
```yaml
---
version: "3.2"
services:
  dnsdist:
    image: hybridadmin/dnsdist:1.5.0
    container_name: dnsdist-server
    hostname: dnsdist-server #optional
    environment:
      - LISTEN_ADDR=0.0.0.0
      - SET_MAXUDPOUTSTANDING=65535
      - SET_MAXTCPCLIENTTHREADS=100
      - SET_MAXTCPCONNECTIONDURATION=10
      - SET_MAXTCPCONNECTIONSPERCLIENT=100
      - SET_MAXTCPQUERIESPERCONNECTION=100
      - SET_ECSOVERRIDE=true
      - SET_ECSSOURCEPREFIXV4=32
      - SET_ECSSOURCEPREFIXV6=64
      - SET_SERVFAILWHENNOSERVER=true
      - SET_VERBOSEHEALTHCHECKS=true
    ports:
      - 53:53/tcp
      - 53:53/udp
    restart: always
```

###  docker cli

Run a container with default settings:

```console
docker run -d -p 53:53/udp -p 53:53/tcp --restart=always hybridadmin/dnsdist:latest
```

Run a container with customized settings:
```console
docker run -d \
-e LISTEN_ADDR=0.0.0.0 \
-e SET_MAXUDPOUTSTANDING=65535 #optional \
-e SET_MAXTCPCLIENTTHREADS=100 #optional \
-e SET_MAXTCPCONNECTIONDURATION=10 #optional \
-e SET_MAXTCPCONNECTIONSPERCLIENT=100 #optional \
-e SET_MAXTCPQUERIESPERCONNECTION=100 #optional \
-e SET_ECSOVERRIDE=true #optional \
-e SET_ECSSOURCEPREFIXV4=32 #optional \
-e SET_ECSSOURCEPREFIXV6=64 #optional \
-e SET_SERVFAILWHENNOSERVER=true #optional \
-e SET_VERBOSEHEALTHCHECKS=true #optional \
-p 53:53/udp -p 53:53/tcp --restart=always hybridadmin/dnsdist:latest
```

### Configuration Settings

By default, the very basic configuration settings below have been added in `/etc/dnsdist/dnsdist.conf` inside the container.

Example `dnsdist.conf`:
```
-- Variables
local enable_caching = "true"

setMaxUDPOutstanding(65535)
setMaxTCPClientThreads(100)
setMaxTCPConnectionDuration(10)
setMaxTCPConnectionsPerClient(100)
setMaxTCPQueriesPerConnection(100)
--setECSOverride(true)
setECSSourcePrefixV4(32)
setECSSourcePrefixV6(128)
setServFailWhenNoServer(true)
--setVerboseHealthChecks(true)

-- Local Addresses binding
setLocal("0.0.0.0:53", {doTCP = true, reusePort = true})
addLocal("0.0.0.0:53", {doTCP = true, reusePort = true})

-- Backend servers
newServer({address="1.1.1.1", name="cloudflare", qps=1000, order=1, weight=1})
newServer({address="9.9.9.9", name="quad9", qps=1000, order=1, weight=1})
setServerPolicy(firstAvailable)

-- Access Lists
AllowedSubnets={"127.0.0.1/32", "0.0.0.0/0"}
setACL(AllowedSubnets)

-- Caching
if (string.match(enable_caching, "true")) then
        pcache = newPacketCache(1000000, {maxTTL=86400, minTTL=0, temporaryFailureTTL=60, staleTTL=60, dontAge=false})
        getPool(""):setCache(pcache)
        setStaleCacheEntriesTTL(28800)
end

-- Dynamic Blocks
local dbr = dynBlockRulesGroup()
dbr:setQueryRate(200, 10, "Exceeded Max Query per Second rate", 60, 100)
dbr:setRCodeRate(DNSRCode.NXDOMAIN, 100, 10, "Exceeded NXD rate", 60)
dbr:setRCodeRate(DNSRCode.SERVFAIL, 100, 10, "Exceeded ServFail rate", 60)
dbr:setQTypeRate(DNSQType.ANY, 50, 10, "Exceeded ANY rate", 60)
dbr:setResponseByteRate(10000, 10, "Exceeded resp BW rate", 60)
dbr:excludeRange({"192.0.2.0/24", "2001:db8::/32"})

function maintenance()
        dbr:apply()
end
```

Additional settings can be added based on the supported settings in the links below:
* https://dnsdist.org/reference/config.html
* https://dnsdist.org/advanced/index.html

## Environment Variables

| Variable | Function |
| :----: | --- |
| `LISTEN_ADDR` | The address(es) to bind to |
| `SET_MAXUDPOUTSTANDING` | The maximum number of outstanding UDP queries to a given backend server |
| `SET_MAXTCPCLIENTTHREADS` | The maximum of TCP client threads, handling TCP connections |
| `SET_MAXTCPCONNECTIONDURATION` | The maximum duration of an incoming TCP connection, in seconds |
| `SET_MAXTCPCONNECTIONSPERCLIENT` | The maximum number of TCP connections per client |
| `SET_MAXTCPQUERIESPERCONNECTION` | The maximum number of queries in an incoming TCP connection |
| `SET_ECSOVERRIDE` | Override an existing option already present in the query when `useClientSubnet` is set and dnsdist adds an EDNS Client Subnet Client option to the query |
| `SET_ECSSOURCEPREFIXV4` | The subnet prefix to be used to truncate the requestors IPv4 address when `useClientSubnet` is set |
| `SET_ECSSOURCEPREFIXV6` | The subnet prefix to be used to truncate the requestors IPv6 address when `useClientSubnet` is set |
| `SET_SERVFAILWHENNOSERVER` | Control whether to return a ServFail when no servers are available, or drop the query |
| `SET_VERBOSEHEALTHCHECKS` | Set whether health check errors should be logged |
