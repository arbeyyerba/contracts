---
eip:
title: User Owned Social/Reputation Profiles
description: A user owned social profile contract that utilizes authoritative contracts owned by external entities to enforce posting rules and avoid sybil attacks
author: o080o (@o0880o), Austin (@PizzaHi5), Cam Cloo (?), Jonathan White (@jonvaljonathan),
discussions-to: 
status: Draft
type: Standards Track
category: ERC
created: 2023-02-27
---

## Abstract

This proposal defines a system where individuals can own contracts representing their own profile. The owner of a profile can list several authoritative 'Authorizer' contracts to their profile, where each authorizer enforces a set of rules about who is allowed to post to the individual's profile. Anyone can then post data to a profile by selecting an 'Authorizer' from the profile's list, and meeting that contract's on-chain validation criteria. An interface for the 'Profile' and 'Authorizer' contracts allow a rich ecosystem of authoritative entities to moderate content and enforce rules. Ownership of the profile contract  allows the owner full control over who can post data to their profile, and what data remains on their profile, while remaining completely decentralized.

## Motivation

There is a growing desire to maintain more state about one's social capital on-chain, not just financial capital. However, currently most social systems follow a trend of locking a user's data whithin a centrally owned and managed contract. This opens the door to future updates or fees that the user may not agree to, but is unable to prevent. Especially in a world of upgradable contracts, off-chain oracles, and more mutable-state, a single smart-contract does not always mean constant, immutable functionality.

A core motivation for this work is to allow an individual full ownership of their social reputation. By owning the contracts, we hope to discourage any sort of centralizing forces coercing users into new rules.

In addition, we see composability and interoperability a key feature of smart-contracts. It is our intention that a rich ecosystem of profile, authorizer, and front-end implementations emerge to meet different user needs and use-cases. By leaving the implementations open, we see a lot of potential use cases. Especially for systems that can leverage both on-chain, off-chain or cross-chain data to validate a user's post requirements.

We also see Authorizers as an interesting solution to the sybil problem. Without any sort of authority on who is "real", it may be near impossible for a system to differentiate between a "real" user, and an automated or "fake" user who is taking similar actions. Solving that is an incredibly hard problem, that does not have a good solution yet. Many solutions end up relying on some centralized authority. However, by delegating that centralized authority to several smaller authorities, we can still gain their benefit. And allowing a user to 'pick and choose' which authorities to listen to maintains a decentralized approach.

For instance, you might want to allow "people in a particular DAO" to post to your profile. Where the DAO acts as an authoritative entity on who is a member. If you later leave that DAO on bad terms (maybe you disagreed with their direction?), you can simply remove that entity from having any authority on your profile.


- users should own their profiles, not allow other entities to enact fees without consent.
- social capital is as important as financial capital, need ways to encode that on the blockchain
- allow a healthy ecosystem of 'networks within networks' of social systems
- composability and interoperability with other "products"


One of the main benefits of this standard is the abstraction of the Profile contract. Rather than having a single contract that manages the state of all possible posts, each actor on the network owns their own contract. While these contracts could still delegate to an existing contract for usability, it forces a higher level of decentralization. In a world with upgradable contracts and patterns, having a single contract can lead to (fees, bad stuff). A primary motivation is to build a network-of-networks where each individual truely owns their own profile.


With this standard, we could build:
-A decentralized review board where the reviewee chooses the conditions of the review and owns it after it has been given. We could do this by configuring the authorizer to validat the poster must have made a transaction of a certain amount to the owner of the reciever's profile contract. 
-Onchain credit systems. By configuring the authorizer to verify off-chain credit worthiness.
-Labor markets. By configuring reviews of reputable employers and employees. Employees can own their reputation and verifiably prove it.


## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.


The system outlined in this proposal has two main components, a "Profle" contract interface, and a "Authorizer" contract interface.

 "Profile" contract maintains a list of "Authorizer" contracts, as well as a list of posts made using each authorizer.
 
 A Post is either a simple string containing data, or it is a URI to a location to fetch the data. The schema of the data is described in section TBD.
 
