'use client';

import { createConfig, http } from 'wagmi';
import { sepolia, mainnet } from 'wagmi/chains';
import { injected, walletConnect } from 'wagmi/connectors';

// 简化版配置（不需要 Project ID）
export const config = createConfig({
  chains: [sepolia, mainnet],
  connectors: [
    injected(),
    // walletConnect({ projectId: 'YOUR_PROJECT_ID' }), // 暂时注释掉
  ],
  transports: {
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
});

export const chains = [sepolia, mainnet];
