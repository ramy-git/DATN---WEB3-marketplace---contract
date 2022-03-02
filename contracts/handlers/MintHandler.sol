// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Upgradable } from '../common/Upgradable.sol';
import { SaleOrder } from '../common/Structs.sol';
import { SignatureUtils } from '../utils/SignatureUtils.sol';
import { PEM1155 } from "../PEM1155.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract MintHandler is Upgradable {
    // data: (0) NFT id, (1) token type, (2) totalCopied, (3) onSaleQuantity, (4) unit price, (5) quantity, (6) saleOrderSalt
    // percentage: ...
    // addr: (0) creator, (1) buyer, (2) tokenAddress
    // recipientAddresses: ...
    // str: (0) uri, (1) internalTxID, (2) payout group addresses
    // signatures: (0) saleOrderSignature
    function mintNFT (
        uint256[] memory _data,
        uint256[] memory _percentage,
        address[] memory _addr,
        address[] memory _recipientAddresses,
        string[] memory _str,
        bytes[] memory _signatures 
    ) public payable virtual reentrancyGuard {
        {   /* Common Check */  

            // Check if already canceled this SaleOrder 
            // If the sale order has been canceled before, reject
            require(!invalidSaleOrder[_signatures[0]], "MintHandler: Sale order has been canceled");

            require (
                !blackList[_addr[1]],
                "MintHandler: Buyer is black listed"
            );

            require (
                msg.sender == _addr[1],
                "MintHandler: Caller is not buyer"
            );
            
            require(_data[2] > 0, "MintHandler: Total copies must be greater than 0");
            require(_data[3] > 0, "MintHandler: Sale order supply must be greater than 0");
            require(_data[4] > 0, "MintHandler: Unit price must be greater than 0");
            require(_data[5] > 0, "MintHandler: Amount want to buy must be greater than 0");
            
            require(_percentage.length > 0, "MintHandler: Must have at least 1 percentage to receive");
            require(_recipientAddresses.length > 0, "MintHandler: Must have at least 1 recipient address");
            require(_percentage.length == _recipientAddresses.length, "MintHandler: The number of recipients does not match with the number of percentages");
        }

        {   /* Create sale order - Verify - Check for each type */

            if (_data[1] == 0) {
                /* dort */
                require(_data[2] == 1, "MintHandler: Dort's total copies cannot exceed 1");
                require(_data[3] == 1, "MintHandler: Dort's sale order supply cannot exceed 1");
                require(_data[5] == 1, "MintHandler: Dort's amount want to buy cannot exceed 1");
                require(soldQuantity[_data[0]] == 0, "MintHandler: The dort has been sold before");
            } else {
                /* item */
                require(_data[2] - PEM1155(pem1155Address).soldQuantity(_data[0]) + soldQuantityBySaleOrder[_signatures[0]] >= _data[3], // totalCopied - soldQuanityByNFTID + soldQuantityBySaleOrder >= onSaleQuantity
                    "MintHandler: Not enough copy of this item"
                );

                require(
                        _data[3] - soldQuantityBySaleOrder[_signatures[0]] >= _data[5],
                    "MintHandler: Not enough item to buy"
                );
            }

            // After verifying successfully, create sale order and verify signature

            SaleOrder memory saleOrder = SaleOrder (
                _data[0],   // NFT id
                _data[1],   // token type
                _data[2],   // totalCopied
                _data[3],    // onSaleQuantity
                _data[4],   // unit price
                _data[6],   // saleOrderSalt
                _addr[0],   // creator
                address(0)   // owner
            );

            require(
                SignatureUtils(signatureUtilsAddress).verifySaleOrder(saleOrder, _signatures[0]), 
                "MintHandler: Verify sale order failed"
            );

            uint256 transferAmount = _data[4] * _data[5];
            
            require(
                _recipientAddresses[0] == superAdmin,
                "MintHandler: Can not found super admin in payout group"
            );
            
            if(msg.value == 0) {
                
                for(uint8 i = 0; i < _percentage.length; i++) {
                    require(
                        IERC20(_addr[2]).transferFrom(_addr[1], _recipientAddresses[i], transferAmount * _percentage[i] / 100000),
                        "MintHandler: Cannot transfer token to creator"
                    );
                }
                
            } else {
                // Check if the value transfered from the buyer is equal to the total price
                require(
                    msg.value == transferAmount, 
                    "MintHandler: Sent value is not equal to the total price wanted to be transferred"
                );
                
                
                for(uint256 i = 0; i<_percentage.length; i++) {
                    payable(_recipientAddresses[i]).transfer(transferAmount * _percentage[i] / 1e5);
                }
            }
            
            
            
            // mint(_receiver, _tokenID,  _tokenType, _amount, _uri, _data);
            uint256 tokenId = mint(_addr[1], _data[0], _data[1], _data[5], _str[0], "");

            // Update the sold quantity
            soldQuantity[_data[0]] += _data[5];
            soldQuantityBySaleOrder[_signatures[0]] += _data[5];

            emit MintNFTEvent(
                tokenId,    // tokenId
                _data[5],   // quantity
                _addr[1],   // buyer
                _str[1]     // internalTxID
            );
        }
        
        
        
    }
}