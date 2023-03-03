// SPDX-License-Identifier: UNLICENSED
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

    function addComment(address attester, uint256 index, string calldata reason) external;

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
}
