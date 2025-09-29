// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// ─── Imports ─────────────────────────────────────────────────────────────

import {AggregatorV3Interface} from "@chainlink/contracts@1.3.0/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts@5.2.0/access/Ownable.sol";
import {MyERC20} from "./MyERC20.sol";

// ─── Contract ─────────────────────────────────────────────────────────────

contract TokenShop is Ownable {

    // ─── State Variables ────────────────────────────────────────────────

    AggregatorV3Interface internal immutable i_priceFeed;
    MyERC20 public immutable i_token;

    uint256 public constant TOKEN_DECIMALS = 18;
    uint256 public constant TOKEN_USD_PRICE = 2 * 10 ** TOKEN_DECIMALS; // 2 USD with 18 decimals

    // ─── Events ─────────────────────────────────────────────────────────

    event BalanceWithdrawn();

    // ─── Custom Errors ──────────────────────────────────────────────────

    error TokenShop__ZeroETHSent();
    error TokenShop__CouldNotWithdraw();

    // ─── Constructor ────────────────────────────────────────────────────

    constructor(address tokenAddress) Ownable(msg.sender) {

        i_token = MyERC20(tokenAddress);

        i_priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    // ─── Public View Functions ──────────────────────────────────────────


    // notice Returns the latest ETH/USD price from Chainlink

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = i_priceFeed.latestRoundData();
        return price;
    }

    /**
     * @notice Calculates how many tokens to mint based on ETH sent
     * @param amountInETH Amount of ETH sent (in wei)
     * @return tokenAmount Number of tokens to mint
     */
    function amountToMint(uint256 amountInETH) public view returns (uint256) {
        // Convert Chainlink price from 8 decimals to 18
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer()) * 10 ** 10;

        // Convert ETH amount to USD
        uint256 ethAmountInUSD = amountInETH * ethUsd / 10 ** 18;

        // Calculate token amount based on fixed USD price
        return (ethAmountInUSD * 10 ** TOKEN_DECIMALS) / TOKEN_USD_PRICE;
    }

    // ─── Receive Function ───────────────────────────────────────────────

    /**
     * @notice Automatically mints tokens when ETH is sent to the contract
     */
    receive() external payable {
        if (msg.value == 0) {
            revert TokenShop__ZeroETHSent();
        }

        uint256 tokenAmount = amountToMint(msg.value);
        i_token.mint(msg.sender, tokenAmount);
    }

    // ─── Owner-Only Function ────────────────────────────────────────────

    /**
     * @notice Allows the contract owner to withdraw all ETH from the contract
     */
    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        if (!success) {
            revert TokenShop__CouldNotWithdraw();
        }
        emit BalanceWithdrawn();
    }
}
