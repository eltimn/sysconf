# Caddy

## Format Caddyfile

From ansible directory on host running ansible.
```shell
docker run --rm \
  -v $PWD/roles/caddy/templates/Caddyfile.j2:/work \
  caddy caddy fmt /work --overwrite
```

## Force Rebuild
Use when using a custom Dockerfile that directly copies the Caddyfile into the container.
```shell
docker compose up --build --force-recreate -d
```

## Reload Caddy
Use when mounting Caddyfile to the local filesystem. `caddy` is the container name.
```shell
docker exec -w /etc/caddy caddy caddy reload
```

# Unifi Network App

[Self-Hosting-a-UniFi-Network-Server](https://help.ui.com/hc/en-us/articles/360012282453-Self-Hosting-a-UniFi-Network-Server)

## SSH

You can SSH into an AP (Access Point) using the IP address and the default credentials (ubnt/ubnt). Once it's been configured, it will use the configured credentials (Settings -> System -> Advanced) or the SSH certificate. ```ssh eltimn@192.168.0.16```

## Access Point Adoption

If the AP can't find the network app, try setting the inform address by SSHing into the device and running:

```shell
set-inform http://192.168.0.1:80/inform
```

[Source](https://lazyadmin.nl/home-network/unifi-set-inform/)

## Factory reset from command line

```shell
syswrapper.sh restore-default
```

## Mongo

Run mongosh in an interactive container:
```shell
docker run -it --network="unifi_default" mongodb/mongodb-community-server mongosh "mongodb://mongodb"
```

Run bash on the actual container:
```shell
docker exec -it unifi-mongo /bin/bash
```

# EdgeRouter - EdgeOS

## DNS Forwarding (cli)

Uses dnsmasq

[EdgeRouter-DNS-Forwarding-Explanation-Setup-Options](https://help.ubnt.com/hc/en-us/articles/115010913367-EdgeRouter-DNS-Forwarding-Explanation-Setup-Options)

SSH to router:
```shell
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password nelly@192.168.1.1
```

Enter configuration mode by running `configure`. When done run `commit` then `save`. See [EdgeRouter-Configuration-and-Operational-Mode](https://help.ui.com/hc/en-us/articles/204960094-EdgeRouter-Configuration-and-Operational-Mode) for more details.

* $ - Operational Mode
* \# - Configuration Mode

Add forwarding addresses (#):

```shell
set service dns forwarding options address=/ruca.home.eltimn.com/192.168.1.163
set service dns forwarding options address=/illmatic.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/dvr.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/plex.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/unifi.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/www.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/cbox.home.eltimn.com/192.168.1.158
set service dns forwarding options address=/cloud.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/ntfy.home.eltimn.com/192.168.1.50
set service dns forwarding options address=/router.home.eltimn.com/192.168.1.50
```

List all forwarding addresses (#):

```shell
show service dns forwarding options
```

Remove an address (#):

```shell
delete service dns forwarding options address=/ruca.home.eltimn.com/192.168.1.43
```

See the whole configuration ($):
```shell
show configuration
```

## Port Forwarding (web ui)

Add ports in Firewall/NAT -> Port Forwarding

Or (manually):

1. Add rule to firewall ruleset to allow port
  * Firewall Policies
  * WAN_IN -> Edit RuleSet (from Actions button)
2. Add NAT Destination rule
  * NAT -> Add Destination NAT Rule

## Resources

* [EdgeRouter-DNS-Forwarding-Setup-and-Options](https://help.ui.com/hc/en-us/articles/115010913367-EdgeRouter-DNS-Forwarding-Setup-and-Options)
* [edgeos-cli-introduction](https://networkjutsu.com/edgeos-cli-introduction/)

EdgeOS allows users to issue operational mode commands under configuration mode by prefacing it with `run`. E.g. `# run show configuration`.
