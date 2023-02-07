// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../lib/Counters.sol";
import "../interfaces/IMetadataFactory.sol";
import "../ERC721OCF.sol";
import "./common/OpenSeaPolygonProxy.sol";
import "./common/meta-transactions/ContentMixin.sol";
import "./common/meta-transactions/NativeMetaTransaction.sol";

contract ERC721OCFOpensea is ERC721OCF, ContextMixin, NativeMetaTransaction {
    using Counters for Counters.Counter;

    address public _proxyRegistryAddress;
    string private _contractCID;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721OCF(name, symbol) {}

    /**
     * @dev This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSenderERC721A()
        internal
        view
        override
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }

    function setContractCID(string memory contractCID_) external virtual {
        _contractCID = contractCID_;
    }

    function setProxyRegistryAddress(
        address proxyRegistryAddress
    ) external virtual {
        _proxyRegistryAddress = proxyRegistryAddress;
    }

    /**
     * @dev Returns the contract CID.
     */
    function contractCID() external view returns (string memory) {
        return string(abi.encodePacked(_baseURI(), _contractCID));
    }

    /**
     * @dev Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721OCF) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721OCF.supportsInterface(interfaceId);
    }
}
