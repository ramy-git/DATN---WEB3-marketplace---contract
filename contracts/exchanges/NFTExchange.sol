// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Upgradable} from "../common/Upgradable.sol";

contract NFTExchange is Upgradable {
    
    constructor() {
        superAdmin = msg.sender;
    }
    
    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "NFTExchange: Need super admin role");
        _;
    }
    
    /**
    * set the address of the super admin
     */
    function setSuperAdmin(address _addr) external {
        superAdmin = _addr;
    }

    /** set the address of the 721 token*/
    function setPEM721Address(address _pem721Address) public onlySuperAdmin {
        pem721Address = _pem721Address;
    }

    /** set the address of the 1155 token */
    function setPEM1155Address(address _pem1155Address) public onlySuperAdmin {
        pem1155Address = _pem1155Address;
    }

    /** set the address of the buy handler */
    function setBuyHandlerAddress(address _buyHandlerAddress) public onlySuperAdmin {
        buyHandlerAddress = _buyHandlerAddress;
    }

    /** set the address of the mint handler */
    function setMintHandlerAddress(address _mintHandlerAddress)
        public
        onlySuperAdmin
    {
        mintHandlerAddress = _mintHandlerAddress;
    }

    // For cancel order
    function setCancelHandlerAddress(address _cancelHandler) public onlySuperAdmin {
        cancelHandlerAddress = _cancelHandler;
    }

    // To set the signature utils address
    function setSignatureUtilsAddress(address _signatureUtilsAddress)
        public
        onlySuperAdmin
    {
        signatureUtilsAddress = _signatureUtilsAddress;
    }

    /** set the address that recieves royalty */
    function setRecipientAddress(address _recipientAddress) public onlySuperAdmin {
        recipientAddress = _recipientAddress;
    }
    
    // For set the list of admin
    function setAdmin(address _addr) public onlySuperAdmin {
        adminList[_addr] = true;
        
        emit SetAdminEvent(_addr, true);
    }

    // Remove from admin role
    function revokeAdmin(address _addr) public onlySuperAdmin {
        adminList[_addr] = false;

        emit SetAdminEvent(_addr, false);
    }

    // set to the black list
    function setToBlackList(address _addr) public onlySuperAdmin {
        blackList[_addr] = true;
    }


    // remove from black list
    function removeFromBlackList(address _addr) public onlySuperAdmin {
        blackList[_addr] = false;
    }

    // check if the address is blacklisted
    function isBlackListed(address _addr) public view returns (bool) {
        return blackList[_addr];
    }
    
    /** 
     * @dev the mint function (primary sale)
     * data: (0) NFT id, (1) token type, (2) totalCopied, (3) onSaleQuantity, (4) unit price, (5) quantity, (6) saleOrderSalt
     * percentage: ...
     * addr: (0) creator, (1) buyer, (2) tokenAddress
     * recipientAddresses: ...
     * str: (0) uri, (1) internalTxID
     * signatures: (0) saleOrderSignature
     */
    function mintNFT(
        uint256[] memory,
        uint256[] memory,
        address[] memory,
        address[] memory,
        string[] memory,
        bytes[] memory
    ) public payable {
        // emit Check(msg.sender, msg.value);
        require(
            mintHandlerAddress != address(0),
            "NFTExchange: buyHandlerAddress is zero"
        );
        address impl = mintHandlerAddress;

        delegateCall(impl);
    }

    /** 
     * @dev the buy function (secondary sale)
     * data: tokenID (0), tokenType(1), totalCopied(2), onSaleQuantity(3), unit price(4), quantity(5), saleOrderSalt(6), royaltyFee(7)
     * addr: creator(0), seller(1), buyer(2), tokenAddress(3)
     * str: uri(0), internalTxID(1)
     * signatures: SaleOrderSignature(0)
     */
    function buyNFT(
        uint256[] memory,
        address[] memory,
        string[] memory,
        bytes[] memory
    ) public payable {
        require(
            buyHandlerAddress != address(0),
            "NFTExchange: sellHandlerAddress is zero"
        );
        address impl = buyHandlerAddress;

        delegateCall(impl);
    }
    
    /** 
     * @dev the cancel order function
     * data: (0) id, (1) token type, (2) totalCopied, (3) onSaleQuantity, (4) unit price, (5) saleOrderSalt
     * addr: (0) creator, (1) owner
     * str: (0) uri, (1) internalTxID
     * signatures: (0) saleOrderSignature
     */
    function cancelSaleOrder (
        uint256[] memory,
        address[] memory,
        string[] memory,
        bytes[] memory
    ) public {
        require(
            cancelHandlerAddress != address(0),
            "NFTExchange: cancelHandlerAddress is zero"
        );
        address impl = cancelHandlerAddress;
        
        delegateCall(impl);
    }

    function delegateCall(address _impl) internal {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            
            switch result
            case 0 {
                revert (ptr, size)
            }
            default {
                return (ptr, size)
            }
        }
    }
    
    
}
