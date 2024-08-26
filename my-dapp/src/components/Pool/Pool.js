import React, { useState, useEffect } from 'react';
import './Pool.css'; // Import the CSS file
import { ethers } from 'ethers';
import EduToken from '../../contracts/EduToken.json';
import { Line } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, LineElement, PointElement, Title, Tooltip, Legend } from 'chart.js';

// Register components
ChartJS.register(CategoryScale, LinearScale, LineElement, PointElement, Title, Tooltip, Legend);

const Pool = ({ dexContract, eduToken, account }) => {
    const [poolIds, setPoolIds] = useState([]);
    const [selectedPool, setSelectedPool] = useState('');
    const [poolDetails, setPoolDetails] = useState(null);
    const [token0, setToken0] = useState('');
    const [token1, setToken1] = useState('');
    const [tick1, setTick1] = useState('');
    const [tick2, setTick2] = useState('');
    const [amount, setAmount] = useState('');
    const [isToken0, setIsToken0] = useState(true);
    const [concentrationsData, setConcentrationsData] = useState({ labels: [], data: [] });

    useEffect(() => {
        fetchPoolIds();
    }, []);

    useEffect(() => {
        if (selectedPool) {
            fetchPoolDetails();
            fetchLiquidityConcentration();
        }
    }, [selectedPool, isToken0]);

    const fetchPoolIds = async () => {
        try {
            const ids = await dexContract.getPoolIds();
            setPoolIds(ids);
        } catch (error) {
            console.error("Error fetching pool IDs:", error);
        }
    };

    const fetchPoolDetails = async () => {
        try {
            const pool = await dexContract.getPool(selectedPool);
            setPoolDetails({
                totalLiquidity0: pool.totalLiquidity0.toString(),
                totalLiquidity1: pool.totalLiquidity1.toString(),
                feeGrowthGlobal0: pool.feeGrowthGlobal0.toString(),
                feeGrowthGlobal1: pool.feeGrowthGlobal1.toString(),
                token0: pool.token0,
                token1: pool.token1,
            });
        } catch (error) {
            console.error("Error fetching pool details:", error);
        }
    };

    const handleCreatePool = async () => {
        try {
            await dexContract.createPool(token0, token1);
            fetchPoolIds(); // Refresh pool list after creation
            setToken0('');
            setToken1('');
        } catch (error) {
            console.error("Error creating pool:", error);
        }
    };

    const handleAddLiquidity = async () => {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
    
            let tokenContract = new ethers.Contract(isToken0 ? poolDetails.token0 : poolDetails.token1, EduToken.abi, signer);
    
            const parsedAmount = amount.toString();
    
            await tokenContract.approve(dexContract.address, parsedAmount);
    
            await dexContract.addLiquidity(selectedPool, tick1, tick2, parsedAmount, isToken0);
            fetchLiquidityConcentration(); // Refresh after adding liquidity
        } catch (error) {
            console.error("Error adding liquidity:", error);
        }
    };

    const handleRemoveLiquidity = async () => {
        try {
            await dexContract.removeLiquidity(selectedPool, amount.toString(), isToken0);
            fetchLiquidityConcentration(); // Refresh after removing liquidity
        } catch (error) {
            console.error("Error removing liquidity:", error);
        }
    };

    const handleCollectFees = async () => {
        try {
            await dexContract.collectFees(selectedPool);
        } catch (error) {
            console.error("Error collecting fees:", error);
        }
    };

    const fetchLiquidityConcentration = async () => {
        try {
            const [ticks, concentrations] = await dexContract.getLiquidityConcentration(selectedPool, isToken0);

            const arraySize = 1000;
            let A = new Array(arraySize).fill(0);

            ticks.forEach((tick, index) => {
                A[tick] += parseInt(concentrations[index]);
            });

            for (let i = 1; i < arraySize; i++) {
                A[i] += A[i - 1];
            }

            const labels = Array.from({ length: arraySize }, (_, i) => i);
            setConcentrationsData({
                labels,
                data: A,
            });

        } catch (error) {
            console.error("Error fetching liquidity concentration:", error);
        }
    };

    return (
        <div className="pool-section">
            <h2>Liquidity Pool Management</h2>

            <div className="pool-creation-form">
                <h3>Create Pool</h3>
                <input
                    type="text"
                    placeholder="Token 0 Address"
                    value={token0}
                    onChange={(e) => setToken0(e.target.value)}
                />
                <input
                    type="text"
                    placeholder="Token 1 Address"
                    value={token1}
                    onChange={(e) => setToken1(e.target.value)}
                />
                <button onClick={handleCreatePool}>Create Pool</button>
            </div>

            <div className="pool-selection">
                <h3>Select Pool</h3>
                <select value={selectedPool} onChange={(e) => setSelectedPool(e.target.value)}>
                    <option value="" disabled>Select a Pool</option>
                    {poolIds.map((id) => (
                        <option key={id} value={id}>
                            {id}
                        </option>
                    ))}
                </select>
            </div>

            {poolDetails && (
                <div className="pool-details">
                    <h3>Pool Details</h3>
                    <p><strong>Token 0:</strong> {poolDetails.token0}</p>
                    <p><strong>Total Liquidity (Token 0):</strong> {poolDetails.totalLiquidity0}</p>
                    <p><strong>Token 1:</strong> {poolDetails.token1}</p>
                    <p><strong>Total Liquidity (Token 1):</strong> {poolDetails.totalLiquidity1}</p>
                    <p><strong>Fee Growth Global (Token 0):</strong> {poolDetails.feeGrowthGlobal0}</p>
                    <p><strong>Fee Growth Global (Token 1):</strong> {poolDetails.feeGrowthGlobal1}</p>
                </div>
            )}

            <div className="liquidity-management">
                <h3>Add/Remove Liquidity</h3>
                <input
                    type="text"
                    placeholder="Tick Lower Bound"
                    value={tick1}
                    onChange={(e) => setTick1(e.target.value)}
                />
                <input
                    type="text"
                    placeholder="Tick Upper Bound"
                    value={tick2}
                    onChange={(e) => setTick2(e.target.value)}
                />
                <input
                    type="number"
                    placeholder="Amount"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                />
                <select value={isToken0} onChange={(e) => setIsToken0(e.target.value === 'true')}>
                    <option value="true">Token 0</option>
                    <option value="false">Token 1</option>
                </select>
                <button onClick={handleAddLiquidity}>Add Liquidity</button>
                <button onClick={handleRemoveLiquidity}>Remove Liquidity</button>
            </div>

            <div className="fees-collection">
                <button onClick={handleCollectFees}>Collect Fees</button>
            </div>

            <div className="liquidity-concentration">
                <h3>Liquidity Concentration</h3>
                {concentrationsData.labels.length > 0 ? (
                    <Line
                        data={{
                            labels: concentrationsData.labels,
                            datasets: [
                                {
                                    label: 'Liquidity Concentration',
                                    data: concentrationsData.data,
                                    fill: false,
                                    backgroundColor: 'rgb(75, 192, 192)',
                                    borderColor: 'rgba(75, 192, 192, 0.2)',
                                },
                            ],
                        }}
                        options={{
                            scales: {
                                x: {
                                    type: 'linear',
                                    position: 'bottom',
                                },
                            },
                        }}
                    />
                ) : (
                    <p>No liquidity concentrations available.</p>
                )}
            </div>
        </div>
    );
};

export default Pool;
