---
eip:
title: Profile and Authorizor Standard
description: Peer-to-peer contextual attestions.
author: Alex Durville (@o0880o), Austin (@PizzaHi5), Cam Cloo (?), Jonathan White (@jonvaljonathan),
discussions-to: 
status: Draft
type: Standards Track
category: ERC
created: 2023-02-27
requires: 
---

## Abstract

This proposal defines a system where one contract or account can post a message to another contract in a given context as determined by an authorizer contract.

Profile Contract: A deployed contract owned by an EOA or another contract. The owner of the contract may add Authorizer contracts to the determine who can post to their profile.

Authorizor Contract: A contract that determines verifies context and content of a post. If the poster, the recieving profile, and the message pass the authorization criteria, the post is accepted and can be written to the recievers profile. The poster and the reciever can have different criteria.

This simple system creates opt-in permissionless reputation system. With it, developers could build reputation based markets, decentralized review boards, credit systems, and more.

A simple implementation would be having the Authorizer verify that both the poster and the reciever own an NFT or a certain amount of an ERC 20 token. If so, they may post on eachother's profile.

A more complex implementation would be defining the Authorizer so that the poster must have made a transactions to the reciever, in a certain time period. The Authorizer could also verify some off-chain test was passed and the message was formatted in a certain way.



## Motivation

A standard spedcification allowing one EOA or contract to attest / post on another's profile contract. They can do this under certain conditions that the profile contract opted into to be managed by the Authorizer contract.

With this standard, we could build:
-A decentralized review board where the reviewee chooses the conditions of the review and owns it after it has been given. We could do this by configuring the authorizer to validat the poster must have made a transaction of a certain amount to the owner of the reciever's profile contract. 
-Onchain credit systems. By configuring the authorizer to verify off-chain credit worthiness.
-Labor markets. By configuring reviews of reputable employers and employees. Employees can own their reputation and verifiably prove it.

We can imagine a world where restaurants coalesce around a single authorizer contract. That authorizer contract will have desirable criteria it.

We can also imagine a world where the legitimacy of a post or review is deterimined by the robustness of the authorizer contract. We imagine that networks and graphs will form around the authorizer contracts. Some will be serious, while others will be playfull amongst friends.



## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### Overview

The system outlined in this proposal has two main components:

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //Authorizer defines criteria to approve transaction
    function isApprovedToSend(address profile) external view returns (bool);

    //Authorizer defines critera to receive transaction
    function isApprovedToReceive(address profile) external view returns (bool);
}

pragma solidity ^0.8.13;

interface IProfile {

    event Attest(address sender, uint256 index, string message);

    event AuthorizeChange(address authorizer, bool status);

    event Contest(uint256 index, string message);

    function attest(address _authorizer, string calldata message) external;

    function contest(address attester, uint256 index, string calldata reason) external;

    function getOwner() external view returns (address);
}

### Registry

The registry serves as a single entry point for projects wishing to utilize token bound accounts. It has two functions:

- `createAccount` - deploys a token bound account for an ERC-721 token given an `implementation` address
- `account` - a read-only function that computes the token bound account address for an ERC-721 token given an `implementation` address

The registry SHALL deploy each token bound account as an [ERC-1167](./eip-1167.md) minimal proxy with immutable arguments.

The the deployed bytecode of each token bound account SHALL have the following structure:

```
ERC-1167 Header               (10 bytes)
<implementation (address)>    (20 bytes)
ERC-1167 Footer               (15 bytes)
STOP code                     (1 byte)
<chainId (uint256)>           (32 bytes)
<tokenContract (address)>     (32 bytes)
<tokenId (uint256)>           (32 bytes)
```

For example, the token bound account with implementation address `0xbebebebebebebebebebebebebebebebebebebebe`, chain ID `1`, token contract `0xcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcf` and token ID `123` would have the following deployed bytecode:

```
363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000cfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfcf000000000000000000000000000000000000000000000000000000000000007b
```

Each token bound account contract SHALL delegate execution to a static account implementation address that implements the token bound account interface.

The registry contract is permissionless, immutable, and has no owner. The registry can be deployed on any Ethereum chain using the following transaction:

```json
{
  "nonce": "0x00",
  "gasPrice": "0x09184e72a000",
  "gasLimit": "0x27100",
  "value": "0x00",
  "data": "TODO",
  "v": "0x1b",
  "r": "TODO",
  "s": "TODO"
}
```

The registry contract will be deployed to the following address: `TBD`

