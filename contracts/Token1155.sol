// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PEM1155 is Ownable, ERC1155{

    address public controller;
    string public name;
    string public symbol;

    mapping (uint256 => string) public tokenURI;        // token ID => uri metadata
    mapping (uint256 => uint256) public soldQuantity;   // token ID => sold quantity

    constructor (
        string memory _name,
        string memory _symbol,
        address _controller
    ) ERC1155("") {
        name = _name;
        symbol = _symbol;
        setController(_controller);
    }

    modifier onlyControllers() {
        require(controller == msg.sender || owner() == msg.sender, "ERC1155: Only controllers");
        _;
    }

    function setController(address _controller) public onlyOwner {
        controller = _controller;
    }

    function setURI(uint256 _tokenId, string memory _uri) public onlyControllers {
        tokenURI[_tokenId] = _uri;
    }

    function mint (
        address _receiver,
        uint256 _tokenId,
        uint256 _amount,
        string memory _uri,
        bytes memory _data
    ) public onlyControllers returns(uint256) {
        _mint(_receiver, _tokenId, _amount, _data);
        setURI(_tokenId, _uri);
        soldQuantity[_tokenId] += _amount;
        return _tokenId;
    }

    function burn (
        address _receiver,
        uint256 _tokenId,
        uint256 _value
    ) public virtual {
        require(_receiver == _msgSender() || isApprovedForAll(_receiver, _msgSender()), "ERC1155: caller is not owner or approved");
        _burn(_receiver, _tokenId, _value);
        soldQuantity[_tokenId] -= _value;
    }

    function uri (uint256 _tokenId) public view virtual override returns (string memory) {
        return tokenURI[_tokenId];
    }
}