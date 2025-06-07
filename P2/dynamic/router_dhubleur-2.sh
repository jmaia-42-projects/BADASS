ip a a 10.0.1.2/24 dev eth0 # Configure ip on eth0 (internet side)

# Setup vxlan
ip link add vxlan10 type vxlan id 10 local 10.0.1.2 group 225.0.0.1 dev eth0 dstport 4789
ip link set vxlan10 up

# Setup bridge
ip link add br0 type bridge
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set br0 up
