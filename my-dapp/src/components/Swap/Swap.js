import React, { useState, useEffect } from 'react';
import './Swap.css'; // Import the CSS file
import { ethers } from 'ethers';
import EduToken from '../../contracts/EduToken.json';

const Swap = ({ dexContract, account }) => {
    const [poolIds, setPoolIds] = useState([]);
    const [selectedPool, setSelectedPool] = useState('');
    const [poolDetails, setPoolDetails] = useState(null);
    const [inputAmount, setInputAmount] = useState('');
    const [isToken0, setIsToken0] = useState(true);
    const [estimatedOutput, setEstimatedOutput] = useState('');
    const [token0Name, setToken0Name] = useState('Token 0');
    const [token1Name, setToken1Name] = useState('Token 1');
    const [poolInfo, setPoolInfo] = useState([]);

    useEffect(() => {
        fetchPoolIds();
    }, []);

    useEffect(() => {
        if (selectedPool) {
            fetchPoolDetails();
            calculateEstimatedOutput();
        }
    }, [selectedPool, isToken0, inputAmount]);

    const fetchPoolIds = async () => {
        try {
            const ids = await dexContract.getPoolIds();
            const pools = await Promise.all(
                ids.map(async (id) => {
                    const pool = await dexContract.getPool(id);
                    const token0Name = await fetchTokenName(pool.token0);
                    const token1Name = await fetchTokenName(pool.token1);
                    return {
                        id,
                        token0Name,
                        token1Name
                    };
                })
            );
            setPoolInfo(pools);
            setPoolIds(ids);
        } catch (error) {
            console.error('Error fetching pool IDs:', error);
        }
    };

    const fetchTokenName = async (tokenAddress) => {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const tokenContract = new ethers.Contract(tokenAddress, EduToken.abi, provider);
            const tokenName = await tokenContract.name();
            return tokenName;
        } catch (error) {
            console.error("Error fetching token name:", error);
            return "Unknown Token"; // Fallback if token name can't be fetched
        }
    };

    const fetchPoolDetails = async () => {
        try {
            const pool = await dexContract.getPool(selectedPool);
            const token0 = pool.token0;
            const token1 = pool.token1;

            const token0Name = await fetchTokenName(token0);
            const token1Name = await fetchTokenName(token1);

            setToken0Name(token0Name);
            setToken1Name(token1Name);

            setPoolDetails({
                totalLiquidity0: ethers.BigNumber.from(pool.totalLiquidity0),
                totalLiquidity1: ethers.BigNumber.from(pool.totalLiquidity1),
                feeGrowthGlobal0: pool.feeGrowthGlobal0.toString(),
                feeGrowthGlobal1: pool.feeGrowthGlobal1.toString(),
                token0,
                token1,
            });
        } catch (error) {
            console.error('Error fetching pool details:', error);
        }
    };

    const calculateEstimatedOutput = () => {
        if (!poolDetails || !inputAmount) return;

        const amountIn = ethers.BigNumber.from(ethers.utils.parseUnits(inputAmount, 18));
        const fee = amountIn.mul(3000).div(1000000); // 0.3% fee
        const amountInAfterFee = amountIn.sub(fee);

        const liquidityIn = isToken0 ? poolDetails.totalLiquidity0 : poolDetails.totalLiquidity1;
        const liquidityOut = isToken0 ? poolDetails.totalLiquidity1 : poolDetails.totalLiquidity0;

        if (liquidityIn.gt(0) && liquidityOut.gt(0)) {
            const amountOut = amountInAfterFee.mul(liquidityOut).div(liquidityIn);
            setEstimatedOutput(ethers.utils.formatUnits(amountOut, 18));
        } else {
            setEstimatedOutput('Insufficient liquidity');
        }
    };

    const handleSwap = async () => {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
    
            const tokenIn = isToken0 ? poolDetails.token0 : poolDetails.token1;
            const tokenOut = isToken0 ? poolDetails.token1 : poolDetails.token0;
    
            const tokenContract = new ethers.Contract(tokenIn, EduToken.abi, signer);
    
            const parsedAmount = inputAmount.toString();
    
            await tokenContract.approve(dexContract.address, parsedAmount);
    
            // Perform the swap
            await dexContract.swap(selectedPool, parsedAmount, isToken0);
    
            fetchPoolDetails(); // Refresh pool details after the swap
        } catch (error) {
            console.error('Error performing swap:', error);
        }
    };

    return (
        <div className="swap-section">
            <h2>Token Swap</h2>

            <div className="pool-selection">
                <h3>Select Pool</h3>
                <select value={selectedPool} onChange={(e) => setSelectedPool(e.target.value)}>
                    <option value="" disabled>Select a Pool</option>
                    {poolInfo.map((pool) => (
                        <option key={pool.id} value={pool.id}>
                            {pool.id} ({pool.token0Name} / {pool.token1Name})
                        </option>
                    ))}
                </select>
            </div>

            {poolDetails && (
                <div className="pool-details">
                    <h3>Pool Information</h3>
                    <p><strong>{token0Name} Address:</strong> {poolDetails.token0}</p>
                    <p><strong>Total Liquidity ({token0Name}):</strong> {poolDetails.totalLiquidity0.toString()}</p>
                    <p><strong>{token1Name} Address:</strong> {poolDetails.token1}</p>
                    <p><strong>Total Liquidity ({token1Name}):</strong> {poolDetails.totalLiquidity1.toString()}</p>
                </div>
            )}

            <div className="token-swap-form">
                <h3>Swap Tokens</h3>
                <select value={isToken0} onChange={(e) => setIsToken0(e.target.value === 'true')}>
                    <option value="true">{token0Name} to {token1Name}</option>
                    <option value="false">{token1Name} to {token0Name}</option>
                </select>
                <input
                    type="number"
                    placeholder="Input Amount"
                    value={inputAmount}
                    onChange={(e) => setInputAmount(e.target.value)}
                />
                <p><strong>Estimated Output:</strong> {estimatedOutput}</p>
                <button onClick={handleSwap}>Swap</button>
            </div>
        </div>
    );
};

export default Swap;