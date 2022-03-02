// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct NFTItem {
	uint256 Id;
	uint Interface;
	uint Rarity;
	uint CreatedAt;
	string Name;
	string Description;
	uint256[] Trait;
}


struct SaleOrder {
    uint256 id;  // NFT id if not minted yet, token Id if minted
    uint256 tokenType;  // token type
    uint256 totalCopied;   // quantity of token has been created
    uint256 onSaleQuantity;    // the number of token has been put on sale
    uint256 unitPrice;  // the price of token
    uint256 createdAt;
    uint8 status;
    address owner;  // the owner of the token, if not minted yet -> 0x00000000000000000000000000000

}