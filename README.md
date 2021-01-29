# PowerDNS Dnsdist Docker Image

![github ci](https://github.com/hybridadmin/docker-dnsdist/workflows/ci/badge.svg?branch=main)

## Supported tags and respective `Dockerfile` links

- [`1.5.0`, `latest`](https://github.com/hybridadmin/docker-dnsdist/tree/main/1.5.0/Dockerfile)
- [`1.4.0`](https://github.com/hybridadmin/docker-dnsdist/tree/main/1.4.0/Dockerfile)

## What is Dnsdist?

dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer.
> [dnsdist.org](https://dnsdist.org/)

## How to use this image

### Standard usage

Run this container with the following command:

```console
docker run --name dnsdist -d -p 53:53/udp -p 53:53/tcp --restart=always hybridadmin/dnsdist:latest
```

To run older versions use the version tag for the required container image, i.e for version 1.4.0, run the following command:

```console
docker run --name dnsdist -d -p 53:53/udp -p 53:53/tcp --restart=always hybridadmin/dnsdist:1.4.0
```


### Configuration Settings

By default, the very basic configuration settings below have been added in /etc/dnsdist/dnsdist.conf inside the container.

Example `dnsdist.conf`:
```
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
```

Additional settings can be added based on the supported settings in the links below:
* https://dnsdist.org/reference/config.html
* https://dnsdist.org/advanced/index.html



# User feedback

## Documentation

Documentation for dnsdist is available on the [project's website](https://dnsdist.org/index.html).
