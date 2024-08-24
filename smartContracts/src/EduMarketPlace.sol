// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {IERC20} from "./IERC20.sol";
import {Ownable} from "./Ownable.sol";

contract EduMarketplace is Ownable {
    struct Listing {
        address seller;
        address token;
        uint256 amount;
        uint256 pricePerToken; // Price per token in another token (e.g., a stablecoin)
        bool active;
    }

    // Mapping from listing ID to Listing details
    mapping(uint256 => Listing) public listings;
    uint256 public listingCounter;

    event Listed(uint256 indexed listingId, address indexed seller, address indexed token, uint256 amount, uint256 pricePerToken);
    event Purchase(uint256 indexed listingId, address indexed buyer, address indexed token, uint256 amount, uint256 totalCost);
    event ListingCancelled(uint256 indexed listingId);

    // Constructor
    constructor() {
        listingCounter = 0;
    }

    // Function to list tokens for sale
    function listToken(address token, uint256 amount, uint256 pricePerToken) external {
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient token balance");
        require(IERC20(token).allowance(msg.sender, address(this)) >= amount, "Marketplace not approved to spend tokens");

        // Transfer tokens from seller to the marketplace contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Create a new listing
        listings[listingCounter] = Listing({
            seller: msg.sender,
            token: token,
            amount: amount,
            pricePerToken: pricePerToken,
            active: true
        });

        emit Listed(listingCounter, msg.sender, token, amount, pricePerToken);
        listingCounter++;
    }

    // Function to purchase tokens from a listing
    function purchaseToken(uint256 listingId, address paymentToken, uint256 paymentAmount) external {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(paymentAmount >= listing.pricePerToken * listing.amount, "Insufficient payment");

        // Transfer payment from buyer to seller
        IERC20(paymentToken).transferFrom(msg.sender, listing.seller, paymentAmount);

        // Transfer tokens from marketplace to buyer
        IERC20(listing.token).transfer(msg.sender, listing.amount);

        // Mark listing as inactive
        listing.active = false;

        emit Purchase(listingId, msg.sender, listing.token, listing.amount, paymentAmount);
    }

    // Function to cancel a listing
    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Only the seller can cancel the listing");
        require(listing.active, "Listing is not active");

        // Transfer tokens back to the seller
        IERC20(listing.token).transfer(listing.seller, listing.amount);

        // Mark listing as inactive
        listing.active = false;

        emit ListingCancelled(listingId);
    }

    // Function to withdraw any ERC20 tokens mistakenly sent to the contract
    function withdrawTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        IERC20(token).transfer(msg.sender, balance);
    }

    function getListings() external view returns (Listing[] memory) {
        Listing[] memory activeListings = new Listing[](listingCounter);
        uint256 activeListingCount = 0;

        for (uint256 i = 0; i < listingCounter; i++) {
            if (listings[i].active) {
                activeListings[activeListingCount] = listings[i];
                activeListingCount++;
            }
        }

        return activeListings;
    }
}

// 0x8a3c4f9e0E9E18D4f35Ec2aBB59d0837f0f2096F