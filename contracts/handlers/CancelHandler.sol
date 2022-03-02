// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Upgradable } from '../common/Upgradable.sol';
import { SaleOrder } from '../common/Structs.sol';
import { SignatureUtils } from '../utils/SignatureUtils.sol'; 

contract CancelHandler is Upgradable {
    // data: (0) id, (1) token type, (2) totalCopied, (3) onSaleQuantity, (4) unit price, (5) saleOrderSalt
    // addr: (0) creator, (1) owner
    // str: (0) uri, (1) internalTxID
    // signatures: (0) saleOrderSignature
    function cancelSaleOrder (
        uint256[] memory _data,
        address[] memory _addr,
        string[] memory _str,
        bytes[] memory _signatures
    ) public reentrancyGuard {
        
        if(!isAdmin(msg.sender) && msg.sender != superAdmin) {
            require(
                msg.sender == _addr[1],
                "CancelHandler: The caller is not the one listed on sale"
            );
        }
        
        // check if the sale order has been sold out
        require(
            soldQuantityBySaleOrder[_signatures[0]] < _data[3],
            "CancelHandler: Sale Order has been sold out"
        );
        
        // check if the sale order has already been canceled
        require(
            !invalidSaleOrder[_signatures[0]],
            "CancelHandler: Sale Order was canceled"
        );
        
        
        SaleOrder memory saleOrder = SaleOrder(
            _data[0],   // token id
            _data[1],   // token type
            _data[2],   // totalCopied
            _data[3],   // onSaleQuantity
            _data[4],   // unit price
            _data[5],   // saleOrderSalt
            _addr[0],   // creator
            _addr[1]   // owner
            
        );
        
        require(
            SignatureUtils(signatureUtilsAddress).verifySaleOrder(
                saleOrder,
                _signatures[0]
            ),
            "CancelHandler: Sale Order signature is invalid"
        );
        
        invalidSaleOrder[_signatures[0]] = true;
        
        emit CancelSaleOrderEvent(
            _data[3],   // onSaleQuantity
            _data[4],   // unit price
            _data[5],   // saleOrderSalt
            msg.sender,   // the one who cancel sale order
            _str[1]     // internalTxID
        );
    }
}