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
      token: '0xf5115a4d861c51183fbd90bbdfa5086c3af3d22a', // 请替换
      tokenBank: '0x7a72f9927080db4ae849f352a6f7d0ce7bf8cf42', // 请替换
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
