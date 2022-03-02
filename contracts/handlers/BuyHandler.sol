// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Upgradable } from "../common/Upgradable.sol";
import { SaleOrder } from "../common/Structs.sol";
import { SignatureUtils } from "../utils/SignatureUtils.sol";
import { PEM1155 } from "../PEM1155.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract BuyHandler is Upgradable {
    // data: tokenID (0), tokenType(1), totalCopied(2), onSaleQuantity(3), unit price(4), quantity(5), saleOrderSalt(6), royaltyFee(7)
    // addr: creator(0), seller(1), buyer(2), tokenAddress(3)
    // str: uri(0), internalTxID(1)
    // signatures: SaleOrderSignature(0)
    function buyNFT(
        uint256[] memory _data,
        address[] memory _addr,
        string[] memory _str,
        bytes[] memory _signatures
    ) public payable virtual reentrancyGuard {
        {
            // Check if already canceled this SaleOrder 
            // If the sale order has been canceled before, reject
            require (
                !invalidSaleOrder[_signatures[0]], 
                "BuyHandler: Sale Order is canceled"
            );

            require (
                !blackList[_addr[2]],
                "BuyHandler: Buyer is black listed"
            );

            require (
                msg.sender == _addr[2],
                "BuyHandler: Caller is not buyer"
            );

            require (
                _data[3] > 0,
                "BuyHandler: Sale order supply must be greater than 0"
            );
        
            require (
                _data[4] > 0, 
                "BuyHandler: Price must be greater than 0"
            );
            
            require (
                _data[5] > 0, 
                "BuyHandler: Amount want to buy must be greater than 0"
            );
            
            require (
                _data[2] >= _data[3],
                "BuyHandler: Sale order supply must be less or equal to totalCopied"
            );
            
        }

        {   
            uint256 quantity;
            
            if (_data[1] == 0) {
                /* dort */ 
                quantity = 1;
                
                require (
                    _data[3] == 1,
                    "BuyHandler: Dort's sale order supply cannot exceed 1"
                );

                require (
                    _data[5] == 1,
                    "BuyHandler: Dort's amount cannot exceed 1"
                );

                require (
                    soldQuantityBySaleOrder[_signatures[0]] == 0,
                    "BuyHandler: The dort has been sold before"
                );

                
            } else {
                /* item */
                quantity = PEM1155(pem1155Address).balanceOf(_addr[1], _data[0]);

                // amount want to buy must be less than or equal the current copies the seller own
                require (
                    quantity >= _data[5],
                    "BuyHandler: The seller does not have enough copy of this item"
                );

                require (
                    _data[5] <= _data[3],
                    "BuyHandler: Not enough item to buy"
                );
            }
            
            SaleOrder memory saleOrder = SaleOrder(
                _data[0], // tokenId
                _data[1], // token type
                _data[2], // totalCopied
                _data[3], // onSaleQuantity
                _data[4], // unit price
                _data[6], // saleOrderSalt
                _addr[0], // creator
                _addr[1]   // owner
            );

            require(
                SignatureUtils(signatureUtilsAddress).verifySaleOrder(
                    saleOrder, 
                    _signatures[0]
                ),
                "BuyHandler: Sale Order signature is invalid"
            );
        }
        {

            uint256 transferAmount = _data[5] * _data[4];
            uint256 royalty = (_data[7] * _data[4])/100000;
            
            if(msg.value == 0) {
                require(
                    IERC20(_addr[3]).balanceOf(_addr[2]) >= transferAmount,
                    "BuyHandler: Not enough ERC-20 token"
                );
                
                
                require(
                    IERC20(_addr[3]).transferFrom(_addr[2], recipientAddress, royalty), 
                    "BuyHandler: Cannot transfer royalty"
                );
                
                // the remained transferred amount
                transferAmount = transferAmount - royalty;
                
                require(
                    IERC20(_addr[3]).transferFrom(_addr[2], _addr[1], transferAmount), 
                    "BuyHandler: Cannot transfer the remained amount"
                );
            } else {
                require (
                    msg.value == transferAmount,
                    "BuyHandler: Transfer amount must equal to the total price"
                );
    
                payable(recipientAddress).transfer(royalty);
                
                payable(_addr[1]).transfer(transferAmount - royalty);
            }

            

            // transfer(seller, buyer, tokenId, tokenType, quantity, data)
            transfer(_addr[1], _addr[2], _data[0], _data[1], _data[5], "");
            
            
            soldQuantityBySaleOrder[_signatures[0]] += _data[5];
            
        }
        {
            uint256 tokenId = _data[0];
            uint256 totalCopies = _data[2];
            uint256 onSaleQuantity = _data[3];
            uint256 quantity = _data[5];
            string memory internalTxID = _str[1];
            
            
            emit BuyNFTEvent(
                tokenId,   // token id
                totalCopies,   // totalCopied
                onSaleQuantity,   // onSaleQuantity
                quantity,   // quantity
                _addr[1],   // seller
                _addr[2],   // buyer
                internalTxID     // internalTxID
            );
        }
        
        
    }
}