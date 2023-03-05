// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMetadata {
    // @notice A Uniform Resuorce Identifier (URI) for the given profile or
    // authorizer
    // @dev URIs are defined in RFC 3986. The UTI may point to a JSON file that
    // conforms to the "ERC721" Metadata JSON Schema. The "name" field should
    // be used for the displayed name of a Profile or Authorizer.
    function getMetadataUri() external view returns (string memory);
}
