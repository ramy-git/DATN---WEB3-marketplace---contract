// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PEM20 is ERC20, Ownable {
    
    address public contractAddress;
    
    constructor(string memory _name, string memory _symbol, address _addr) ERC20(_name, _symbol) {
        contractAddress = _addr;
    }
    
    
    function mint(address _to, uint256 _amount) public {
        // require(msg.value == _amount, "Value must equal amount to mint");
        
        // payable(owner()).transfer(_amount);
        
        increaseAllowance(contractAddress, _amount);
        
        _mint(_to, _amount);
    }
}