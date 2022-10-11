import '@nomiclabs/hardhat-waffle';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

task('deploy', 'Deploy Mastermost contract').setAction(
  async (_, hre: HardhatRuntimeEnvironment): Promise<void> => {
    const Mastermost = await hre.ethers.getContractFactory('Mastermost');
    const masterMost = await Mastermost.deploy('Hello, Hardhat!');
    await masterMost.deployed();
    console.log('Mastermost deployed to:', masterMost.address);
  }
);
