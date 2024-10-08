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
        mapping(uint256 => int256) liquidityConcentration0;
        mapping(uint256 => int256) liquidityConcentration1;
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
    bytes32[] public poolIds;

    uint256 public feePercent = 3000; // 0.3% fee
    uint256 counter = 0;

    function createPool(address token0, address token1) external returns (bytes32 poolId) {
        require(token0 != token1, "Identical tokens");
        poolId = keccak256(abi.encodePacked(token0, token1, counter));
        pools[poolId].token0 = token0;
        pools[poolId].token1 = token1;
        poolIds.push(poolId);
        counter++;
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
            pool.liquidityConcentration0[tick1] += int256(amountPerTick);
            pool.liquidityConcentration0[tick2 + 1] -= int256(amountPerTick);
        } else {
            pool.ticks1[tick1].liquidityGross += int256(amountPerTick);
            pool.ticks1[tick2 + 1].liquidityGross -= int256(amountPerTick);
            pool.totalLiquidity1 += amount;
            pool.liquidityConcentration1[tick1] += int256(amountPerTick);
            pool.liquidityConcentration1[tick2 + 1] -= int256(amountPerTick);
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
            pool.liquidityConcentration0[position.lowerTick] -= int256(amountPerTick);
            pool.liquidityConcentration0[position.upperTick + 1] += int256(amountPerTick);
        } else {
            pool.ticks1[position.lowerTick].liquidityGross -= int256(amountPerTick);
            pool.ticks1[position.upperTick + 1].liquidityGross += int256(amountPerTick);
            pool.totalLiquidity1 -= amount;
            pool.liquidityConcentration1[position.lowerTick] -= int256(amountPerTick);
            pool.liquidityConcentration1[position.upperTick + 1] += int256(amountPerTick);
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
            pool.totalLiquidity0 += amountIn;
            pool.totalLiquidity1 -= amountOut;
        } else {
            pool.feeGrowthGlobal1 += fee / pool.totalLiquidity1;
            pool.totalLiquidity1 += amountIn;
            pool.totalLiquidity0 -= amountOut;
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

    uint256 constant ARRAY_SIZE = 1000;
    function getLiquidityConcentration(bytes32 poolId, bool isToken0) external view returns (uint256[] memory ticks, int256[] memory concentrations) {
        Pool storage pool = pools[poolId];
        uint256 count = 0;
        uint256[] memory tempTicks = new uint256[](ARRAY_SIZE);
        int256[] memory tempConcentrations = new int256[](ARRAY_SIZE);

        for (uint256 i = 0; i < ARRAY_SIZE; i++) {
            int256 concentration = isToken0 ? pool.liquidityConcentration0[i] : pool.liquidityConcentration1[i];
            if (concentration != 0) {
                tempTicks[count] = i;
                tempConcentrations[count] = concentration;
                count++;
            }
        }

        ticks = new uint256[](count);
        concentrations = new int256[](count);

        for (uint256 i = 0; i < count; i++) {
            ticks[i] = tempTicks[i];
            concentrations[i] = tempConcentrations[i];
        }
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

    function getPoolIds() external view returns (bytes32[] memory) {
        return poolIds;
    }

    function getAllPools() external view returns (
        bytes32[] memory ids,
        address[] memory token0Addresses,
        address[] memory token1Addresses,
        uint256[] memory totalLiquidity0s,
        uint256[] memory totalLiquidity1s
    ) {
        uint256 length = poolIds.length;
        ids = new bytes32[](length);
        token0Addresses = new address[](length);
        token1Addresses = new address[](length);
        totalLiquidity0s = new uint256[](length);
        totalLiquidity1s = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            bytes32 poolId = poolIds[i];
            Pool storage pool = pools[poolId];

            ids[i] = poolId;
            token0Addresses[i] = pool.token0;
            token1Addresses[i] = pool.token1;
            totalLiquidity0s[i] = pool.totalLiquidity0;
            totalLiquidity1s[i] = pool.totalLiquidity1;
        }
    }
}

// 0x36CC7645Dfdf2707D55f96b235992B2Bd6265792
