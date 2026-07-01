// //SPDX-License-Identifier: MIT

// // Have our invariants aka properties hold true all time

// // What are our invariants

// // 1. The total supply of the DSC should always be equal to the total value of the collateral

// // 2. Getter view functions should never revert <- evergreen invariant

// pragma solidity ^0.8.19;

// import {Test} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzepplin/contracts/token/ERC20/IERC20.sol";

// contract InvariantsTest is StdInvariant, Test {
//     DecentralizedStableCoin dsc;
//     DeployDSC deployer;
//     DSCEngine dsce;
//     HelperConfig config;
//     address weth;
//     address wbtc;

//     function setUp() public {
//         deployer = new DeployDSC();
//         (dsc, dsce, config) = deployer.run();
//         (, , weth, wbtc, ) = config.activeNetworkConfig();
//         targetContract(address(dsce));
//     }

//     function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//         // get the value of all the collateral in the protocol, compare with total debt(dsc)
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//         uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

//         uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
//         uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
//         uint256 totalCollateralValue = wethValue + wbtcValue;

//         assert(totalCollateralValue >= totalSupply);
//     }
// }
