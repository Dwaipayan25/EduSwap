// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract SimpleERC20Test is Test {
    SimpleERC20 token;

    address owner = address(0x1);
    address addr1 = address(0x2);
    address addr2 = address(0x3);

    function setUp() public {
        // Deploy the SimpleERC20 contract with an initial supply of 1000 tokens
        vm.startPrank(owner);
        token = new SimpleERC20("Simple Token", "STK", 1000);
        vm.stopPrank();
    }

    function testInitialSupply() public {
        // Check that the total supply is correctly set
        assertEq(token.totalSupply(), 1000 * 10**18);
        assertEq(token.balanceOf(owner), 1000 * 10**18);
    }

    function testTransfer() public {
        // Test transferring tokens from the owner to addr1
        vm.startPrank(owner);
        bool success = token.transfer(addr1, 100 * 10**18);
        assertTrue(success);
        assertEq(token.balanceOf(owner), 900 * 10**18);
        assertEq(token.balanceOf(addr1), 100 * 10**18);
        vm.stopPrank();
    }

    function testApproveAndTransferFrom() public {
        // Test approving and transferring tokens using transferFrom
        vm.startPrank(owner);
        bool successApprove = token.approve(addr1, 200 * 10**18);
        assertTrue(successApprove);
        assertEq(token.allowance(owner, addr1), 200 * 10**18);
        vm.stopPrank();

        vm.startPrank(addr1);
        bool successTransferFrom = token.transferFrom(owner, addr2, 150 * 10**18);
        assertTrue(successTransferFrom);
        assertEq(token.balanceOf(owner), 850 * 10**18);
        assertEq(token.balanceOf(addr2), 150 * 10**18);
        assertEq(token.allowance(owner, addr1), 50 * 10**18);
        vm.stopPrank();
    }

    function testMint() public {
        // Test minting new tokens
        vm.startPrank(owner);
        bool success = token.mint(owner, 500 * 10**18);
        assertTrue(success);
        assertEq(token.totalSupply(), 1500 * 10**18);
        assertEq(token.balanceOf(owner), 1500 * 10**18);
        vm.stopPrank();
    }

    function testBurn() public {
        // Test burning tokens
        vm.startPrank(owner);
        bool success = token.burn(100 * 10**18);
        assertTrue(success);
        assertEq(token.totalSupply(), 900 * 10**18);
        assertEq(token.balanceOf(owner), 900 * 10**18);
        vm.stopPrank();
    }

    function testTransferFailInsufficientBalance() public {
        // Test that transfer fails when there is insufficient balance
        vm.startPrank(addr1);
        vm.expectRevert("Insufficient balance");
        token.transfer(addr2, 10 * 10**18);
        vm.stopPrank();
    }

    function testApproveFail() public {
        // Test that approve fails when trying to approve to the zero address
        vm.startPrank(owner);
        vm.expectRevert("Approve to the zero address");
        token.approve(address(0), 100 * 10**18);
        vm.stopPrank();
    }

    function testMintFailZeroAddress() public {
        // Test that mint fails when minting to the zero address
        vm.startPrank(owner);
        vm.expectRevert("Mint to the zero address");
        token.mint(address(0), 100 * 10**18);
        vm.stopPrank();
    }

    function testBurnFailInsufficientBalance() public {
        // Test that burn fails when there is insufficient balance
        vm.startPrank(addr1);
        vm.expectRevert("Insufficient balance");
        token.burn(10 * 10**18);
        vm.stopPrank();
    }
}
