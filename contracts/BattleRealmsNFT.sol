// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// OpenZeppelin imports
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract BattleRealmsNFT is ERC721Enumerable, ERC721URIStorage, Ownable, ERC2981 {
    using Strings for uint256;

    string private baseTokenURI;
    uint256 public nextTokenId = 1;
    uint256 public maxSupply;
    bool public metadataFrozen = false;

    event BaseURISet(string newBaseURI);
    event MetadataFrozen();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxSupply,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator // e.g. 500 = 5%
    ) ERC721(_name, _symbol) {
        baseTokenURI = _baseURI;
        maxSupply = _maxSupply;
        if (royaltyReceiver != address(0)) {
            _setDefaultRoyalty(royaltyReceiver, royaltyFeeNumerator);
        }
    }

    // ------------------
    // MINTING
    // ------------------

    /// @notice Owner-only mint to a single address
    function ownerMint(address to, uint256 amount) external onlyOwner {
        require(nextTokenId + amount - 1 <= maxSupply, "Sold out or exceeds max supply");
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = nextTokenId++;
            _safeMint(to, tokenId);
        }
    }

    /// @notice Convenience to mint many specific recipients (owner-only)
    function ownerMintBatch(address[] calldata recipients) external onlyOwner {
        require(nextTokenId + recipients.length - 1 <= maxSupply, "Exceeds max supply");
        for (uint256 i = 0; i < recipients.length; i++) {
            _safeMint(recipients[i], nextTokenId++);
        }
    }

    // ------------------
    // METADATA / URI
    // ------------------

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        require(!metadataFrozen, "Metadata frozen");
        baseTokenURI = _newBaseURI;
        emit BaseURISet(_newBaseURI);
    }

    function freezeMetadata() external onlyOwner {
        metadataFrozen = true;
        emit MetadataFrozen();
    }

    // override tokenURI so it uses base + tokenId if no per-token URI is set
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory perToken = ERC721URIStorage.tokenURI(tokenId);
        if (bytes(perToken).length > 0) {
            return perToken;
        }

        string memory base = _baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString(), ".json")) : "";
    }

    // Allow owner to set per-token URI if needed
    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external onlyOwner {
        require(_exists(tokenId), "Nonexistent token");
        require(!metadataFrozen, "Metadata frozen");
        _setTokenURI(tokenId, _tokenURI);
    }

    // ------------------
    // ROYALTIES (EIP-2981)
    // ------------------

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

    // ------------------
    // BURN / SUPPORT
    // ------------------

    function burn(uint256 tokenId) external {
        // allow owner of token or approved to burn
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not owner nor approved");
        _burn(tokenId);
    }

    // ------------------
    // OVERRIDES
    // ------------------

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // supportsInterface override for ERC2981 and ERC721
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // hook to keep Enumerable working
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
