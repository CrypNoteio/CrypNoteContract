// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NoteNFT is ERC721Enumerable, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant MaxSupply = 1024;
    uint256 public tokenId = 0;
    string public baseURI = "";

    address public creator;
    uint256 public constant mintPrice = 0.05 ether;
    uint256 public wlStartTime;
    uint256 public publicStartTime;

    uint256 public constant WhitelistMaxNumber = 124;
    EnumerableSet.AddressSet private whitelist;
    mapping(address => bool) public whiteMintedMap;

    constructor(uint256 _wlStartTime, uint256 _publicStartTime, address _creator) ERC721("Note NFT", "NOTE") {
        wlStartTime = _wlStartTime;
        publicStartTime = _publicStartTime;
        creator = _creator;
    }

    function addWhitelist(address[] memory _whitelist) external onlyOwner {
        require(whitelist.length() + _whitelist.length <= WhitelistMaxNumber, "Exceed whitelist max number");
        for (uint i = 0; i < _whitelist.length; i++) {
            if (!whitelist.contains(_whitelist[i])) {
                whitelist.add(_whitelist[i]);
            }
        }
    }

    function mint() payable external {
        require(msg.value == mintPrice, "Mint price is 0.05 ETH");
        require(tokenId < MaxSupply, "Exceed max supply 1024");
        require(block.timestamp >= wlStartTime, "NOT start");
        if (block.timestamp < publicStartTime) {
            require(whitelist.contains(msg.sender), "NOT in whitelist");
            require(!whiteMintedMap[msg.sender], "can NOT mint more than once");
            tokenId++;
            _mint(msg.sender, tokenId);
            whiteMintedMap[msg.sender] = true;
            return;
        } 
        tokenId++;
        _mint(msg.sender, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function withdraw() external {
        require(msg.sender == creator, "Only creator can withdraw");
        payable(creator).transfer(address(this).balance);
    }
}