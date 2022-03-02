// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { HashUtils } from './HashUtils.sol';
import { SaleOrder } from '../common/Structs.sol';  

contract SignatureUtils is HashUtils {
    function verifySaleOrder(SaleOrder memory saleOrder, bytes memory signature) public pure returns (bool) {
        bytes32 hash = hashSaleOrder(saleOrder);
        bytes32 ethSignedHash = getEthSignedHash(hash);
        return saleOrder.owner == address(0) ? recover(ethSignedHash, signature) == saleOrder.creator : recover(ethSignedHash, signature) == saleOrder.owner;
    }
    
    function recover(bytes32 ethSignedHash, bytes memory signature) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        
        return ecrecover(ethSignedHash, v, r, s);
    }
    
    function recoverSigner(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        // (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        // return ecrecover(_ethSignedMessageHash, v, r, s);
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }
}