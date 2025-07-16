import { useState, useCallback } from 'react';
import { useAccount, useReadContract, useWriteContract } from 'wagmi';
import { formatEther, parseEther } from 'viem';
import { CHAIN_CONFIG, CONTRACT_ABIS, SupportedChain } from '../config/contracts';

export function useTokenBank() {
  const { address, isConnected, chain } = useAccount();
  const [depositAmount, setDepositAmount] = useState('');
  const [withdrawAmount, setWithdrawAmount] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // 获取合约地址
  const getContractAddress = useCallback((contractName: 'token' | 'tokenBank') => {
    const chainId = chain?.id;
    const chainConfig = Object.values(CHAIN_CONFIG).find(c => c.id === chainId);
    return chainConfig?.contracts[contractName];
  }, [chain?.id]);

  const tokenAddress = getContractAddress('token');
  const tokenBankAddress = getContractAddress('tokenBank');

  // 读取合约数据
  const { data: tokenBalance, refetch: refetchTokenBalance } = useReadContract({
    address: tokenAddress,
    abi: CONTRACT_ABIS.token,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: { enabled: !!address && !!tokenAddress },
  });

  const { data: bankBalance, refetch: refetchBankBalance } = useReadContract({
    address: tokenBankAddress,
    abi: CONTRACT_ABIS.tokenBank,
    functionName: 'getBalance',
    args: address ? [address] : undefined,
    query: { enabled: !!address && !!tokenBankAddress },
  });

  const { data: allowance, refetch: refetchAllowance } = useReadContract({
    address: tokenAddress,
    abi: CONTRACT_ABIS.token,
    functionName: 'allowance',
    args: address && tokenBankAddress ? [address, tokenBankAddress] : undefined,
    query: { enabled: !!address && !!tokenAddress && !!tokenBankAddress },
  });

  const { data: tokenSymbol } = useReadContract({
    address: tokenAddress,
    abi: CONTRACT_ABIS.token,
    functionName: 'symbol',
    query: { enabled: !!tokenAddress },
  });

  const { writeContract } = useWriteContract({
    mutation: {
      onSuccess: () => {
        // 延迟刷新数据
        setTimeout(() => {
          refetchTokenBalance();
          refetchBankBalance();
          refetchAllowance();
          setIsLoading(false);
        }, 2000);
      },
      onError: (error) => {
        console.error('交易失败:', error);
        setIsLoading(false);
      },
    },
  });

  // 存款逻辑
  const handleDeposit = useCallback(async () => {
    if (!depositAmount || !address || !tokenAddress || !tokenBankAddress) return;
    
    setIsLoading(true);
    const amount = parseEther(depositAmount);
    
    try {
      // 检查授权
      if ((allowance || BigInt(0)) < amount) {
        await writeContract({
          address: tokenAddress,
          abi: CONTRACT_ABIS.token,
          functionName: 'approve',
          args: [tokenBankAddress, amount],
        });
        return;
      }
      
      // 执行存款
      await writeContract({
        address: tokenBankAddress,
        abi: CONTRACT_ABIS.tokenBank,
        functionName: 'deposit',
        args: [amount],
      });
      
      setDepositAmount('');
    } catch (error) {
      console.error('存款失败:', error);
      setIsLoading(false);
    }
  }, [depositAmount, address, tokenAddress, tokenBankAddress, allowance, writeContract]);

  // 取款逻辑
  const handleWithdraw = useCallback(async () => {
    if (!withdrawAmount || !address || !tokenBankAddress) return;
    
    setIsLoading(true);
    
    try {
      await writeContract({
        address: tokenBankAddress,
        abi: CONTRACT_ABIS.tokenBank,
        functionName: 'withdraw',
        args: [parseEther(withdrawAmount)],
      });
      
      setWithdrawAmount('');
    } catch (error) {
      console.error('取款失败:', error);
      setIsLoading(false);
    }
  }, [withdrawAmount, address, tokenBankAddress, writeContract]);

  // 格式化余额
  const formatBalance = useCallback((balance: bigint | undefined) => {
    return balance ? formatEther(balance) : '0';
  }, []);

  return {
    // 状态
    isConnected,
    isLoading,
    depositAmount,
    withdrawAmount,
    tokenSymbol: tokenSymbol || 'CTK',
    
    // 数据
    tokenBalance,
    bankBalance,
    allowance,
    
    // 方法
    setDepositAmount,
    setWithdrawAmount,
    handleDeposit,
    handleWithdraw,
    formatBalance,
    
    // 配置
    chain: chain?.name,
    tokenAddress,
    tokenBankAddress,
  };
}
