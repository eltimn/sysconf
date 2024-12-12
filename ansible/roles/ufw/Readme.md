## Notes

Docker's iptables rules execute before any ufw rules do, therefore they will not have an effect on exposed docker ports. However ports are avaiable to the localhost and to other hosts on the same docker network without exposing them. For instance, Caddy running natively can access ports on docker containers even if they are not exposed. ufw is still useful for securing ports used by native running apps, like Caddy and Channels DVR on illmatic.

**References**

* [Docker Firewall](https://docs.docker.com/engine/network/packet-filtering-firewalls/#docker-and-ufw)
