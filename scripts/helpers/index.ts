import { Libraries } from '@nomicfoundation/hardhat-viem/internal/bytecode';
import { DeployContractConfig } from '@nomicfoundation/hardhat-viem/types';
import { viem } from 'hardhat';
import { ContractTypesMap } from 'hardhat/types/artifacts';

type ContractName = keyof ContractTypesMap;

export async function deploy(
  contractName: ContractName,
  libraries?: Libraries<`0x${string}`>,
  config?: DeployContractConfig,
  ...args: any[]
) {
  const contract = await viem.deployContract(contractName as string, [...args], {
    libraries,
    ...config,
  });
  return contract as unknown as ContractTypesMap[typeof contractName];
}
