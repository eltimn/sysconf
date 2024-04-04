db.getSiblingDB("unifi").createUser({user: "unifi", pwd: "ZT9Hc5HV62yua4akPY", roles: [{role: "dbOwner", db: "unifi"}]});
db.getSiblingDB("unifi_stat").createUser({user: "unifi", pwd: "ZT9Hc5HV62yua4akPY", roles: [{role: "dbOwner", db: "unifi_stat"}]});
