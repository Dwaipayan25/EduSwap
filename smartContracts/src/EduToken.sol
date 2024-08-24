// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {SimpleERC20} from "./ERC20.sol";

contract EduToken is SimpleERC20{

    constructor(string memory name, string memory symbol, uint256 _initialSupply) 
    SimpleERC20(name,symbol,_initialSupply)
    {}

    function mint(uint256 amount)public{
        mint(msg.sender, amount);
    }
}