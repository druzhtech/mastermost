import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-ethers';
import 'hardhat-deploy';
import "hardhat-deploy-ethers";

import * as dotenv from 'dotenv';
import { HardhatUserConfig } from 'hardhat/config';

dotenv.config();
/* This loads the variables in your .env file to `process.env` */

const { DEPLOYER_PRIVATE_KEY, INFURA_PROJECT_ID } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
    },
    localhost: {
    },
    masterchain: {
      url: `https://learn.fintechru.org/masterchange/web3`,
      // chainId: 42,
      // accounts: [`0x${DEPLOYER_PRIVATE_KEY}`],
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
