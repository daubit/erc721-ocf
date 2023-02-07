# ERC721OCF (On-Chain Factory)

This projects provides an ERC721A extension. Checkout the [ERC721A](https://www.npmjs.com/package/erc721a]) contract for the optimizations.
We built upon those to provide some extra functionality such as multiple tokens per contract. ERC721OCF behaves similar to the ERC1155 standard but manages multiple tokens (ERC721).

## Installation

NPM:

```sh
npm install --save-dev erc721-ocf
```

Yarn:

```sh
yarn add -D erc721-ocf 
```

## Usage

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity ^0.8.17;

import "erc721-ocf/contracts/ERC721OCF.sol";

contract MyToken is ERC721OCF {
    constructor() ERC721A("MyToken", "MT") {}
}
```

## License

Distributed under MIT License. See LICENSE for more information.
