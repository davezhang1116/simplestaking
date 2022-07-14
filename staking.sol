// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract Staking {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public owner;

    mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint) public balances;
    mapping(address => uint256) public stakeTime;

    uint256 public contractBalance;
    uint256 constant public yieldPerSecond = 250000000 ; // about 12.6% APY, Calculated by 1/yieldPerSecond*3600*24*365

    IERC20 public erc20Contract;

    event tokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);

    constructor(IERC20 _erc20_contract_address)  {
        owner = msg.sender;
        erc20Contract = _erc20_contract_address;
    }

    function stakeTokens(IERC20 token, uint256 amount) public {
        require(amount > 0, "value must be greater than 0");
        require(token == erc20Contract);
        require(amount <= token.balanceOf(msg.sender), "Not enough tokens in your wallet");
        if (balances[msg.sender] > 0){
            token.safeTransfer(msg.sender, balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]));
            token.safeTransferFrom(msg.sender, address(this), balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]));
            token.safeTransferFrom(msg.sender, address(this), amount);
            balances[msg.sender] = balances[msg.sender].add(amount + (balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender])));
            stakeTime[msg.sender] = block.timestamp;
            emit tokensStaked(msg.sender, amount + (balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender])));
        }else{
            token.safeTransferFrom(msg.sender, address(this), amount);
            balances[msg.sender] = balances[msg.sender].add(amount);
            stakeTime[msg.sender] = block.timestamp;
            emit tokensStaked(msg.sender, amount);
        }
    }

    function unstakeTokens(IERC20 token, uint256 amount) public  {
        require(amount > 0, "value must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient staked balance");
        require(token == erc20Contract, "false erc20 token");
        alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);     
        token.safeTransfer(msg.sender, amount);
        token.safeTransfer(msg.sender, balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]));
        balances[msg.sender] = balances[msg.sender] - amount;
        stakeTime[msg.sender] = block.timestamp;
        emit TokensUnstaked(msg.sender, amount);

    }

    function withdrawAll(IERC20 token) public  {
        require(balances[msg.sender] > 0, "value must be greater than 0");
        require(token == erc20Contract, "false erc20 token");
        uint amount = balances[msg.sender];
        alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(balances[msg.sender]);
        token.safeTransfer(msg.sender, amount);
        token.safeTransfer(msg.sender, balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]));
        balances[msg.sender] = 0;
        stakeTime[msg.sender] = block.timestamp;
        emit TokensUnstaked(msg.sender, amount);
    }

    function claimRewards(IERC20 token) public  {
        require((balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender])) > 0, "claim must be greater than 0");
        token.safeTransfer(msg.sender,balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]));
        stakeTime[msg.sender] = block.timestamp;
    }

    function showRewards() public view returns(uint){
        return balances[msg.sender] / yieldPerSecond * (block.timestamp - stakeTime[msg.sender]);
    }

}