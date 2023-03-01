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

    function attest(address _authorizer, string calldata message) external;

    function contest(address attester, uint256 index, string calldata reason) external;

    function getOwner() external view returns (address);

    function getAttestation(address sender, uint256 index) external view returns (Attestation memory);

    function getAttestations(address sender) external view returns (Attestation[] memory);

}
