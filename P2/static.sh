# Get containers names
hosts="$(docker ps | grep gns3 | grep alpine | sed -E 's/^.* ([a-z_]+)$/\1/')"
host1="$(echo "$hosts" | head -n1)"
host2="$(echo "$hosts" | tail -n1)"

routers="$(docker ps | grep gns3 | grep badass-routeur | sed -E 's/^.* ([a-z_]+)$/\1/')"
router1="$(echo "$routers" | head -n1)"
router2="$(echo "$routers" | tail -n1)"

# Host 1
docker exec "$host1" sh -c "
ip a a 10.0.0.1/24 dev eth0 # Configure IP
"

# Host 2
docker exec "$host2" sh -c "
ip a a 10.0.0.2/24 dev eth0 # Configure IP
"

# Router 1
docker exec "$router1" sh -c "ip a a 10.0.1.1/24 dev eth0 # Configure ip on eth0 (internet side)
# Setup vxlan
ip link add vxlan10 type vxlan id 10 local 10.0.1.1 remote 10.0.1.2 dev eth0 dstport 4789
ip link set vxlan10 up
# Setup bridge
ip link add br0 type bridge
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set br0 up
"

# Router 2
docker exec "$router2" sh -c "ip a a 10.0.1.2/24 dev eth0 # Configure ip on eth0 (internet side)
# Setup vxlan
ip link add vxlan10 type vxlan id 10 local 10.0.1.2 remote 10.0.1.1 dev eth0 dstport 4789
ip link set vxlan10 up
# Setup bridge
ip link add br0 type bridge
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set br0 up
"
