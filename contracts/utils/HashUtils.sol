// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Utils } from './Utils.sol';
import { AssemblyUtils } from './AssemblyUtils.sol'; 
import { SaleOrder } from '../common/Structs.sol'; 

contract HashUtils {
    
    function hashSaleOrder(SaleOrder memory saleOrder) public pure returns (bytes32 hash) {
        uint256 size = Utils.sizeOfSaleOrder();
        bytes memory array = new bytes(size);
        uint256 index;
        assembly {
            index := add(array, 0x20)
        }
        
        index = AssemblyUtils.writeUint256(index, saleOrder.id);
        index = AssemblyUtils.writeUint256(index, saleOrder.tokenType);
        index = AssemblyUtils.writeUint256(index, saleOrder.totalCopied);
        index = AssemblyUtils.writeUint256(index, saleOrder.onSaleQuantity);
        index = AssemblyUtils.writeUint256(index, saleOrder.unitPrice);
        index = AssemblyUtils.writeUint256(index, saleOrder.saleOrderSalt);
        index = AssemblyUtils.writeAddress(index, saleOrder.creator);
        index = AssemblyUtils.writeAddress(index, saleOrder.owner);
        
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }
    
    function getHashSaleOrder(uint256[] memory _data, address[] memory _addr) public pure returns (bytes32 hash) {
        uint256 size = Utils.sizeOfSaleOrder();
        bytes memory array = new bytes(size);
        uint256 index;
        assembly {
            index := add(array, 0x20)
        }
        
        index = AssemblyUtils.writeUint256(index, _data[0]);
        index = AssemblyUtils.writeUint256(index, _data[1]);
        index = AssemblyUtils.writeUint256(index, _data[2]);
        index = AssemblyUtils.writeUint256(index, _data[3]);
        index = AssemblyUtils.writeUint256(index, _data[4]);
        index = AssemblyUtils.writeUint256(index, _data[5]);
        index = AssemblyUtils.writeAddress(index, _addr[0]);
        index = AssemblyUtils.writeAddress(index, _addr[1]);
        
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }
    
    function getEthSignedHash(bytes32 hash) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    hash
                )
            );
    }
}