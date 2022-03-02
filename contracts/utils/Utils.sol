// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Utils {
    
    function sizeOfSaleOrder() internal pure returns (uint256) {
        return ((0x20 * 6) + (0x14 * 2));
    }
}