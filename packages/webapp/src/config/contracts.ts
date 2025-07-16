/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 16:17:40
 */
import { tokenBankConfig } from '../contracts/tokenBank';
import { ERC20Config } from '../contracts/ERC20';

export const CHAIN_CONFIG = {
  sepolia: {
    id: 11155111,
    name: 'Sepolia',
    contracts: {
      token: '0x0000000000000000000000000000000000000000', // 请替换
      tokenBank: '0x0000000000000000000000000000000000000000', // 请替换
    },
  },
  mainnet: {
    id: 1,
    name: 'Mainnet',
    contracts: {
      token: '0x0000000000000000000000000000000000000000',
      tokenBank: '0x0000000000000000000000000000000000000000',
    },
  },
} as const;

export const CONTRACT_ABIS = {
  token: ERC20Config.abi,
  tokenBank: tokenBankConfig.abi,
} as const;

export type SupportedChain = keyof typeof CHAIN_CONFIG;
export type ContractName = keyof typeof CONTRACT_ABIS;
