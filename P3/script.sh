# Get containers names
hosts="$(docker ps | grep gns3 | grep alpine | sed -E 's/^.* ([a-z_]+)$/\1/')"
for host in $hosts; do
	eval host$(docker exec $host sh -c "hostname" | sed -E 's/^.*([0-9])$/\1/')=$host
done

# Get routers names
routers="$(docker ps | grep gns3 | grep badass-routeur | sed -E 's/^.* ([a-z_]+)$/\1/')"
for router in $routers; do
	eval router$(docker exec $router sh -c "hostname" | sed -E 's/^.*([0-9])$/\1/')=$router
done

# Configure hosts
for i in $(seq 1 3); do
	docker exec "$(eval echo '$'host$i)" sh -c "
	ip a a 10.0.0.$i/24 dev eth0 # Configure IP
	"
done

# Configure main router
docker exec "$router1" sh -c "
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
"

# Configure leafs routers
for i in $(seq 2 4); do
	docker exec $(eval echo '$'router$i) sh -c "
	ip a a 10.0.$i.2/24 dev eth0 # Configure ip on eth0 (Router side)
	ip a d 127.0.0.1/8 dev lo
	ip a a 172.16.0.$i/32 dev lo
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
	"
done
