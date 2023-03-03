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

This proposal defines a system where individual contracts can post messages to one another. In order to avoid sybil attacks, and increase the authenticity and value of these messages, each contract lists a set of authoritative contracts that define rules on who is allowed, and who is not allowed, to post messages.

This delegation of authority allows the individual contracts to remain decentralized, while still allowing central authority entities to weed out unwanted actors. Since each contract is free to decide it's own list of authorities, there is no ability for one authority to ever control the system. In addition, in this 'opt-in' security scheme, authorities behaving as bad actors can simply be ignored.

This system is composed of two contract interfaces: The "Profile" contract, and the "Authorizer" contract.

### Profile Contract

A deployed contract owned by an EOA or contract. The profile contains a set of posted messages. The owner of the contract may add Authorizer contracts to determine who can post to their profile.

Profiles could represent and individual, organization, or a contract. They could be deployed by EOA's, multisigs, account abstracted accounts. Anyone entity can deploy multiple contracts.

### Authorizer Contract

A contract that hosts a set of rules about whether or not a post can be made. If the poster, the receiving profile contract, and the message pass the given rules, a Profile contract can accept the post.

The poster and the reciever can have different criteria. The authorizer can save the sender, reciever, and message. This data can be crosschecked against a profile contract to verify the integrity of the profile.

## Motivation

This simple system creates an opt-in permissionless reputation system, that can be used to serve many different goals. With it, developers could build social networks, decentralized review boards, employee-owned work profiles, and more. By using common interfaces, this data can be used in reputation based markets, credit systems, and more, increasing the value of the network as a whole.

A simple implementation of this system could just be members within a particular group giving each other endorements on their activity. An Authorizer could easily verify that both the poster and the reciever own an NFT or a certain amount of an ERC 20 token. If so, they may post on eachother's profile. These sorts of tokens are already used frequently to validate membership in groups, and prevent abuse from unknown addresses outside the group.

More complex implementations could verify both on-chain and off-chain data using oracles, or other existing smart-contract patterns. Some powerful examples could include: an Authorizer verifying purchase from a company before leaving a review. Verifying two people are friends via an existing social network off-chain before they can post to one another. Allowing anyone employed by a particular company to endorse each other, providing a form of more authentic work-related endorsements, backed by on-chain attestation. Using zero-knowledge proofs to validate private data before making a public post.

One of the main benefits of this standard is the abstraction of the Profile contract. Rather than having a single contract that manages the state of all possible posts, each actor on the network owns their own contract. While these contracts could still delegate to an existing contract for usability, it forces a higher level of decentralization. In a world with upgradable contracts and patterns, having a single contract can lead to (fees, bad stuff). A primary motivation is to build a network-of-networks where each individual truely owns their own profile.


With this standard, we could build:
-A decentralized review board where the reviewee chooses the conditions of the review and owns it after it has been given. We could do this by configuring the authorizer to validat the poster must have made a transaction of a certain amount to the owner of the reciever's profile contract. 
-Onchain credit systems. By configuring the authorizer to verify off-chain credit worthiness.
-Labor markets. By configuring reviews of reputable employers and employees. Employees can own their reputation and verifiably prove it.

## Example Use case

We can imagine a world where restaurants coalesce around a single trusted authorizer contract. They may even form a DAO to maintain the authorizer contract, deploy the profiles, and host a front-end application.

The legitimacy of a post or review is deterimined by the robustness of the authorizer contract. We imagine that networks and graphs will form around the authorizer contracts. Some will be serious, while others will be playfull amongst friends.

Authorizer contracts can verify arbitrary on or off-chain data. Depending on their authorization parameters, they will be more or less sybil resistant. They could require that a profile holds an NFT, does not hold an NFT, has a certain balance, meets an off-chain condition, and more.

Profile holders will be able to own their own reputation via a deployed contract. They can opt-in to an authorizer contract. If they chose, they can delete a post from their profile. Front-ends will be able to check the posts against the stored posts on the authorizer contract. If they are not the same, the front-ends may raise a flag or disallow the content from being shown. 

Prfoile holders may also contest posts on their profile. Front-ends will handle how these posts are handled.    

1. Check the hashes
2. Sybil resistance - every post has an authorizer. authorizers provide trusted moderation. we're not dealing with completely unknown actors...

Authorizers keep negative posts. Organizations can burn scammers by minting a ERC721 to their address which there authorizer can check against.

having a blacklist would disable posting and always return an invalid message hash indicating suspicious activity.

reinventing your identity is a feature and not a bug. if you want to cut bad ties, that's your perogative in a decnetralized world.

Why is the own your own profile contract the better paradigm then one contract?
-opt-in
-no centralized contract holder
-you can compose reputation from all other centralized contracts
-you can find all the repuation in one place rather than scouring different contracts for it




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

    //
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
