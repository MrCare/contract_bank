// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {MyToken} from "./token.sol";

// ============ 事件接口 ============
interface INFTMarketEvents {
    event Listed(uint256 indexed listId, uint256 indexed tokenId, uint256 price, address indexed seller);
    event Sold(uint256 indexed listId, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event Delisted(uint256 indexed listId, uint256 indexed tokenId);
}

// ============ 错误接口 ============
interface INFTMarketErrors {
    error NotNFTOwner();
    error InvalidPrice();
    error NFTAlreadyListed();
    error NFTNotListed();
    error InvalidListId();
    error TransferFailed();
    error InsufficientPayment();
    error UnauthorizedTokenReceiver();
    error NFTOwnerChanged();
    error InvalidData();
}

contract NFTMarket is Ownable, INFTMarketEvents, INFTMarketErrors {
    // ============ 状态变量 ============
    IERC721 public immutable nftContract;
    MyToken public immutable tokenContract;

    struct Listing {
        uint256 tokenId;
        uint256 price;
        address seller;
        bool active;
    }

    uint256 public nextListId;
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => uint256) public tokenToListId; // tokenId => listId

    constructor(address _nftContract, address _tokenContract) Ownable(msg.sender) {
        nftContract = IERC721(_nftContract);
        tokenContract = MyToken(_tokenContract);
    }

    // ============ 上架NFT ============
    function list(uint256 tokenId, uint256 price) external onlyOwner {
        if (nftContract.ownerOf(tokenId) != msg.sender) revert NotNFTOwner();
        if (price == 0) revert InvalidPrice();
        
        // 检查是否已上架
        uint256 existingListId = tokenToListId[tokenId];
        if (existingListId != 0 && listings[existingListId].active) {
            // 更新价格
            listings[existingListId].price = price;
            emit Listed(existingListId, tokenId, price, msg.sender);
        } else {
            // 新上架
            uint256 listId = ++nextListId;
            listings[listId] = Listing(tokenId, price, msg.sender, true);
            tokenToListId[tokenId] = listId;
            emit Listed(listId, tokenId, price, msg.sender);
        }
    }

    // ============ 下架NFT ============
    function delist(uint256 listId) external onlyOwner {
        Listing storage listing = listings[listId];
        if (!listing.active) revert NFTNotListed();
        
        listing.active = false;
        delete tokenToListId[listing.tokenId];
        
        emit Delisted(listId, listing.tokenId);
    }

    // ============ 购买NFT ============
    function buyNFT(uint256 listId) external {
        Listing storage listing = listings[listId];
        if (!listing.active) revert NFTNotListed();
        if (nftContract.ownerOf(listing.tokenId) != listing.seller) revert NFTOwnerChanged();

        // 执行转账
        nftContract.transferFrom(listing.seller, msg.sender, listing.tokenId);
        if (!tokenContract.transferFrom(msg.sender, listing.seller, listing.price)) {
            revert TransferFailed();
        }

        // 更新状态
        listing.active = false;
        delete tokenToListId[listing.tokenId];

        emit Sold(listId, listing.tokenId, msg.sender, listing.price);
    }

    // ============ 回调购买NFT ============
    function tokensReceived(address from, uint256 amount, bytes calldata data) external returns (bool) {
        if (msg.sender != address(tokenContract)) revert UnauthorizedTokenReceiver();
        if (data.length == 0) revert InvalidData();

        uint256 listId = abi.decode(data, (uint256));
        Listing storage listing = listings[listId];
        
        if (!listing.active) revert NFTNotListed();
        if (amount < listing.price) revert InsufficientPayment();
        if (nftContract.ownerOf(listing.tokenId) != listing.seller) revert NFTOwnerChanged();

        // 执行转账
        nftContract.transferFrom(listing.seller, from, listing.tokenId);
        tokenContract.transfer(listing.seller, listing.price);

        // 更新状态
        listing.active = false;
        delete tokenToListId[listing.tokenId];

        emit Sold(listId, listing.tokenId, from, listing.price);
        return true;
    }

    // ============ 查询函数 ============
    function getListing(uint256 listId) external view returns (Listing memory) {
        return listings[listId];
    }

    function getListingByToken(uint256 tokenId) external view returns (Listing memory) {
        uint256 listId = tokenToListId[tokenId];
        if (listId == 0) revert NFTNotListed();
        return listings[listId];
    }

    function isListed(uint256 tokenId) external view returns (bool) {
        uint256 listId = tokenToListId[tokenId];
        return listId != 0 && listings[listId].active;
    }
}
