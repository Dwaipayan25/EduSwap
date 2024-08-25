// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ConcentratedLiquidityDEX {
    struct Position {
        uint128 liquidity;
        uint256 lowerTick;
        uint256 upperTick;
        uint256 feeGrowthInsideLast; // Tracks the fee growth at the last interaction
    }

    struct Ticks {
        int256 liquidityGross;
        int256 liquidityNet;
    }

    struct Pool {
        int256[] liquidityArray0;
        int256[] liquidityArray1;
        mapping(uint256 => Ticks) ticks0; // Map from tick to liquidity for token0
        mapping(uint256 => Ticks) ticks1; // Map from tick to liquidity for token1
        mapping(address => Position) positions; // Map from address to positions
        uint256 totalLiquidity0;
        uint256 totalLiquidity1;
        uint256 feeGrowthGlobal0; // Tracks the fee growth globally for token0
        uint256 feeGrowthGlobal1; // Tracks the fee growth globally for token1
        address token0;
        address token1;
    }

    mapping(bytes32 => Pool) public pools;
    uint256 public constant ARRAY_SIZE = 100001; // Size of the array

    uint256 public feePercent = 3000; // 0.3% fee

    function createPool(address token0, address token1) external returns (bytes32 poolId) {
        require(token0 != token1, "Identical tokens");
        poolId = keccak256(abi.encodePacked(token0, token1));
        pools[poolId].liquidityArray0 = new int256[](ARRAY_SIZE);
        pools[poolId].liquidityArray1 = new int256[](ARRAY_SIZE);
        pools[poolId].token0 = token0;
        pools[poolId].token1 = token1;
    }

    function addLiquidity(bytes32 poolId, uint256 tick1, uint256 tick2, uint128 amount, bool isToken0) external {
        require(tick1 >= 0 && tick2 >= 0, "Ticks must be non-negative");
        require(tick1 < tick2, "Invalid ticks");

        Pool storage pool = pools[poolId];
        uint256 range = tick2 - tick1 + 1;
        require(range > 0, "Invalid Range");
        uint256 amountPerTick = (amount + range - 1) / range;

        if (isToken0) {
            pool.ticks0[tick1].liquidityGross += int256(amountPerTick);
            pool.ticks0[tick2 + 1].liquidityGross -= int256(amountPerTick);
            pool.totalLiquidity0 += amount;
            pool.liquidityArray0[tick1] += int256(amountPerTick);
            if (tick2 + 1 < ARRAY_SIZE) {
                pool.liquidityArray0[tick2 + 1] -= int256(amountPerTick);
            }
        } else {
            pool.ticks1[tick1].liquidityGross += int256(amountPerTick);
            pool.ticks1[tick2 + 1].liquidityGross -= int256(amountPerTick);
            pool.totalLiquidity1 += amount;
            pool.liquidityArray1[tick1] += int256(amountPerTick);
            if (tick2 + 1 < ARRAY_SIZE) {
                pool.liquidityArray1[tick2 + 1] -= int256(amountPerTick);
            }
        }

        Position storage position = pool.positions[msg.sender];
        position.liquidity += amount;
        position.lowerTick = tick1;
        position.upperTick = tick2;
        position.feeGrowthInsideLast = isToken0 ? pool.feeGrowthGlobal0 : pool.feeGrowthGlobal1;

        IERC20(isToken0 ? pool.token0 : pool.token1).transferFrom(msg.sender, address(this), amount);
    }

    function removeLiquidity(bytes32 poolId, uint128 amount, bool isToken0) external {
        Pool storage pool = pools[poolId];
        Position storage position = pool.positions[msg.sender];

        require(position.liquidity >= amount, "Insufficient liquidity");

        uint256 range = position.upperTick - position.lowerTick + 1;
        uint256 amountPerTick = amount / range;

        if (isToken0) {
            pool.ticks0[position.lowerTick].liquidityGross -= int256(amountPerTick);
            pool.ticks0[position.upperTick + 1].liquidityGross += int256(amountPerTick);
            pool.totalLiquidity0 -= amount;
            pool.liquidityArray0[position.lowerTick] -= int256(amountPerTick);
            if (position.upperTick + 1 < ARRAY_SIZE) {
                pool.liquidityArray0[position.upperTick + 1] += int256(amountPerTick);
            }
        } else {
            pool.ticks1[position.lowerTick].liquidityGross -= int256(amountPerTick);
            pool.ticks1[position.upperTick + 1].liquidityGross += int256(amountPerTick);
            pool.totalLiquidity1 -= amount;
            pool.liquidityArray1[position.lowerTick] -= int256(amountPerTick);
            if (position.upperTick + 1 < ARRAY_SIZE) {
                pool.liquidityArray1[position.upperTick + 1] += int256(amountPerTick);
            }
        }

        position.liquidity -= amount;

        IERC20(isToken0 ? pool.token0 : pool.token1).transfer(msg.sender, amount);
    }

    function swap(bytes32 poolId, uint256 amountIn, bool zeroForOne) external {
        Pool storage pool = pools[poolId];
        address tokenIn = zeroForOne ? pool.token0 : pool.token1;
        address tokenOut = zeroForOne ? pool.token1 : pool.token0;

        uint256 fee = (amountIn * feePercent) / 1e6;
        uint256 amountInAfterFee = amountIn - fee;

        uint256 liquidityIn = zeroForOne ? pool.totalLiquidity0 : pool.totalLiquidity1;
        uint256 liquidityOut = zeroForOne ? pool.totalLiquidity1 : pool.totalLiquidity0;

        require(liquidityIn > 0 && liquidityOut > 0, "Insufficient liquidity");

        uint256 amountOut = (amountInAfterFee * liquidityOut) / liquidityIn;

        if (zeroForOne) {
            pool.feeGrowthGlobal0 += fee / pool.totalLiquidity0;
        } else {
            pool.feeGrowthGlobal1 += fee / pool.totalLiquidity1;
        }

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);
    }

    function collectFees(bytes32 poolId) external {
        Pool storage pool = pools[poolId];
        Position storage position = pool.positions[msg.sender];

        uint256 feeShare0 = (position.liquidity * pool.feeGrowthGlobal0) / pool.totalLiquidity0;
        uint256 feeShare1 = (position.liquidity * pool.feeGrowthGlobal1) / pool.totalLiquidity1;

        position.feeGrowthInsideLast = pool.feeGrowthGlobal0;
        IERC20(pool.token0).transfer(msg.sender, feeShare0);
        IERC20(pool.token1).transfer(msg.sender, feeShare1);
    }

    function getLiquidityConcentration(bytes32 poolId, bool isToken0) external view returns (int256[] memory concentrations) {
        Pool storage pool = pools[poolId];
        return isToken0 ? pool.liquidityArray0 : pool.liquidityArray1;
    }

    function getPool(bytes32 poolId) external view returns (
        uint256 totalLiquidity0,
        uint256 totalLiquidity1,
        uint256 feeGrowthGlobal0, // Tracks the fee growth globally for token0
        uint256 feeGrowthGlobal1, // Tracks the fee growth globally for token1
        address token0,
        address token1
    ) {
        return (pools[poolId].totalLiquidity0, pools[poolId].totalLiquidity1, pools[poolId].feeGrowthGlobal0, pools[poolId].feeGrowthGlobal1, pools[poolId].token0, pools[poolId].token1);
    }
}

// 0x97ABC1e9c0d8e95d402343fE670010e2d6Ae1948

// 0x4813c9483c877a6f328bB43eC9793A828244A5E6