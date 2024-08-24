"use client";

import { useState } from 'react';
import { ethers } from 'ethers'; // Import the entire ethers library
import Web3Modal from 'web3modal';

export default function WalletConnect() {
    const [address, setAddress] = useState(null);

    const connectWallet = async () => {
        try {
            const web3Modal = new Web3Modal();
            const instance = await web3Modal.connect();
            const provider = new ethers.providers.Web3Provider(instance); // Access Web3Provider from ethers
            const signer = provider.getSigner();
            const userAddress = await signer.getAddress();

            setAddress(userAddress);

            console.log('Connected address:', userAddress);
        } catch (error) {
            console.error('Error connecting wallet:', error);
        }
    };

    return (
        <div>
            <button onClick={connectWallet}>
                Connect Wallet
            </button>
            {address && (
                <p>Connected Address: {address}</p>
            )}
        </div>
    );
}
