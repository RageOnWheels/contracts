// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./mixins/signature-control.sol";
import "./mixins/ERC4907.sol";
import "./mixins/nonce-control.sol";
import "./interfaces/Itreasury.sol";

contract RageOnWheelsMint is ERC4907, SignatureControl, NonceControl {

    ITreasury treasury;

    event Mint (
        address minter,
        uint256 indexed tokenId,
        string metadata
    );

    constructor(string memory name_, string memory symbol_, address treasury_)
        ERC4907(name_, symbol_)
    {
        treasury = ITreasury(treasury_);
    }

    function mint (
        string memory ipfsMetadata, 
        uint256 tokenId, 
        bytes memory signature, 
        uint256 nonce,
        uint256 timestamp
        ) 
        public 
        {
        require(isValidMint(
            ipfsMetadata,
            tokenId,
            signature,
            nonce,
            timestamp
            )
        );
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, ipfsMetadata);
        emit Mint(msg.sender, tokenId, ipfsMetadata);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _burn(tokenId);
    }

    function isValidMint(
        string memory ipfsMetadata, 
        uint256 tokenId, 
        bytes memory signature, 
        uint256 nonce,
        uint256 timestamp
    ) internal onlyValidNonce(nonce) returns(bool) {
        bytes memory data = abi.encodePacked(
             _toAsciiString(msg.sender), 
            " is authorized to mint token ", 
            Strings.toString(tokenId), 
            " with metadata ", 
            ipfsMetadata,
            " before ",
            Strings.toString(timestamp),
            ", ",
            Strings.toString(nonce)
        );
        bytes32 hash = _toEthSignedMessage(data);
        address signer = ECDSA.recover(hash, signature);
        require(treasury.isOperator(signer),"Mint not verified by operator");
        require(block.timestamp <= timestamp, "Outdated signed message");
        return true;
    }

}

