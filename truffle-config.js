module.exports = {
  networks: {
    development: {
      host:       "ganache",
      port:       8545,
      network_id: "1337"
    },
    local: {
      host:       "127.0.0.1",
      port:       8545,
      network_id: "1337"
    }
  },
  compilers: {
    solc: {
      version: "0.4.25"
    }
  }
};
