// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/EduMarketplace.sol";
import "../src/EduToken.sol";

contract EduMarketplaceTest is Test {
    EduMarketplace marketplace;
    EduToken tokenForSale;
    EduToken paymentToken;
    address user1 = address(1);
    address user2 = address(2);

    function setUp() public {
        marketplace = new EduMarketplace();

        // Deploy test tokens
        tokenForSale = new EduToken("TokenForSale", "TFS", 1000);
        paymentToken = new EduToken("PaymentToken", "PAY", 1000);

        // Mint tokens to user1 and user2
        tokenForSale.mint(500);
        paymentToken.mint(500);
        tokenForSale.transfer(user1, 200);
        paymentToken.transfer(user2, 200);
    }

    function testListToken() public {
        vm.startPrank(user1);
        tokenForSale.approve(address(marketplace), 100);
        marketplace.listToken(address(tokenForSale), 100, 2);
        vm.stopPrank();

        // Retrieve listing details
        (
            uint256 listingId,
            address seller,
            address token,
            uint256 amount,
            uint256 pricePerToken,
            bool active
        ) = marketplace.listings(0);

        // Check the listing details
        assertEq(seller, user1);
        assertEq(token, address(tokenForSale));
        assertEq(amount, 100);
        assertEq(pricePerToken, 2);
        assertEq(active, true);
    }

    function testPurchaseToken() public {
        // List the token for sale
        vm.startPrank(user1);
        tokenForSale.approve(address(marketplace), 100);
        marketplace.listToken(address(tokenForSale), 100, 2);
        vm.stopPrank();

        // Purchase the token
        vm.startPrank(user2);
        paymentToken.approve(address(marketplace), 200);
        marketplace.purchaseToken(0, address(paymentToken), 200);
        vm.stopPrank();

        // Check that user2 received the tokens and the listing is inactive
        assertEq(tokenForSale.balanceOf(user2), 100);

        // Retrieve listing details
        (
            uint256 listingId,
            address seller,
            address token,
            uint256 amount,
            uint256 pricePerToken,
            bool active
        ) = marketplace.listings(0);

        assertEq(active, false);
    }

    function testCancelListing() public {
        // List the token for sale
        vm.startPrank(user1);
        tokenForSale.approve(address(marketplace), 100);
        marketplace.listToken(address(tokenForSale), 100, 2);
        vm.stopPrank();

        // Cancel the listing
        vm.startPrank(user1);
        marketplace.cancelListing(0);
        vm.stopPrank();

        // Check that the tokens were returned to user1 and the listing is inactive
        assertEq(tokenForSale.balanceOf(user1), 200);

        // Retrieve listing details
        (
            uint256 listingId,
            address seller,
            address token,
            uint256 amount,
            uint256 pricePerToken,
            bool active
        ) = marketplace.listings(0);

        assertEq(active, false);
    }

    function testWithdrawTokens() public {
        // Transfer some tokens to the contract
        paymentToken.transfer(address(marketplace), 100);

        uint256 balanceBefore = paymentToken.balanceOf(address(this));

        // Withdraw the tokens as the owner
        marketplace.withdrawTokens(address(paymentToken));

        // Check that the owner received the tokens
        uint256 balanceAfter = paymentToken.balanceOf(address(this));

        assertEq(balanceAfter, balanceBefore + 100);
    }

    function testGetListings() public {
        vm.startPrank(user1);
        tokenForSale.approve(address(marketplace), 150); // Adjust approval to cover all listings
        marketplace.listToken(address(tokenForSale), 100, 2);
        marketplace.listToken(address(tokenForSale), 50, 3);
        vm.stopPrank();

        EduMarketplace.Listing[] memory activeListings = marketplace.getListings();

        assertEq(activeListings.length, 2);
        assertEq(activeListings[0].amount, 100);
        assertEq(activeListings[1].amount, 50);
    }

}
