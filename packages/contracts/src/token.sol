// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenBankV2 {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external returns (bool);
}

contract MyToken is ERC20 {
    // 定义自定义错误
    error CallbackFailed();

    constructor() ERC20("CarToken", "CTK") {
        _mint(msg.sender, 100 * 10 ** decimals()); // 铸造100个CTK
    }

    function transferWithCallback(address to, uint256 amount, bytes calldata data) public returns (bool) {
        _transfer(msg.sender, to, amount);
        if (to.code.length > 0) {
            // 如果目标是合约地址
            try ITokenBankV2(to).tokensReceived(msg.sender, amount, data) returns (bool success) {
                if (!success) {
                    revert CallbackFailed();
                }
                return success;
            } catch {
                revert CallbackFailed();
            }
        }
        return true;
    }
}