An "Authorizer" contract has a `makeValidPost` method, and a read-only `isValidPost` method that encode the rules for what address can post to a particular profile.
If `isValidPost` returns true, then `makeValidPost` SHOULD also succeed without reverting, given the same arguments, baring exceptions like changes to the chain state.

The contract also MUST maintain a hash of all posts for a given profile. This hash is used to identify alterations to a profile's posts. This hash can be calculated and updated in `makeValidPost` by taking the previous hash for that profile, and XOR'ing it with a keccak hash of the new message. An example is piven below:

```
mapping(address => bytes32) hashedPosts;
...
function makeValidPost(address sender, address profile, string calldata message) external {
    bytes32 currentHash = hashedPosts[profile];
    currentHash ^= keccak256(abi.encodePacked(message));
    hashedPosts[profile] = currentHash;
}

```
 
 Any other account can post data to a "Profile" contract using `addPost`. `addPost` should succeed if and only if it passes the "Authorizers" `makeValidPost` method without reverting. Not calling `makeValidPost`, or altering message data after sending it to `makeValidPost` will result in the calculated hash on the "Authorizer" contract being different that what an observer calculates from the data on the "Profile". 
 
 By calling `isValidPost`, a user can know ahead of time whether their call to `addPost` will fail due to not meeting the 'Authorizer' requirements. 
 
 In order to facilitate deleting posts and content, a "Profile" contract SHOULD replace a post's sender with the profile contact's address, and replace the content with the calculated hash of all previous posts. This will allow for an observer to check the validity of all other posts, yet still identify that the post data has been altered for the deleted post.
 
 Anyone can view all the posts made using a particular "Authorizer" by calling `postsByAuthorizer`, as well as get a list of all possible "Authorizers" by calling `authorizerList`. Specific posts can be retrieved using `postByAuthorizerAndIndex`. The total number of posts made through a particular authorizer can be obtained from calling `postLengthByAuthorizer`.
 
 "Authorizers" may need to check details for the owner of the "Profile" contract, such as if they are a member of a DAO. contracts can call `profileOwner` to retrieve that data.
 
### Profile Contract interface

```
pragma solidity ^0.8.13;

interface IProfile {

    struct Attestation {
        address sender;
        string message;
    }

    event AuthorizeChange(address authorizer, bool status);
    event Attest(address sender, address authorizer, uint256 index);
    event Contest(address authorizer, uint256 index);

    /// @notice Add a post to this profile, using the specified authorizer
    /// contract to Approve.
    /// The Authorizer contract MUST validate any conditions the sender
    /// and the profile must meet.
    /// @dev this function throws for posts that do not meet the Authorizers
    /// criteria.
    /// @param _authorizer The address of an Authorizer contract to validate
    /// any posting rules
    /// @param _message The content of the post. MUST be either a string
    /// containing the post or a URI to find the content of the post.
    function addPost(address _authorizer, string calldata _message) external;

    /// @notice The address that owns this profile, and will be used for any
    /// checks made by Authorizer contracts.
    function profileOwner() external view returns (address);

    /// @notice A post made using the specified authorizer, at the specified
    /// index
    /// @param _authorizer An address for an Authorizer contract to validae
    /// the posting rules
    /// @param _index The index of the post for this Authorizer
    function postByAuthorizerAndIndex(address _authorizer, uint256 _index) external view returns (Attestation memory);

    /// @notice All posts made using the specified authorizer.
    /// @param _authorizer An address for an Authorizer contract to validae
    /// the posting rules
    /// @param _index The index of the post for this Authorizer
    function postsByAuthorizer(address _authorizer) external view returns (Attestation[] memory);

    /// @notice The number of posts made to this profile using the specified
    /// Authorizer contract address
    /// @param _authorizer the Authorizer contract used to make the posts
    function postLengthByAuthorizer(address _authorizer) external view returns (Attestation[] memory);

    /// @notice The complete list of authorizers approved for this contract
    function authorizerList() external view returns (address[] memory);
}
```

### Authorizer Contract

