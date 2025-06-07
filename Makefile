build:
	docker build -t badass:host P1 -f P1/Dockerfile.host
	docker build -t badass:router P1 -f P1/Dockerfile.router

apply_p2_static:
	bash apply.sh P2/static

apply_p2_dynamic:
	bash apply.sh P2/dynamic

apply_p3:
	bash apply.sh P3