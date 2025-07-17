// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract CarNFT is ERC721, Ownable {
    string private _ipfsHash;

    constructor(string memory ipfsHash) ERC721("CarNFT", "CFT") Ownable(msg.sender) {
        _ipfsHash = ipfsHash;
    }

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    // 只接受 IPFS 哈希，自动添加 ipfs:// 前缀
    function setIPFSHash(string memory ipfsHash) public onlyOwner {
        _ipfsHash = ipfsHash;
    }

    // 获取当前 IPFS 哈希
    function getIPFSHash() public view returns (string memory) {
        return _ipfsHash;
    }

    // 重写 tokenURI 函数，只返回 IPFS 格式
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        require(bytes(_ipfsHash).length > 0, "IPFS hash not set");

        return string(abi.encodePacked("ipfs://", _ipfsHash, "/", Strings.toString(tokenId), ".json"));
    }

    // 移除原来的 _baseURI 函数，强制使用 IPFS
    function _baseURI() internal view override returns (string memory) {
        return string(abi.encodePacked("ipfs://", _ipfsHash, "/"));
    }
}
