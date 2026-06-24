// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

import {ERC20, ERC20Burnable} from "@openzepplin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzepplin/contracts/access/Ownable.sol";

/*
 * @title DecentralizedStableCoin
 * @author Chinmay Anand
 * Collateral: Exogenous
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed DSCengine. This contract is the ERC20 implementation of the stablecoin.
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DSC_AmountMustBePositive();
    error DSC_BalanceInsufficient();
    error DSC_NotZeroAddress();

    constructor() ERC20("DecentralizedStableCoin", "DSC") {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DSC_AmountMustBePositive();
        }
        if (balance < _amount) {
            revert DSC_BalanceInsufficient();
        }

        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DSC_NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DSC_AmountMustBePositive();
        }
        _mint(_to, _amount);
        return true;
    }
}
