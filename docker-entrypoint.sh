#!/bin/sh
set -e

DNSDIST_CONF="/etc/dnsdist/dnsdist.conf"
DNSDIST_VERSION=$(dpkg -l | grep dnsdist | awk '{print $3}' | cut -c1-5)

if [ "$1" = "/usr/bin/dnsdist" ]; then

cat >> ${DNSDIST_CONF} <<EOL
-- Variables
local enable_caching = "true"

setMaxUDPOutstanding(${SET_MAXUDPOUTSTANDING:-65535})
setMaxTCPClientThreads(${SET_MAXTCPCLIENTTHREADS:-100})
setMaxTCPConnectionDuration(${SET_MAXTCPCONNECTIONDURATION:-10})
setMaxTCPConnectionsPerClient(${SET_MAXTCPCONNECTIONSPERCLIENT:-100})
setMaxTCPQueriesPerConnection(${SET_MAXTCPQUERIESPERCONNECTION:-100})
--setECSOverride(${SET_ECSOVERRIDE:-true})
setECSSourcePrefixV4(${SET_ECSSOURCEPREFIXV4:-32})
setECSSourcePrefixV6(${SET_ECSSOURCEPREFIXV6:-128})
setServFailWhenNoServer(${SET_SERVFAILWHENNOSERVER:-true})
--setVerboseHealthChecks(${SET_VERBOSEHEALTHCHECKS:-true})

-- Local Addresses binding
setLocal("${LISTEN_ADDR:-0.0.0.0}:53", {doTCP = true, reusePort = true})
addLocal("${LISTEN_ADDR:-0.0.0.0}:53", {doTCP = true, reusePort = true})

-- Backend servers
newServer({address="1.1.1.1", name="cloudflare", qps=2000, order=1, weight=1, checkName="c.root-servers.net.", checkType="A", maxCheckFailures=1, retries=5})
newServer({address="9.9.9.9", name="quad9", qps=2000, order=2, weight=2, checkName="d.root-servers.net.", checkType="A", maxCheckFailures=1, retries=5})
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

EOL


fi

exec "$@"
