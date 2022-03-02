// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PEM721 is Ownable, ERC721URIStorage {

    address public controller;

    constructor (
        string memory _name,
        string memory _symbol,
        address _controller
    ) ERC721(_name, _symbol) {
        setController(_controller);
    }

    modifier onlyControllers() {
        require(controller == msg.sender || owner() == msg.sender, "ERC721: Only controllers");
        _;
    }

    function setController(address _controller) public onlyControllers{
        controller = _controller;
    }

    function mint (
        address _receiver,
        uint256 _tokenId,
        string memory _uri,
        bytes memory _data
    ) public onlyControllers returns(uint256){
        _safeMint(_receiver, _tokenId, _data);
        _setTokenURI(_tokenId, _uri);
        return _tokenId;
    }

    function burn (uint256 _tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721Burnable: caller is not owner or approved");
        _burn(_tokenId);
    }
}