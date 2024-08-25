import React, { useState, useEffect } from 'react';
import './Marketplace.css'; // Import the CSS file
import EduToken from "../../contracts/EduToken.json";
import { ethers } from 'ethers';

const Marketplace = ({ eduToken, eduMarketPlace, account }) => {
    const [listings, setListings] = useState([]);
    const [paymentToken, setPaymentToken] = useState(eduToken.address);
    const [tokenAddress, setTokenAddress] = useState('');
    const [amount, setAmount] = useState('');
    const [pricePerToken, setPricePerToken] = useState('');

    useEffect(() => {
        fetchListings();
    }, []);

    const fetchListings = async () => {
        try {
            const activeListings = await eduMarketPlace.getListings();
            console.log("Active Listings:", activeListings[0]);

            if (activeListings[0].active === false) {
                setListings([]);
                return;
            }

            const formattedListings = await Promise.all(
                activeListings.map(async (listing) => { 
                    const tokenName = await fetchTokenName(listing.token);
                    return {
                        listingId: listing.listingId,
                        token: listing.token,
                        shortToken: `${formatAddress(listing.token)} (${tokenName})`, // Add token name and short address here
                        amount: listing.amount.toString(),
                        pricePerToken: listing.pricePerToken.toString(),
                        seller: listing.seller,
                        active: listing.active
                    };
                })
            );
            // console.log("Listings:", formattedListings);
            setListings(formattedListings);
        } catch (error) {
            console.error("Error fetching listings:", error);
        }
    };

    const handleListToken = async () => {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const tokenContract = new ethers.Contract(tokenAddress, EduToken.abi, signer);

            await tokenContract.approve(eduMarketPlace.address, amount);
            await eduMarketPlace.listToken(tokenAddress, amount, pricePerToken);
            fetchListings(); // Refresh the listings after creating a new one
            setTokenAddress('');
            setAmount('');
            setPricePerToken('');
        } catch (error) {
            console.error("Error listing token:", error);
        }
    };

    const handlePurchase = async (tokenAddress, listingId, pricePerToken, amount) => {
        const totalCost = (pricePerToken * amount).toString();
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const tokenContract = new ethers.Contract(paymentToken, EduToken.abi, signer);
            await tokenContract.approve(eduMarketPlace.address, totalCost);
            await eduMarketPlace.purchaseToken(listingId, paymentToken, totalCost);
            fetchListings(); // Refresh the listings after purchase
        } catch (error) {
            console.error("Error purchasing token:", error);
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

    const handleCancel = async (listingId) => {
        try {
            await eduMarketPlace.cancelListing(listingId);
            fetchListings(); // Refresh the listings after cancellation
        } catch (error) {
            console.error("Error canceling listing:", error);
        }
    };

    const formatAddress = (address) => {
        return `${address.slice(0, 4)}...${address.slice(-4)}`;
    };

    return (
        <div className="marketplace-section">
            <h2>Marketplace</h2>
            
            <div className="token-listing-form">
                <h3>List a Token</h3>
                <input 
                    type="text" 
                    placeholder="Token Address" 
                    value={tokenAddress} 
                    onChange={(e) => setTokenAddress(e.target.value)} 
                />
                <input 
                    type="number" 
                    placeholder="Amount" 
                    value={amount} 
                    onChange={(e) => setAmount(e.target.value)} 
                />
                <input 
                    type="number" 
                    placeholder="Price per Token" 
                    value={pricePerToken} 
                    onChange={(e) => setPricePerToken(e.target.value)} 
                />
                <button onClick={handleListToken}>List Token</button>
            </div>
            
            <div className="listings-display">
                <h3>Active Listings</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Token</th>
                            <th>Amount</th>
                            <th>Price per Token</th>
                            <th>Seller</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {listings
                        .filter(listing => listing.active)
                        .map((listing) => (
                            <tr key={listing.listingId}>
                                <td>{listing.shortToken}</td>
                                <td>{listing.amount}</td>
                                <td>{listing.pricePerToken}</td>
                                <td>{listing.seller}</td>
                                <td>
                                    {listing.seller.toLowerCase() !== account.toLowerCase() ? (
                                        <button onClick={() => handlePurchase(listing.token, listing.listingId, listing.pricePerToken, listing.amount)}>Purchase</button>
                                    ) : (
                                        <button onClick={() => handleCancel(listing.listingId)}>Cancel</button>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Marketplace;
