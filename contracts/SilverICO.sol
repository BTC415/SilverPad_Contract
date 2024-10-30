//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SilverICO is Ownable {
    // Address of the SilverDoge token
    address public silverDogeToken;

    // Presale parameters
    uint256 public presaleRate; // Tokens per BNB
    uint256 public presaleCap; // Maximum BNB to be raised
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;

    // Mapping to track user contributions
    mapping(address => uint256) public contributions;

    // Events
    event Contribution(
        address indexed contributor,
        uint256 amount,
        uint256 tokensPurchased
    );

    // Constructor
    constructor(
        address _silverDogeToken,
        uint256 _presaleCap,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        address _owner
    ) Ownable(_owner) {
        silverDogeToken = _silverDogeToken;
        presaleCap = _presaleCap;
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;

        // Desired token price in BNB
        uint256 tokenPriceInBNB = 100000000; // 1 BNB = 100,000,000 tokens

        // Calculate presale rate
        presaleRate = 1e18 / tokenPriceInBNB;
    }

    // Function to participate in the presale
    function participate() external payable {
        require(block.timestamp >= presaleStartTime, "Presale has not started");
        require(block.timestamp <= presaleEndTime, "Presale has ended");
        require(msg.value > 0, "Must send BNB to participate");

        uint256 tokensPurchased = (msg.value) * (presaleRate);
        require(tokensPurchased > 0, "Insufficient BNB sent");

        // Check if the presale cap is reached
        require(
            getPresaleRaised() + msg.value <= presaleCap,
            "Presale cap reached"
        );

        // Transfer tokens to the contributor
        IERC20(silverDogeToken).transfer(msg.sender, tokensPurchased);

        // Update contribution mapping
        contributions[msg.sender] = contributions[msg.sender] + (msg.value);

        // Emit event
        emit Contribution(msg.sender, msg.value, tokensPurchased);
    }

    // Function to retrieve the current amount raised in BNB
    function getPresaleRaised() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to withdraw BNB from the contract (only for the owner)
    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
