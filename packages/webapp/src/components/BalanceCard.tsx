/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 16:21:10
 */

import { Card, CardContent, CardHeader, CardTitle } from './ui/card';

interface BalanceCardProps {
  title: string;
  balance: string;
  symbol: string;
  className?: string;
}

export function BalanceCard({ title, balance, symbol, className }: BalanceCardProps) {
  return (
    <Card className={className}>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">
          {balance} {symbol}
        </div>
      </CardContent>
    </Card>
  );
}