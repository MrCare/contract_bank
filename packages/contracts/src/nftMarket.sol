// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {MyToken} from "./token.sol";

contract NFTMarket is Ownable {
    ERC721 public nftContract;
    MyToken public tokenContract;

    struct NFT {
        uint256 tokenId;
        uint256 price;
        address owner;
        bool isListed; // 是否上架
    }

    uint256 public nftCount = 0;
    mapping(uint256 => NFT) public listedNfts; // owner 上架的NFT列表

    event NFTBought(address indexed buyer, uint256 indexed listId);

    constructor(address _nftContract, address _tokenContract) Ownable(msg.sender) {
        nftContract = ERC721(_nftContract);
        tokenContract = MyToken(_tokenContract);
    }
    // 上架NFT

    function list(uint256 tokenId, uint256 price) public onlyOwner {
        listedNfts[nftCount] = NFT(tokenId, price, msg.sender, true);
        nftCount++; // 维护货架上的商品ID
    }
    // 普通购买NFT

    function buyNFT(uint256 listId) public {
        nftContract.transferFrom(listedNfts[listId].owner, msg.sender, listedNfts[listId].tokenId);
        bool success = tokenContract.transferFrom(msg.sender, listedNfts[listId].owner, listedNfts[listId].price);
        require(success, "Transfer failed");
        emit NFTBought(msg.sender, listId);
    }
    // 兼容ERC20扩展 Token 转账并在转账中实现 NFT 购买

    function tokensReceived(address from, uint256 amount, bytes calldata _data) external returns (bool) {
        require(msg.sender == address(tokenContract), "Only this contract can receive tokens");
        if (_data.length > 0) {
            uint256 listId = abi.decode(_data, (uint256));
            require(listedNfts[listId].isListed, "NFT not listed");
            require(amount >= listedNfts[listId].price, "Insufficient balance");
            // 转移NFT给买家
            nftContract.transferFrom(listedNfts[listId].owner, from, listedNfts[listId].tokenId);
            // 转移代币给NFT原所有者
            tokenContract.transfer(listedNfts[listId].owner, listedNfts[listId].price);
            // 标记为已售出
            listedNfts[listId].isListed = false;
            emit NFTBought(from, listId);
            return true;
        }
        return false;
    }
}
