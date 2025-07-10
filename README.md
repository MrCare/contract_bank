<!--
 * @Author: Mr.Car
 * @Date: 2025-07-10 08:52:43
-->

# Changelog

## [0.1.0] - 2024-07-08

### 新增功能
- 支持通过钱包直接存款到 Bank 合约
- 记录每个地址的存款金额
- 管理员可通过 `withdraw()` 方法提取资金
- 跟踪存款金额前 3 名用户

### 部署
部署脚本
```
forge script script/bank.s.sol:DeployBank \
  --rpc-url $SEPOLIA_RPC \
  --private-key $NFT_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

日志输出

```                      
(base) ➜  contract_bank git:(main) ✗ forge script script/bank.s.sol:DeployBank \
  --rpc-url $SEPOLIA_RPC \
  --private-key $NFT_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
[⠊] Compiling...
No files changed, compilation skipped
Warning: Detected artifacts built from source files that no longer exist. Run `forge clean` to make sure builds are in sync with project files.
 - /Users/car/Work/2025beginAgain/contract_bank/test/Counter.t.sol
 - /Users/car/Work/2025beginAgain/contract_bank/src/Counter.sol
 - /Users/car/Work/2025beginAgain/contract_bank/script/Counter.s.sol
Traces:
  [581498] DeployBank::run()
    ├─ [0] VM::envUint("NFT_PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE991bC71A371055B3f02aa79b79E4b714A3D04c0
    ├─ [0] console::log("Deployer Balance", 334519602789691411 [3.345e17]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [540315] → new Bank@0x19317565B2161d3F9f67E54f24e5F90fe4dfA738
    │   └─ ← [Return] 2588 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Deployer Balance 334519602789691411

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [540315] → new Bank@0x19317565B2161d3F9f67E54f24e5F90fe4dfA738
    └─ ← [Return] 2588 bytes of code


==========================

Chain 11155111

Estimated gas price: 0.002942676 gwei

Estimated total gas used for script: 822929

Estimated amount required: 0.000002421613418004 ETH

==========================

##### sepolia
✅  [Success] Hash: 0x2a306ddbe9f789b43c4d666d9c5d409a980292f8608266381264796f8be95a97
Contract Address: 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738
Block: 8733996
Paid: 0.000001193861368388 ETH (633191 gas * 0.001885468 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.000001193861368388 ETH (633191 gas * avg 0.001885468 gwei)
                                                                                   

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x19317565B2161d3F9f67E54f24e5F90fe4dfA738` deployed on sepolia
EVM version: paris
Compiler version: 0.8.18

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (2 tries remaining)

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (1 tries remaining)

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (0 tries remaining)

Submitting verification for [src/bank.sol:Bank] 0x19317565B2161d3F9f67E54f24e5F90fe4dfA738.
Submitted contract for verification:
        Response: `OK`
        GUID: `9iu27r7f3fza5vbps1cnvzvx9k3ejqi6k9szed9fnijpprvbey`
        URL: https://sepolia.etherscan.io/address/0x19317565b2161d3f9f67e54f24e5f90fe4dfa738
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/car/Work/2025beginAgain/contract_bank/broadcast/bank.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/car/Work/2025beginAgain/contract_bank/cache/bank.s.sol/11155111/run-latest.json
```


- 测试网部署成功:
- 合约地址与scanUrl: [0x19317565B2161d3F9f67E54f24e5F90fe4dfA738](https://sepolia.etherscan.io/address/0x19317565b2161d3f9f67e54f24e5f90fe4dfa738)