import '@typechain/hardhat';
import type { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox-viem';
import dotenv from 'dotenv';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: '0.8.28',
  networks: {
    monadTestnet: {
      url: 'https://10143.rpc.thirdweb.com/f4f634aad888c9e6d43dd22ed5d02158',
      chainId: 10143,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 'auto',
      gas: 'auto',
      gasMultiplier: 1,
    },
  },
  typechain: {
    target: 'ethers-v5',
    outDir: './artifacts/types',
  },
};

export default config;
