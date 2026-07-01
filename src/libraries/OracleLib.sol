// SPDX-License-Identifier:

pragma solidity ^0.8.18;

/*
 * @title OracleLib
 * @author Chinmay Anand
 * @notice This library is used to check the Chainlink Oracle for stale data.
 * If a price is stale, the function will revert, and render the DSCEngine unusable - this is by design.
 * We want the DSCEngine to freeze if prices become stale.
 *
 * So if the Chainlink network explodes and you have a lot of money locked in the protocol... too bad!
 */
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library OracleLib {
    error OracleLib__PriceIsStale();
    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(
        AggregatorV3Interface priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) {
            revert OracleLib__PriceIsStale();
        }
        return (roundId, price, startedAt, updatedAt, answeredInRound);
    }
}
