pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    // All code goes here....
    string public name = "Dapp Token Farm";
    address public owner;
    DappToken public dappToken;
    DaiToken public daiToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    // Staking tokens(Deposit)
    function stakeTokens(uint256 _amount) public {
        //Require amount greater than 0;
        require(_amount > 0, "amount cannot be 0");

        //Transfer Mock DAI Token to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        //update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        //add users to stakers array *only* if they haven't staked already
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Unstaking tokens(Withdraw)
    function unstakeTokens() public {
        //fetch staking balance
        uint256 balance = stakingBalance[msg.sender];

        //require amount greater than 0
        require(balance > 0, "staking balance can not be 0");

        // Transfer Mock DAI Token to the user
        daiToken.transfer(msg.sender, balance);

        //reset staking balance
        stakingBalance[msg.sender] = 0;

        //Update Staking status
        isStaking[msg.sender] = false;
    }

    //Issuing tokens
    function issueTokens() public {
        //Only owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        //issue tokens to all stakers
        for (uint256 item = 0; item < stakers.length; item++) {
            address recipient = stakers[item];
            uint256 balance = stakingBalance[recipient];

            if (balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }
}
