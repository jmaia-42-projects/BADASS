ip a a 10.0.2.1/24 dev eth0 # Configure ip on eth0
ip a a 10.0.3.1/24 dev eth1 # Configure ip on eth1
ip a a 10.0.4.1/24 dev eth2 # Configure ip on eth2
ip a d 127.0.0.1/8 dev lo
ip a a 172.16.0.1/32 dev lo

# Setup router
vtysh << EOF
conf
router bgp 1
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 172.16.0.0/24 peer-group ibgp
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 router ospf
  network 0.0.0.0/0 area 0
EOF
