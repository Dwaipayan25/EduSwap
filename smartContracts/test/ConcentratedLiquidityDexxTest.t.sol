// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ConcentratedLiquidityDexx.sol";
import "../src/EduToken.sol";
import "../src/IERC20.sol";

contract ConcentratedLiquidityDEXTest is Test {
    ConcentratedLiquidityDEX dex;
    EduToken token0;
    EduToken token1;
    address user1 = address(1);
    address user2 = address(2);
    bytes32 poolId;

    function setUp() public {
        dex = new ConcentratedLiquidityDEX();

        token0 = new EduToken("Token 0", "TK0", 1000000 ether);
        token1 = new EduToken("Token 1", "TK1", 1000000 ether);
        vm.stopPrank();

        poolId = dex.createPool(address(token0), address(token1));
    }

    function testGetPool() public {
        poolId = dex.createPool(address(token0), address(token1));
        poolId = dex.createPool(address(token0), address(token1));
        poolId = dex.createPool(address(token0), address(token1));

        bytes32[] memory poolIds = dex.getPoolIds();
        (bytes32[] memory ids, address[] memory token0Addresses, address[] memory token1Addresses, uint256[] memory totalLiquidity0s, uint256[] memory totalLiquidity1s) = dex.getAllPools();

        assertEq(poolIds.length, 4); // Ensure all pools were created
        assertEq(ids.length, 4);     // Ensure all pools were retrieved
        assertEq(token0Addresses[0], address(token0));
        assertEq(token1Addresses[0], address(token1));
    }

    function testCreatePool() public {
        (
            uint256 totalLiquidity0,
            uint256 totalLiquidity1,
            uint256 feeGrowthGlobal0, // Tracks the fee growth globally for token0
            uint256 feeGrowthGlobal1, // Tracks the fee growth globally for token1
            address token00,
            address token11
        ) = dex.getPool(poolId);
        assertEq(token00, address(token0));
        assertEq(token11, address(token1));
    }

    function testCreate2Pools() public {
        vm.startPrank(user1);
        bytes32 poolId1 = dex.createPool(address(token0), address(token1));
        bytes32 poolId2 = dex.createPool(address(token0), address(token1));
        vm.stopPrank();
    }

    function testAddLiquidityToken0() public {
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 100 ether);
        dex.addLiquidity(poolId, 100, 200, 100, true);
        vm.stopPrank();

        (uint256[] memory ticks, int256[] memory concentrations) = dex.getLiquidityConcentration(poolId, true);
        assertEq(concentrations[0], 1); // Checking if liquidity concentration is correctly set
        assertEq(ticks[0], 100);
    }

    function testAddLiquidityToken1() public {
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token1.approve(address(dex), 100);
        dex.addLiquidity(poolId, 100, 200, 100, false);
        vm.stopPrank();

        (uint256[] memory ticks, int256[] memory concentrations) = dex.getLiquidityConcentration(poolId, false);
        assertEq(concentrations[0], 1); // Checking if liquidity concentration is correctly set
        assertEq(ticks[0], 100);
    }

    function testRemoveLiquidityToken0() public {
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 100);
        dex.addLiquidity(poolId, 100, 200, 100, true);
        dex.removeLiquidity(poolId, 100, true);
        vm.stopPrank();

        (uint256[] memory ticks, int256[] memory concentrations) = dex.getLiquidityConcentration(poolId, true);
        // assertEq(concentrations.length, 0); // Ensure liquidity concentration is removed
    }

    function testRemoveLiquidityToken1() public {
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token1.approve(address(dex), 100);
        dex.addLiquidity(poolId, 100, 200, 100, false);
        dex.removeLiquidity(poolId, 100, false);
        vm.stopPrank();

        (uint256[] memory ticks, int256[] memory concentrations) = dex.getLiquidityConcentration(poolId, false);
        // assertEq(concentrations.length, 0); // Ensure liquidity concentration is removed
    }

    function testSwapToken0ForToken1() public {
        // Add liquidity
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 200);
        token1.approve(address(dex), 200);
        dex.addLiquidity(poolId, 100, 200, 100, true);
        dex.addLiquidity(poolId, 100, 200, 100, false);
        vm.stopPrank();

        // Swap
        vm.startPrank(user2);
        token0.mint(500 ether);
        token0.approve(address(dex), 100);
        dex.swap(poolId, 50, true);
        vm.stopPrank();

        // Check balances after swap
        assertEq(token1.balanceOf(user2), 50); // Assuming a 1:2 price for simplicity
    }

    function testSwapToken1ForToken0() public {
        // Add liquidity
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 200);
        token1.approve(address(dex), 200);
        dex.addLiquidity(poolId, 100, 200, 100, true);
        dex.addLiquidity(poolId, 100, 200, 100, false);
        vm.stopPrank();

        // Swap
        vm.startPrank(user2);
        token1.mint(500 ether);
        token1.approve(address(dex), 100);
        dex.swap(poolId, 50, false); // token1: 500-50=450, token0: 500+50=550
        vm.stopPrank();

        // Check balances after swap
        assertEq(token1.balanceOf(user2), 499999999999999999950); // Assuming a 1:2 price for simplicity
    }

    function testCollectFees() public {
        // Add liquidity
        vm.startPrank(user1);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 200);
        token1.approve(address(dex), 200);
        dex.addLiquidity(poolId, 100, 200, 100, true);
        dex.addLiquidity(poolId, 100, 200, 100, false);
        vm.stopPrank();

        // Perform swap
        vm.startPrank(user2);
        token0.mint(500 ether);
        token1.mint(500 ether);
        token0.approve(address(dex), 50);
        dex.swap(poolId, 50, true);
        vm.stopPrank();

        // Collect fees
        vm.startPrank(user1);
        dex.collectFees(poolId);
        vm.stopPrank();

        // Check if fees have been collected
        assertGt(token0.balanceOf(user1), 0);
        assertGt(token1.balanceOf(user1), 0);
    }
}
