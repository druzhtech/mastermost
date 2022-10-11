module.exports = {
  version: "0.0.1",
  description: "",
  keywords: [
    "ethereum",
    "addition"
  ],
  dependencies: {
    "owned": "^0.0.1",
    "erc20-token": "1.0.0"
  },
  compilers: {
    solc: {
      version: "native", // A version or constraint - Ex. "^0.5.0"
      targets: [{
        // properties: {
        //   contractName: "MyContract",
        //   /* other literal properties */
        // },
        fileProperties: {
          abi: "./output/contract.abi",
          bytecode: "./output/contract.bytecode",
          /* other properties encoded in output files */
        }
      }]
      // Can also be set to "native" to use a native solc
      // docker: boolean, // Use a version obtained through docker
      // parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      // settings: {
      //   optimizer: {
      //     enabled: <boolean>,
      //     runs: <number>   // Optimize for how many times you intend to run the code
      //   },
      //   evmVersion: <string> // Default: "istanbul"
      // },
      // modelCheckerSettings: {
      //   // contains options for SMTChecker
      // }
    }
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    develop: {
      port: 8545
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/YOUR-PROJECT-ID");
      },
      network_id: '3',
    },
    test: {
      provider: function () {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:8545/");
      },
      network_id: '*',
    },
    live: {
      host: "178.25.19.88", // Random IP for example purposes (do not use)
      port: 80,
      network_id: 1,        // Ethereum public network
      // optional config values:
      // gas
      // gasPrice
      // from - default address to use for any transaction Truffle makes during migrations
      // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
      //          - function that returns a web3 provider instance (see below.)
      //          - if specified, host and port are ignored.
      // skipDryRun: - true if you don't want to test run the migration locally before the actual migration (default is false)
      // confirmations: - number of confirmations to wait between deployments (default: 0)
      // timeoutBlocks: - if a transaction is not mined, keep waiting for this number of blocks (default is 50)
      // deploymentPollingInterval: - duration between checks for completion of deployment transactions
      // disableConfirmationListener: - true to disable web3's confirmation listener
    }
  },
  etherscan: {
    apiKey: "0123456789abcdef0123456789abcdef" //replace this with your API key if you have one
  },
  sourceFetchers: ["sourcify", "etherscan"], //prefer Sourcify over Etherscan
  environments: {
    /* ... other environments */

    // development: {
    //   ipfs: {
    //     address: 'http://localhost:5001
    //   }
    // },
    // production: {
    //   ipfs: {
    //     address: 'https://ipfs.infura.io:5001'
    //   }
    // }
  }
};