```
pragma solidity ^0.8.13;

interface IAuthorize {
    /// @notice Validate that a post on a profile is valid, and updates the
    /// current hash of all validated posts.
    /// @dev throws if any conditions set by the Authorizer are not met for
    /// this post.
    // @arg _sender the address that is making the post
    // @arg _profile the address of the Profile contract to post to
    // @arg _message the content of the message being posted, or a URI to the
    // content.
    function makeValidPost(address _sender, address _profile, string calldata _message) external;
    // @notice Determine whether a post is valid or not state. returns
    // true iff the post matches any criteria set by the Authorizer.
    // @dev returning 'true' from this call should ensure a call to
    // makeValidPost will succeed using the same arguments.
    // @arg _sender the address that will make the post
    // @arg _profile the address of the Profile contract that will be posted to
    // @arg _message the content of the message to be posted, or a URI to the
    // content.
    function isPostValid(address _sender, address _profile, string calldata _message) external view returns (bool);
    /// @notice The latest hash of all validated posts that this authorizer has
    /// approved. By recreating this hash from a Profile's posts, an observer
    /// can identify if the Profile's posts have been deleted, tampered with,
    /// or did not use this Authorizer.
    /// @arg _profile The Profile Contract to return the hash for. Each profile
    /// should have a seperately maintained hash.
    function latestValidatedHash(address _profile) external view returns (bytes32);
}
```


## Rationale

**needs discussion**

## Backwards Compatibility

(no other accepted EIPs cover this use case)

**needs discussion**

## Reference Implementation

### Example "Authorizer" that allows anyone to post

```
pragma solidity ^0.8.13;

contract AlwaysValidAuthorizer {

    mapping(address => bytes32) hashedPosts;

    error InvalidCaller(address profile);

    // function validateTransaction(address profile, address target, string calldata message) external returns (bool) {
    function makeValidPost(address sender, address profile, string calldata message) external {
        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedPosts[profile] = currentHash;
    }

    function isValidPost(address sender, address profile, string calldata message) external returns (bool) {
        return true;
    }

    function latestValidatedHash(address profile) external view returns (bytes32) {
        return hashedPosts[profile];
    }
}

```

### Example "Profile"

