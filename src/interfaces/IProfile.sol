// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProfile {

    /** @dev
        Tried to incorporate struct, made validating authorizer data with keccak256 hash very expensive
        authorizer to AttestData
        mapping(address => AttestData)

        struct AttestData {
            address sender;
            string attest;
        } 

        @dev Other idea: removes contest mapping, directly ties attest and contest together
            drawback: -creates additional storage string that often times not used
                      -more expensive to validate data (more data to encode/hash)
        struct Endorse {
            string attest;
            string contest;
        }
    */

    event AuthorizeChange(address authorizer, bool status);
    event Attest(address sender, uint256 index, string message);
    event Contest(address sender, uint256 index, string message);

    function attest(address _authorizer, string calldata message) external;

    function contest(address attester, uint256 index, string calldata reason) external;

    function getOwner() external view returns (address);

    function getAttestation(address sender, uint256 index) external view returns (string memory);

    function getAttestations(address sender) external view returns (string[] memory);

}
