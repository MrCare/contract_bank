'use client';

import { useTokenBank } from '../hooks/useTokenBank';
import { BalanceCard } from './BalanceCard';
import { ActionSection } from './ActionSection';
import { Card, CardContent, CardHeader, CardTitle } from './ui/index';
import { Badge } from './ui/index';

export default function TokenBank() {
  const {
    isConnected,
    isLoading,
    depositAmount,
    withdrawAmount,
    tokenSymbol,
    tokenBalance,
    bankBalance,
    allowance,
    setDepositAmount,
    setWithdrawAmount,
    handleDeposit,
    handleWithdraw,
    formatBalance,
    chain,
    tokenAddress,
    tokenBankAddress,
  } = useTokenBank();

  if (!isConnected) {
    return (
      <Card className="max-w-md mx-auto">
        <CardContent className="pt-6 text-center">
          <CardTitle className="mb-4">请先连接钱包</CardTitle>
          <p className="text-muted-foreground">您需要连接钱包才能使用TokenBank功能</p>
        </CardContent>
      </Card>
    );
  }

  if (!tokenAddress || !tokenBankAddress) {
    return (
      <Card className="max-w-md mx-auto">
        <CardContent className="pt-6 text-center">
          <CardTitle className="mb-4 text-destructive">合约地址未配置</CardTitle>
          <p className="text-muted-foreground mb-2">请在 contracts.ts 中配置正确的合约地址</p>
          <Badge variant="outline">当前网络: {chain}</Badge>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="max-w-md mx-auto">
      <CardHeader>
        <CardTitle className="text-center">TokenBank</CardTitle>
        <div className="flex justify-center">
          <Badge variant="secondary">网络: {chain}</Badge>
        </div>
      </CardHeader>
      
      <CardContent className="space-y-6">
        {/* 余额显示 */}
        <div className="grid grid-cols-2 gap-4">
          <BalanceCard
            title="钱包余额"
            balance={formatBalance(tokenBalance)}
            symbol={tokenSymbol}
            className="bg-blue-50 border-blue-200"
          />
          <BalanceCard
            title="银行存款"
            balance={formatBalance(bankBalance)}
            symbol={tokenSymbol}
            className="bg-green-50 border-green-200"
          />
        </div>

        {/* 存款功能 */}
        <ActionSection
          title="存款到TokenBank"
          placeholder="输入存款金额"
          value={depositAmount}
          onChange={setDepositAmount}
          onAction={handleDeposit}
          buttonText={isLoading ? "处理中..." : "存款"}
          variant="default"
          disabled={isLoading}
        />

        {/* 取款功能 */}
        <ActionSection
          title="从TokenBank取款"
          placeholder="输入取款金额"
          value={withdrawAmount}
          onChange={setWithdrawAmount}
          onAction={handleWithdraw}
          buttonText={isLoading ? "处理中..." : "取款"}
          variant="secondary"
          disabled={isLoading}
        />

        {/* 授权信息 */}
        {allowance && (
          <div className="text-center">
            <Badge variant="outline">
              授权额度: {formatBalance(allowance)} {tokenSymbol}
            </Badge>
          </div>
        )}

        {/* 合约地址 */}
        <details className="text-xs text-muted-foreground">
          <summary className="cursor-pointer hover:text-foreground">合约信息</summary>
          <div className="mt-2 space-y-1 font-mono">
            <p>Token: {tokenAddress}</p>
            <p>TokenBank: {tokenBankAddress}</p>
          </div>
        </details>
      </CardContent>
    </Card>
  );
}
