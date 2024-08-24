// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Ownable {
    // The address of the owner
    address private _owner;

    // Event emitted when ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    // Constructor that sets the initial owner to the deployer of the contract
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Internal function that transfers ownership to a new account (`newOwner`).
     * @param newOwner The address of the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Renounces ownership of the contract.
     * Leaves the contract without an owner, thereby disabling `onlyOwner` functions.
     * Can only be called by the current owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }
}
