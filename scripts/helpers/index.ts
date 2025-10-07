import { ethers } from 'hardhat';
import { Libraries } from 'hardhat/types';

export async function deploy<Type>(typeName: string, libraries?: Libraries, ...args: any[]): Promise<Type> {
  const ctrFactory = await ethers.getContractFactory(typeName, { libraries });
  const ctr = await ctrFactory.deploy(...args);
  const deployed = await ctr.deployed();
  return deployed as Type;
}

export async function getContractAt<Type>(typeName: string, address: string): Promise<Type> {
  const ctr = (await ethers.getContractAt(typeName, address)) as unknown as Type;
  return ctr;
}
