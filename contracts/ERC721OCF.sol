// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./erc721a/ERC721A.sol";
import "./lib/Counters.sol";
import "./interfaces/IMetadataFactory.sol";

contract ERC721OCF is ERC721A {
    using Counters for Counters.Counter;

    // Total items
    Counters.Counter private _itemId;
    // TokenId => internal itemId tokenId
    mapping(uint256 => uint256) private _itemInternalIds;
    // TokenId => ItemId
    mapping(uint256 => uint256) private _itemIds;
    // ItemId => internal itemId tokenId Counter
    mapping(uint256 => Counters.Counter) private _itemIdCounters;
    // ItemId => Max Supply
    mapping(uint256 => uint256) private _itemMaxSupply;
    // ItemId => Limited|Unlimited
    mapping(uint256 => bool) private _itemLimited;
    // ItemId => Paused/Unpaused
    mapping(uint256 => bool) private _itemPaused;
    //ItemId => Lock Period
    mapping(uint256 => uint256) private _itemLockPeriod;
    // ItemId => Metadata Contracts
    mapping(uint256 => address) private _metadataFactory;

    error InvalidTokenId();
    error InvalidItemId();
    error ItemPaused();
    error InvalidSupply();
    error MaxSupply();
    error ItemLocked();

    constructor(
        string memory name,
        string memory symbol
    ) ERC721A(name, symbol) {}

    modifier onlyValidItem(uint256 itemId) {
        if (itemId <= 0 && itemId > _itemId.current()) revert InvalidItemId();
        uint256 currentSupply = _itemIdCounters[itemId].current();
        uint256 maxSupply = _itemMaxSupply[itemId];
        if (_itemPaused[itemId]) revert ItemPaused();
        if (_itemLimited[itemId] && currentSupply >= maxSupply)
            revert MaxSupply();
        _;
    }

    function _beforeTokenTransfers(
        address from,
        address, // to,
        uint256 startTokenId,
        uint256 // quantity
    ) internal virtual override {
        // Ignore mints
        if (from == address(0)) return;
        uint256 currentTimestamp = block.timestamp;
        uint256 itemId = _itemIds[startTokenId];
        uint256 lockPeriod = _itemLockPeriod[itemId];
        if (currentTimestamp < lockPeriod) revert ItemLocked();
    }

    function mint(
        uint256 itemId,
        address to
    ) external virtual onlyValidItem(itemId) returns (uint256) {
        uint256 nextToken = _nextTokenId();
        _itemIds[nextToken] = itemId;
        _itemInternalIds[nextToken] = _itemIdCounters[itemId].current();
        _itemIdCounters[itemId].increment();
        _mint(to, 1);
        return nextToken;
    }

    /**
     * @dev Adds a new limited item.
     * @param factory, Metadata contract responsible for supplying a tokenURI
     * @param supply, Amount of tokens this item holds
     */
    function addItem(address factory, uint256 supply) external virtual {
        if (supply == 0) revert InvalidSupply();
        _itemId.increment();
        uint256 itemId = _itemId.current();
        _itemMaxSupply[itemId] = supply;
        _itemLimited[itemId] = true;
        _metadataFactory[itemId] = factory;
    }

    /**
     * @dev Adds a new unlimited item.
     * @param factory, Metadata contract responsible for supplying a tokenURI
     */
    function addItem(address factory) external virtual {
        _itemId.increment();
        uint256 itemId = _itemId.current();
        _metadataFactory[itemId] = factory;
    }

    function addItemIndexed(uint256 index, address factory) external virtual {
        _metadataFactory[index] = factory;
    }

    /**
     * @dev Returns the item id of the token
     * @param tokenId, id of the token
     */
    function getItem(uint256 tokenId) external view returns (uint256) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return _itemIds[tokenId];
    }

    /**
     * @dev Returns the maximum amount of token this item can mint
     * @param itemId, id of the item
     */
    function totalMaxSupply(
        uint256 itemId
    ) external view virtual onlyValidItem(itemId) returns (uint256) {
        return _itemMaxSupply[itemId];
    }

    /**
     * @dev Returns the current amount of tokens this item holds
     * @param itemId, id of the item
     */
    function totalSupply(
        uint256 itemId
    ) external view virtual onlyValidItem(itemId) returns (uint256) {
        return _itemIdCounters[itemId].current();
    }

    /**
     * @dev Pauses the item state to stop the minting process
     * @param itemId, id of the item
     */
    function pauseItem(uint256 itemId) external virtual onlyValidItem(itemId) {
        _itemPaused[itemId] = true;
    }

    /**
     * @dev Unpauses the item state to continue the minting process
     * @param itemId, id of the item
     */
    function unpauseItem(
        uint256 itemId
    ) external virtual onlyValidItem(itemId) {
        _itemPaused[itemId] = false;
    }

    /**
     * @dev Sets the date till the token of an item is locked
     * @param itemId, id of the item
     * @param timePeriod, Unix timestamp of the deadline
     */
    function setLockPeriod(
        uint256 itemId,
        uint256 timePeriod
    ) external virtual {
        _itemLockPeriod[itemId] = timePeriod;
    }

    /**
     * @dev Returns the internal id within an item collection
     * @param tokenId, id of the token
     */
    function getInternalItemId(
        uint256 tokenId
    ) external view returns (uint256) {
        return _itemInternalIds[tokenId];
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        uint256 itemId = _itemIds[tokenId];
        IMetadataFactory metadata = IMetadataFactory(_metadataFactory[itemId]);
        return metadata.tokenURI(_itemInternalIds[tokenId]);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721A.supportsInterface(interfaceId);
    }
}
