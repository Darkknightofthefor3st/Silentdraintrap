// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ITrap } from "./interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title SilentDrainTrap
 * @notice Detects slow, sustained balance erosion of a treasury/safe
 * @dev Designed for Drosera: deterministic, windowed, edge-triggered
 */
contract SilentDrainTrap is ITrap {
    /// CONFIG — set these before deployment
    address public constant TOKEN = 0x0000000000000000000000000000000000000000; // SET
    address public constant SAFE  = 0x0000000000000000000000000000000000000000; // SET

    /// Trigger if balance drops >5% across the sample window
    uint256 public constant DROP_THRESHOLD_BPS = 500; // 5%

    struct Sample {
        uint256 blockNumber;
        uint256 balance;
    }

    function collect() external view override returns (bytes memory) {
        uint256 size;
        assembly { size := extcodesize(TOKEN) }
        if (size == 0) return bytes("");

        uint256 bal;
        try IERC20(TOKEN).balanceOf(SAFE) returns (uint256 b) {
            bal = b;
        } catch {
            return bytes("");
        }

        return abi.encode(
            Sample({
                blockNumber: block.number,
                balance: bal
            })
        );
    }

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length < 2) return (false, bytes(""));
        if (data[0].length == 0 || data[data.length - 1].length == 0) {
            return (false, bytes(""));
        }

        Sample memory newest = abi.decode(data[0], (Sample));
        Sample memory oldest = abi.decode(data[data.length - 1], (Sample));

        if (newest.blockNumber <= oldest.blockNumber) {
            return (false, bytes(""));
        }

        if (oldest.balance == 0) return (false, bytes(""));
        if (newest.balance >= oldest.balance) return (false, bytes(""));

        uint256 drop = oldest.balance - newest.balance;
        uint256 dropBps = (drop * 10_000) / oldest.balance;

        if (dropBps < DROP_THRESHOLD_BPS) {
            return (false, bytes(""));
        }

        return (
            true,
            abi.encode(
                SAFE,
                oldest.balance,
                newest.balance,
                dropBps,
                newest.blockNumber
            )
        );
    }
}
