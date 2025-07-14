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
- 合约地址与scanUrl: [0x2feb07aa72860baf1951908cd20911a61b99309c#readContract](https://sepolia.etherscan.io/address/0x2feb07aa72860baf1951908cd20911a61b99309c#readContract)

## [1.1.0] - 2024-07-11

### 新增功能
- 编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank 
- 要求存款金额 >0.001 ether（用modifier权限控制）
- BigBank 合约支持转移管理员
- 编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。
- BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。

### 新增功能
- 编写一个 token 合约 CTX
- 编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出
- TokenBank 有两个方法：
  - deposit() : 需要记录每个地址的存入数量；
  - withdraw() : 用户可以提取自己的之前存入的 token。

*通过存款与取款测试：* `forge test --match-path ./test/tokenBank.t.sol -vvv`
```Bash
➜  contract_bank git:(main) ✗ forge test --match-path ./test/tokenBank.t.sol -vvv
[⠊] Compiling...
[⠆] Compiling 1 files with Solc 0.8.20
[⠰] Solc 0.8.20 finished in 1.25s
Compiler run successful!

Ran 5 tests for test/tokenBank.t.sol:TokenBankTest
[PASS] test_tokenBalances() (gas: 36505)
Logs:
  测试 Token 余额分配

[PASS] test_tokenBankDeposit() (gas: 92796)
Logs:
  测试 TokenBank 存款功能

[PASS] test_tokenBankOwner() (gas: 23058)
Logs:
  测试 TokenBank 所有者

[PASS] test_tokenBankWithdraw() (gas: 100192)
Logs:
  测试 TokenBank 取款功能

[PASS] test_tokenBasicInfo() (gas: 28233)
Logs:
  测试 Token 基础信息

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 2.05ms (1.44ms CPU time)

Ran 1 test suite in 606.83ms (2.05ms CPU time): 5 tests passed, 0 failed, 0 skipped (5 total tests)
```