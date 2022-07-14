// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    address public owner;

    
    constructor() ERC20("HAHA", "WOW") {
        owner = msg.sender;
        _mint(address(this), 500 * 10**decimals());
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    function Mint(uint256 value) public onlyOwner{
        _mint(address(this), value);
    }

    function MintTo(address to, uint256 value) public onlyOwner{
        _mint(address(this), value);
        Token(address(this)).transfer(to, value);
    }

    function Withdraw(uint256 value) public onlyOwner{
        Token(address(this)).transfer(msg.sender, value);
    }

    function WithdrawTo(address to, uint256 value) public onlyOwner{
        Token(address(this)).transfer(to, value);
    }

    function Burn(uint256 value) public onlyOwner{
        _burn(msg.sender, value);
    }
}
