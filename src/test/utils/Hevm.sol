// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;
pragma abicoder v2;

interface Hevm {
    function warp(uint256) external;

    function roll(uint256) external;

    function store(
        address,
        bytes32,
        bytes32
    ) external;

    function load(address, bytes32) external returns (bytes32);

    function sign(uint256, bytes32)
        external
        returns (
            uint8,
            bytes32,
            bytes32
        );

    function addr(uint256) external returns (address);

    function ffi(string[] calldata) external returns (bytes memory);
}