The registry SHALL deploy all token bound account contracts using the `create2` opcode with a salt value derived from the ERC-721 token contract address, token ID, and [EIP-155](./eip-155.md) chain ID.

The registry SHALL implement the following interface:

```solidity
interface IERC6551Registry {
    /// @dev Each registry MUST emit the AccountCreated event upon account creation
    event AccountCreated(
        address account,
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    );

    /// @dev Creates a token bound account for an ERC-721 token.
    ///
    /// Emits AccountCreated event.
    ///
    /// @return the address of the created account
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address);

    /// @dev Returns the computed address of a token bound account
    ///
    /// @return The computed address of the account
    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address);
}
```

### Account Interface

All token bound accounts SHOULD be created via the registry.

All token bound account implementations MUST implement [ERC-165](./eip-165.md) interface detection.

All token bound account implementations MUST implement [ERC-1271](./eip-1271.md) signature validation.

All token bound account implementations MUST implement the following interface:

```solidity
/// @dev the ERC-165 identifier for this interface is `0xeff4d378`
interface IERC6551Account {
    /// @dev Token bound accounts MUST implement a `receive` function.
    ///
    /// Token bound accounts MAY perform arbitrary logic to restrict conditions
    /// under which Ether can be received.
    receive() external payable;

    /// @dev Executes `call` on address `to`, with value `value` and calldata
    /// `data`.
    ///
    /// MUST revert and bubble up errors if call fails.
    ///
    /// By default, token bound accounts MUST allow the owner of the ERC-721 token
    /// which owns the account to execute arbitrary calls using `executeCall`.
    ///
    /// Token bound accounts MAY implement additional authorization mechanisms
    /// which limit the ability of the ERC-721 token holder to execute calls.
    ///
    /// Token bound accounts MAY implement additional execution functions which
    /// grant execution permissions to other non-owner accounts.
    ///
    /// @return The result of the call
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory);

    /// @dev Returns identifier of the ERC-721 token which owns the
    /// account
    ///
    /// The return value of this function MUST be constant - it MUST NOT change
    /// over time.
    ///
    /// @return chainId The EIP-155 ID of the chain the ERC-721 token exists on
    /// @return tokenContract The contract address of the ERC-721 token
    /// @return tokenId The ID of the ERC-721 token
    function token()
        external
        view
        returns (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        );

    /// @dev Returns the owner of the ERC-721 token which controls the account
    /// if the token exists.
    ///
    /// This is value is obtained by calling `ownerOf` on the ERC-721 contract.
    ///
    /// @return Address of the owner of the ERC-721 token which owns the account
    function owner() external view returns (address);
}
```

## Rationale

### Account Ambiguity

The specification proposed above allows ERC-721 tokens to have multiple token bound accounts, one per implementation address. During the development of this proposal, alternative architectures were considered which would have assigned a single token bound account to each ERC-721 token, making each token bound account address an unambiguous identifier.

However, these alternatives present several trade offs.

First, due to the permissionless nature of smart contracts, it is impossible to enforce a limit of one token bound account per ERC-721 token. Anyone wishing to utilize multiple token bound accounts per ERC-721 token could do so by deploying an additional registry contract.

Second, limiting each ERC-721 token to a single token bound account would require a static, trusted account implementation to be included in this proposal. This implementation would inevitably impose specific constraints on the capabilities of token bound accounts. Given the number of unexplored use cases this proposal enables and the benefit that diverse account implementations could bring to the non-fungible token ecosystem, it is the authors' opinion that defining a canonical and constrained implementation in this proposal is premature.

Finally, this proposal seeks to grant ERC-721 tokens the ability to act as agents on-chain. In current practice, on-chain agents often utilize multiple accounts. A common example is individuals who use a "hot" account for daily use and a "cold" account for storing valuables. If on-chain agents commonly use multiple accounts, it stands to reason that ERC-721 tokens ought to inherit the same ability.

### Proxy Implementation

ERC-1167 minimal proxies are well supported by existing infrastructure and are a common smart contract pattern. However, ERC-1167 proxies do not support storage of constant data. This proposal deploys each token bound account as a lightly modified ERC-1167 proxy with static data appended to the contract bytecode. The appended data is abi-encoded to prevent hash collisions and is preceded by a stop code to prevent accidental execution of the data as code. This approach was taken to maximize compatibility with existing infrastructure while also giving smart contract developers full flexibility when creating custom token bound account implementations.


## Backwards Compatibility



## Reference Implementation

### Example Account Implementation


### Registry Implementation



## Security Considerations



## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
