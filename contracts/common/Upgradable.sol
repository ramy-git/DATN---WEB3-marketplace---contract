// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ReentrancyGuarded } from "./ReentrancyGuarded.sol";
import { PEM1155 } from "../PEM1155.sol";
import { PEM721 } from "../PEM721.sol";

contract Upgradable is ReentrancyGuarded {
    
    address public recipientAddress;
    address public signatureUtilsAddress;
    
    address public pem1155Address;
    address public pem721Address;
    
    address public buyHandlerAddress;
    address public mintHandlerAddress;

    address public cancelHandlerAddress;
    
    address public superAdmin;
      
    mapping (address => bool) adminList;                //address -> if admin or not 
    mapping (address => bool) blackList;                //address -> if black listed
    mapping (bytes => bool) invalidSaleOrder;           //signature -> sale_availibity
    mapping (uint256 => uint256) soldQuantity;          // NFT ID -> soldQuantity
    mapping (bytes => uint256) soldQuantityBySaleOrder; // signature -> soldQuantity
    

    event MintNFTEvent(
        uint256 _tokenId,
        uint256 _quantity,
        address indexed _buyer,
        string _internalTxID
    );
    
    event BuyNFTEvent(
        uint256 _tokenId,
        uint256 _totalCopied,
        uint256 _onSaleQuantity,
        uint256 _quantity,
        address indexed _seller,
        address indexed _buyer,
        string _internalTxID
    );
    
    event CancelSaleOrderEvent(
        uint256 _onSaleQuantity,    
        uint256 _unitPrice,
        uint256 _saleOrderSalt,
        address indexed _caller,
        string _internalTxID
    );

    event SetAdminEvent(
        address indexed _addr, 
        bool _value
    );
    
    // check if the address is set admin
    function isAdmin(address _addr) public view returns (bool) {
        return adminList[_addr];
    } 
    
    // To handle mint request
    function mint(
        address _receiver,
        uint256 _tokenId,
        uint256 _tokenType,
        uint256 _amount,
        string memory _uri,
        bytes memory _data
    ) internal returns(uint256) {
        uint256 tokenId;
        if (_tokenType == 0) {  // ERC721
            tokenId = PEM721(pem721Address).mint(_receiver, _tokenId, _uri, _data);
        } else {    // ERC1155
            tokenId = PEM1155(pem1155Address).mint(_receiver, _tokenId, _amount, _uri, _data);
        }
        return tokenId;
    }

    // To handle buy request
    function transfer(
        address _seller,
        address _buyer,
        uint256 _tokenId,
        uint256 _tokenType,
        uint256 _amount,
        bytes memory _data
    ) internal {
        if (_tokenType == 0) {  // ERC 721
            PEM721(pem721Address).safeTransferFrom(_seller, _buyer, _tokenId, _data);
        } else {
            PEM1155(pem1155Address).safeTransferFrom(_seller, _buyer, _tokenId, _amount, _data);
        }
    }
    
    
}