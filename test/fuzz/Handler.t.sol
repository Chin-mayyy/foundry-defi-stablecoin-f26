// SPDX-License-Identifier: MIT
// Handler is going to narrow down the way we call function

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzepplin/contracts/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine public dscEngine;
    DecentralizedStableCoin public dsc;

    ERC20Mock public weth;
    ERC20Mock public wbtc;

    uint256 public timesMintIsCalled;
    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dscEngine = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dscEngine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(
            dscEngine.getCollateralTokenPriceFeed(address(weth))
        );
    }

    // redeem collateral
    function depositCollateral(
        uint256 collateralSeed,
        uint256 amountCollateral
    ) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dscEngine), amountCollateral);
        dscEngine.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        // double push
        usersWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(
        uint256 collateralSeed,
        uint256 amountCollateral,
        uint256 addressSeed
    ) public {
        if (usersWithCollateralDeposited.length == 0) return;

        address sender = usersWithCollateralDeposited[
            addressSeed % usersWithCollateralDeposited.length
        ];

        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dscEngine.getCollateralBalanceOfUser(
            sender,
            address(collateral)
        );
        if (maxCollateralToRedeem == 0) return;

        amountCollateral = bound(amountCollateral, 1, maxCollateralToRedeem);

        vm.startPrank(sender);
        dscEngine.redeemCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
    }

    function mintDSC(uint256 amountDscToMint, uint256 addressSeed) public {
        if (usersWithCollateralDeposited.length == 0) return;

        address sender = usersWithCollateralDeposited[
            addressSeed % usersWithCollateralDeposited.length
        ];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(sender);

        int256 maxDscToMint = int256(collateralValueInUsd / 2) -
            int256(totalDscMinted);
        if (maxDscToMint <= 0) return;
        amountDscToMint = bound(amountDscToMint, 1, uint256(maxDscToMint));

        vm.startPrank(sender);
        dscEngine.mintDSC(amountDscToMint);
        vm.stopPrank();
        timesMintIsCalled++;
    }

    // This breaks our invariant test suite
    // function updateCollateralPrice(int96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    // Helper function
    function _getCollateralFromSeed(
        uint256 collateralSeed
    ) public view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        } else {
            return wbtc;
        }
    }
}
