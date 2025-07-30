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

contract NFTMarketAssembly is Ownable, INFTMarketEvents, INFTMarketErrors {
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

    // ============ 内联汇编优化的辅助函数 ============
    
    /// @dev 优化的零值检查
    function _isZero(uint256 value) private pure returns (bool result) {
        assembly {
            result := iszero(value)
        }
    }
    
    /// @dev 优化的非零值检查
    function _isNotZero(uint256 value) private pure returns (bool result) {
        assembly {
            result := gt(value, 0)
        }
    }
    
    /// @dev 优化的地址比较
    function _addressEquals(address a, address b) private pure returns (bool result) {
        assembly {
            result := eq(a, b)
        }
    }
    
    /// @dev 优化的数值加1操作
    function _increment(uint256 value) private pure returns (uint256 result) {
        assembly {
            result := add(value, 1)
        }
    }

    /// @dev 优化的mapping读取
    function _getTokenToListId(uint256 tokenId) private view returns (uint256 listId) {
        assembly {
            // 计算mapping slot
            mstore(0x00, tokenId)
            mstore(0x20, tokenToListId.slot)
            listId := sload(keccak256(0x00, 0x40))
        }
    }

    /// @dev 优化的mapping写入
    function _setTokenToListId(uint256 tokenId, uint256 listId) private {
        assembly {
            // 计算mapping slot
            mstore(0x00, tokenId)
            mstore(0x20, tokenToListId.slot)
            let slot := keccak256(0x00, 0x40)
            sstore(slot, listId)
        }
    }

    /// @dev 优化的mapping删除
    function _deleteTokenToListId(uint256 tokenId) private {
        assembly {
            // 计算mapping slot
            mstore(0x00, tokenId)
            mstore(0x20, tokenToListId.slot)
            let slot := keccak256(0x00, 0x40)
            sstore(slot, 0)
        }
    }

    // ============ 上架NFT ============
    function list(uint256 tokenId, uint256 price) external onlyOwner {
        if (!_addressEquals(nftContract.ownerOf(tokenId), msg.sender)) revert NotNFTOwner();
        if (_isZero(price)) revert InvalidPrice();
        
        // 检查是否已上架 - 使用优化的mapping读取
        uint256 existingListId = _getTokenToListId(tokenId);
        
        if (_isNotZero(existingListId) && listings[existingListId].active) {
            // 更新价格
            listings[existingListId].price = price;
            emit Listed(existingListId, tokenId, price, msg.sender);
        } else {
            // 新上架 - 使用优化的递增操作
            uint256 listId;
            assembly {
                // 读取并递增nextListId
                let currentNextListId := sload(nextListId.slot)
                listId := add(currentNextListId, 1)
                sstore(nextListId.slot, listId)
            }
            
            listings[listId] = Listing(tokenId, price, msg.sender, true);
            _setTokenToListId(tokenId, listId);
            emit Listed(listId, tokenId, price, msg.sender);
        }
    }

    // ============ 下架NFT ============
    function delist(uint256 listId) external onlyOwner {
        Listing storage listing = listings[listId];
        if (!listing.active) revert NFTNotListed();
        
        listing.active = false;
        _deleteTokenToListId(listing.tokenId);
        
        emit Delisted(listId, listing.tokenId);
    }

    // ============ 购买NFT ============
    function buyNFT(uint256 listId) external {
        Listing storage listing = listings[listId];
        if (!listing.active) revert NFTNotListed();
        if (!_addressEquals(nftContract.ownerOf(listing.tokenId), listing.seller)) revert NFTOwnerChanged();

        // 执行转账
        nftContract.transferFrom(listing.seller, msg.sender, listing.tokenId);
        if (!tokenContract.transferFrom(msg.sender, listing.seller, listing.price)) {
            revert TransferFailed();
        }

        // 更新状态
        listing.active = false;
        _deleteTokenToListId(listing.tokenId);

        emit Sold(listId, listing.tokenId, msg.sender, listing.price);
    }

    // ============ 回调购买NFT ============
    function tokensReceived(address from, uint256 amount, bytes calldata data) external returns (bool) {
        if (!_addressEquals(msg.sender, address(tokenContract))) revert UnauthorizedTokenReceiver();
        if (_isZero(data.length)) revert InvalidData();

        uint256 listId;
        assembly {
            // 优化的abi.decode
            listId := calldataload(add(data.offset, 0))
        }
        
        Listing storage listing = listings[listId];
        
        if (!listing.active) revert NFTNotListed();
        
        // 优化的数值比较
        assembly {
            if lt(amount, sload(add(listing.slot, 1))) {
                mstore(0x00, 0x3fd2347e) // InsufficientPayment() selector
                revert(0x1c, 0x04)
            }
        }
        
        if (!_addressEquals(nftContract.ownerOf(listing.tokenId), listing.seller)) revert NFTOwnerChanged();

        // 执行转账
        nftContract.transferFrom(listing.seller, from, listing.tokenId);
        tokenContract.transfer(listing.seller, listing.price);

        // 更新状态
        listing.active = false;
        _deleteTokenToListId(listing.tokenId);

        emit Sold(listId, listing.tokenId, from, listing.price);
        
        assembly {
            mstore(0x00, 1)
            return(0x1f, 0x01)
        }
    }

    // ============ 查询函数 ============
    function getListing(uint256 listId) external view returns (Listing memory) {
        return listings[listId];
    }

    function getListingByToken(uint256 tokenId) external view returns (Listing memory) {
        uint256 listId = _getTokenToListId(tokenId);
        if (_isZero(listId)) revert NFTNotListed();
        return listings[listId];
    }

    function isListed(uint256 tokenId) external view returns (bool) {
        uint256 listId = _getTokenToListId(tokenId);
        return _isNotZero(listId) && listings[listId].active;
    }
}