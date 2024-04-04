const hostnameSymbol = Symbol('hostname')
prompt = () => {
    if (!db[hostnameSymbol])
      db[hostnameSymbol] = db.serverStatus().host
    return `${db.getName()}@${db[hostnameSymbol]}> `
}
