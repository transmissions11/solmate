// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Hevm {
    function warp(uint256) external;

    function roll(uint256) external;

    function store(
        address,
        bytes32,
        bytes32
    ) external;

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
