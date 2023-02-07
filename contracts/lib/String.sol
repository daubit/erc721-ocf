// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Math.sol";

library String {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    function equals(
        string memory self,
        string memory s
    ) public pure returns (bool) {
        return
            keccak256(abi.encodePacked(self)) == keccak256(abi.encodePacked(s));
    }

    function concat(
        string memory self,
        string memory s
    ) public pure returns (string memory) {
        return string(abi.encodePacked(self, s));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
}
