ip a a 10.0.2.2/24 dev eth0 # Configure ip on eth0 (Router side)
ip a d 127.0.0.1/8 dev lo
ip a a 172.16.0.2/32 dev lo

# Setup vxlan
ip link add vxlan10 type vxlan id 10 dev eth0 dstport 4789
ip link set vxlan10 up

# Setup bridge
ip link add br0 type bridge
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set br0 up

# Setup router
vtysh << EOF
conf
interface eth0
 ip ospf area 0
interface lo
 ip ospf area 0
router bgp 1
 neighbor 172.16.0.1 remote-as 1
 neighbor 172.16.0.1 update-source lo
 address-family l2vpn evpn
  neighbor 172.16.0.1 activate
  advertise-all-vni
 router ospf
EOF
