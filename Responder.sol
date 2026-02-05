// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SilentDrainResponder
 * @notice Emits an alert when a slow treasury drain is detected
 */
contract SilentDrainResponder {
    event SilentDrainDetected(
        address indexed safe,
        uint256 oldBalance,
        uint256 newBalance,
        uint256 dropBps,
        uint256 blockNumber
    );

    // Open responder for PoC. Add caller gating if desired.
    function respondToSilentDrain(
        address safe,
        uint256 oldBalance,
        uint256 newBalance,
        uint256 dropBps,
        uint256 blockNumber
    ) external {
        emit SilentDrainDetected(
            safe,
            oldBalance,
            newBalance,
            dropBps,
            blockNumber
        );
    }
}
