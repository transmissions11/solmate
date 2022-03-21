// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;
interface Hevm {
    /// @notice Set block.timestamp (newTimestamp)
    function warp(uint256) external;
    /// @notice Set block.height (newHeight)
    function roll(uint256) external;
    /// @notice Set block.basefee (newBasefee)
    function fee(uint256) external;
    /// @notice Loads a storage slot from an address (who, slot)
    function load(address,bytes32) external returns (bytes32);
    /// @notice Stores a value to an address' storage slot, (who, slot, value)
    function store(address,bytes32,bytes32) external;
    /// @notice Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256,bytes32) external returns (uint8,bytes32,bytes32);
    /// @notice Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
    /// @notice Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);
    /// @notice Sets the *next* call's msg.sender to be the input address
    function prank(address) external;
    /// @notice Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;
    /// @notice Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address,address) external;
    /// @notice Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address,address) external;
    /// @notice Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;
    /// @notice Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;
    /// @notice Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;
    /// @notice Expects an error on next call
    function expectRevert(bytes calldata) external;
    function expectRevert(bytes4) external;
    /// @notice Record all storage reads and writes
    function record() external;
    /// @notice Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);
    /// @notice Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    /// @notice Call this function, then emit an event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data (as specified by the booleans)
    function expectEmit(bool,bool,bool,bool) external;
    /// @notice Mocks a call to an address, returning specified data.
    /// @notice Calldata can either be strict or a partial match, e.g. if you only
    /// pass a Solidity selector to the expected calldata, then the entire Solidity
    /// function will be mocked.
    function mockCall(address,bytes calldata,bytes calldata) external;
    /// @notice Clears all mocked calls
    function clearMockedCalls() external;
    /// @notice Expect a call to an address with the specified calldata.
    /// @notice Calldata can either be strict or a partial match
    function expectCall(address,bytes calldata) external;
    /// @notice Fetches the contract bytecode from its artifact file
    function getCode(string calldata) external returns (bytes memory);
    /// @notice Label an address in test traces
    function label(address addr, string calldata label) external;
    /// @notice When fuzzing, generate new inputs if conditional not met
    function assume(bool) external;
}