```

pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";

/**
    @notice This is the first iteration of a Profile contract. This contract has basic functionality.
        Store the posts of users as strings on-chain given they meet the Authorizer's 
        criteria. Future implementations will use a different more efficient storage method. 
 */

contract Profile {
    string public ownerName;

    //profile to authorizers
    address[] authorizedContracts;

    //authorizer to messages
    mapping(address => Attestation[]) public attestations;

    //authorizer and index to message
    mapping(address => mapping(uint256 => string)) public contestations;

    string name;


    error AuthorizerDenied();
    error TransactionDenied(address sender, address authorizer);

    constructor(string memory _ownerName) {
        ownerName = _ownerName;
    }

    //
    // EXTERNAL
    //

    /// @notice Attesters needs profile address, authorizer address, and attest message, IPFS CID (32bytes)
    function addPost(address _authorizer, string calldata message) external nonReentrant {
        if(!isAuthorizer(_authorizer)) revert AuthorizerDenied();
        if(!(IAuthorize(_authorizer).validateTransaction(msg.sender, address(this), message))) 
            revert TransactionDenied(msg.sender, _authorizer);

        attestations[_authorizer].push(Attestation(msg.sender, message));
        emit Attest(msg.sender, _authorizer, getAttestLength(_authorizer) - 1);
    }

    //
    // EXTERNAL Only-Owner
    //

    /// @dev Add authorizer
    function addAuthorizer(address newAuthorizer) external onlyOwner {
        authorizedContracts.push(newAuthorizer);
        emit AuthorizeChange(newAuthorizer, true);
    }

    /// @dev Removes authorizer
    function removeAuthorizer(address badAuthorizer) external onlyOwner{
        authorizedContracts.push(badAuthorizer);
        emit AuthorizeChange(badAuthorizer, false);
    }


    function setName(string _name) external onlyOwner {
        name = _name;
    }

    /// @dev Stores contest message onchain
    function addComment(address _authorizer, uint256 index, string calldata message) external onlyOwner {
        contestations[_authorizer][index] = message;
        emit Contest(_authorizer, index);
    }

    /// @notice allow the owner to delete content they do not agree with. However, this will make the message hashes
    /// not match what the authorizer has on file, so anyone will know the messages were modified.
    function deleteAttestation(address authorizer, uint256 index) external onlyOwner {
        attestations[authorizer][index]=Attestation(address(this), '');
    }

    /// @notice Allow the owner to delete content they do not agree with, while still enabling
    /// a viewer to recompute the correct hash of all posts.
    /// @dev by putting the hash at the deleted message, someone looking at this profile could identify this
    /// as the deleted message, and use it to continue calculating the true hash.
    /// This lets the user know both that a) a message was deleted and b) *which* message was deleted, while
    /// still verifying that no other messages were tampered with.
    ///
    /// By using the contract address as the sender, we also indicate that this is a 'magic' value,
    /// not a real attestation.
    function deleteAttestationWithHash(address authorizer, uint256 index, bytes32 hash) external onlyOwner {
        string memory hashAsString = string(abi.encodePacked(hash));
        attestations[authorizer][index]=Attestation(address(this), hashAsString);
    }

    /// @dev Set new owner name
    function setOwnerName(string calldata _newOwnerName) external onlyOwner {
        ownerName = _newOwnerName;
    }

    //
    // EXTERNAL VIEW
    //

    function getOwner() external view returns (address) {
        return owner();
    }

    /// @dev Get a list of all messages from a sender
    function postsByAuthorizer(address authorizer) external view returns (Attestation[] memory) {
        return attestations[authorizer];
    }

    /// @dev Get a specific message from sender at index
    function postByAuthorizerAndIndex(address authorizer, uint256 index) external view returns (Attestation memory) {
        return attestations[authorizer][index];
    }

     /// @dev Get a specific message from sender at index
    function commentByAuthorizerAndIndex(address authorizer, uint256 index) external view returns (string memory) {
        return contestations[authorizer][index];
    }

    function getAuthorizerList() external view returns (address[] memory) {
        return authorizedContracts;
    }

    //
    // PUBLIC VIEW
    //

    /// @dev Get total length of message array
    function postsLengthByAuthorizer(address authorizer) public view returns (uint256) {
        return attestations[authorizer].length;
    }

    /// @dev Check if authorizer in authorizer array
    function isAuthorizer(address _authorizer) public view returns (bool) {
        for(uint i=0; i < authorizedContracts.length; i++) {
            if(authorizedContracts[i] == _authorizer) {
                return true;
            }
        }

        return false;
    }

    function getMetadataUri() public view returns (string memory) {
        return string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked('{"name":"', name, '"}')))));
    }
}
```

## Security Considerations

**needs discussion**

The main security consideration is around the trustworthyness of various Profile and Authorizer implementations.

# malicious/inappropriate content of posts
A user could post malicious content to another user's profile. 

A profile should be able to delete malicious content from a user. However, for many use-cases, deleting posts could be seen as malicious, or an attempt to avoid negative comments. For example, removing bad feedback from a coworker before submitting a resume would be poor form. 

The data is never truely deleted, as it could be recovered from an archive node or through old transaction data, however it shouldn't be forced to stay on your profile.

This prompted the inclusion of the post hash in the "Authorizer", so that an observer could identify this sort of behavior to determine whether an individual is being authentic about their posts or not, without preventing someone from doing so.

### fake posts made by a poster

A malicious Profile could advertise posts that were not made by an individual.

To avoid spoofing comments from reputable members of a community, we should include the 'sender' field as part of the post hash.


## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).


# Word Salad (to be deleted)


### Seperate contracts
### hashing post content

- why seperate contracts
- on hashing: users should be able to delete messages, but not be able to hide that fact from others
- concerns about malicious contracts

### Example Use cases

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

More complex implementations could verify both on-chain and off-chain data using oracles, or other existing smart-contract patterns. Some powerful examples could include: an Authorizer verifying purchase from a company before leaving a review. Verifying two people are friends via an existing social network off-chain before they can post to one another. Allowing anyone employed by a particular company to endorse each other, providing a form of more authentic work-related endorsements, backed by on-chain attestation. Using zero-knowledge proofs to validate private data before making a public post.
