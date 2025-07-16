#!/bin/bash
###
 # @Author: Mr.Car
 # @Date: 2025-07-16 14:21:06
### 
# 这个脚本是否有必要还值得商榷？
# 部署合约并生成类型
echo "🚀 开始部署合约..."

cd packages/contracts

# 构建合约
forge build

# 部署到测试网
forge script script/deployAll.s.sol \
  --rpc-url $SEPOLIA_RPC \
  --private-key $NFT_PRIVATE_KEY \
  --broadcast \
  --verify

# 生成前端类型
cd ../..
node scripts/generate-types.js

echo "✅ 部署完成！"
