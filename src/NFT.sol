// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFT is ERC721A("NFT EXAMPLE", "NFT"), ERC721AQueryable, Ownable {
    using Address for address;

    // =============================================================
    //                           EVENTS
    // =============================================================

    event BaseUriUpdated(string _uri);

    // =============================================================
    //                           ERRORS
    // =============================================================

    error MintLimitReached();
    error MaxSupplyReached();
    error InsufficientPayment();

    // =============================================================
    //                           STATE
    // =============================================================

    uint256 public constant MAX_MINTABLE = 100;
    uint256 public constant MAX_SUPPLY = type(uint256).max;
    uint256 public constant MINT_PRICE = 0.0001 ether;

    // Mapping from account to amount of tokens minted
    mapping(address => uint256) private _mintedCount;

    string private _baseUri;

    //     =============================================================
    //                           CONSTRUCTOR
    //     =============================================================

    constructor(address owner_) Ownable(owner_) {}

    // =============================================================
    //                            FUNCTIONS
    // =============================================================

    /// @notice Allows users to buy during public sale
    /// @param numberOfTokens the number of NFTs to buy
    function buyPublic(uint256 numberOfTokens) external payable {
        uint256 newMintedCount = _mintedCount[_msgSenderERC721A()] + numberOfTokens;

        if (_totalMinted() + numberOfTokens > MAX_SUPPLY) revert MaxSupplyReached();
        if (newMintedCount > MAX_MINTABLE) revert MintLimitReached();
        if (msg.value < numberOfTokens * MINT_PRICE) revert InsufficientPayment();

        _mintedCount[msg.sender] = newMintedCount;

        _safeMint(msg.sender, numberOfTokens);
    }

    /// @notice Returns the number of tokens minted by an account
    /// @param account The account to query for
    function mintedCount(address account) external view returns (uint256) {
        return _mintedCount[account];
    }

    /// @notice Get token's URI. In case of delayed reveal we give user the json of the placeholer metadata.
    /// @param tokenId token ID
    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(tokenId));
        return _baseUri;
    }

    // =============================================================
    //                           RESTRICTED FUNCTIONS
    // =============================================================

    /// @notice Set the base URI
    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseUri = baseURI;
        emit BaseUriUpdated(_baseUri);
    }

    function withdraw() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    // =============================================================
    //                  PRIVATE/INTERNAL FUNCTIONS
    // =============================================================
    /// @dev override base uri. It will be combined with token ID
    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }
}
