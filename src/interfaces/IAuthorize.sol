// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IAuthorize {
    /// @notice Validate that a post on a profile is valid, and updates the
    /// current hash of all validated posts.
    /// @dev throws if any conditions set by the Authorizer are not met for
    /// this post.
    // @param _sender the address that is making the post
    // @param _profile the address of the Profile contract to post to
    // @param _message the content of the message being posted, or a URI to the
    // content.
    function makeValidPost(address _sender, address _profile, string calldata _message) external;
    // @notice Determine whether a post is valid or not state. returns
    // true iff the post matches any criteria set by the Authorizer.
    // @dev returning 'true' from this call should ensure a call to
    // makeValidPost will succeed using the same arguments.
    // @param _sender the address that will make the post
    // @param _profile the address of the Profile contract that will be posted to
    // @param _message the content of the message to be posted, or a URI to the
    // content.
    function isPostValid(address _sender, address _profile, string calldata _message) external view returns (bool);
    /// @notice The latest hash of all validated posts that this authorizer has
    /// approved. By recreating this hash from a Profile's posts, an observer
    /// can identify if the Profile's posts have been deleted, tampered with,
    /// or did not use this Authorizer.
    /// @param _profile The Profile Contract to return the hash for. Each profile
    /// should have a seperately maintained hash.
    function latestValidatedHash(address _profile) external view returns (bytes32);
}
