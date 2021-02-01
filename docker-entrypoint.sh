#!/bin/sh
set -e

DNSDIST_CONF="/etc/dnsdist/dnsdist.conf"

if [ "$1" = "/usr/bin/dnsdist" ] && [ ! -f ${DNSDIST_CONF} ]; then

cat >> ${DNSDIST_CONF} <<EOL
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

if (string.match(enable_caching, "true")) then
        pcache = newPacketCache(1000000, 28800, 0, 60, 60, true)
        getPool(""):setCache(pcache)
        setStaleCacheEntriesTTL(28800)
end

-- Dynamic Blocks
local dbr = dynBlockRulesGroup()
dbr:setQueryRate(200, 10, "Exceeded Max Query per Second rate", 60, 100)
dbr:setRCodeRate(dnsdist.NXDOMAIN, 100, 10, "Exceeded Non-Existent Domain Query Type response rate", 60)
dbr:setRCodeRate(dnsdist.SERVFAIL, 100, 10, "Exceeded ServFail Query Type response rate", 60)
dbr:setRCodeRate(dnsdist.REFUSED, 100, 10, "Exceeded Refused Query Type  response rate", 60)
dbr:setRCodeRate(dnsdist.ANY, 100, 10, "Exceeded ANY Query Type response rate", 60)
dbr:setResponseByteRate(65536, 10, "Exceeded Response Bandwidth rate", 60)
dbr:excludeRange({"192.0.2.0/24", "2001:db8::/32"})

function maintenance()
        dbr:apply()
end

EOL


fi

exec "$@"
