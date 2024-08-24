// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract SimpleERC20 {
    // Token properties
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Mapping from account addresses to current balance.
    mapping(address => uint256) private balances;

    // Mapping from account addresses to a mapping of spender addresses to an allowance amount.
    mapping(address => mapping(address => uint256)) private allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor to set the token name, symbol, and initial supply
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Function to get the balance of a given address
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Function to transfer tokens to a specified address
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Function to approve a spender to spend a certain amount of tokens
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Approve to the zero address");

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to get the current allowance for a spender
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Function for the spender to transfer tokens on behalf of the owner
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // Function to mint new tokens (only accessible by the contract owner)
    function mint(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Mint to the zero address");

        totalSupply += amount;
        balances[to] += amount;

        emit Transfer(address(0), to, amount);
        return true;
    }

    // Function to burn tokens
    function burn(uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        totalSupply -= amount;
        balances[msg.sender] -= amount;

        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
