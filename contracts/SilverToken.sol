//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@hardhat/console.sol";

import "@openzeppelin/contracts/ERC20/ERC20.sol";
import "@openzeppelin/contracts/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/ERC20/IERC20.sol";
import "@openzeppelin/contracts/ERC20/utils/ReentrancyGuard.sol";

contract SilverToken is ReentrancyGuard {
    ///@dev state variables

    ///@dev Struct for Token Info
    struct TOKEN {
        string name;
        string symbol;
        uint256 decimal;
        uint256 price;
        uint256 totalSupply;
        address tokenAddress;
    }

    ///@dev Struct for Distribution
    struct DISTRIBUTION {
        bool distributed;
        address distributor;
        uint256 timestamp;
    }

    ///@dev Struct for Refund
    struct REFUND {
        bool refunded;
        address refunder;
        uint256 timestamp;
    }

    ///@dev Struct for History
    struct HISTORY {
        address contributor;
        address investor;
        uint256 amount;
        uint256 timestamp;
    }

    ///@dev address of listing partner
    address public lister;

    ///@dev address of contract owner
    address public owner;

    ///@dev DAO address
    address public daoAddress;

    ///@dev FundRaised address after successful ICO;
    address public fundRaisedAddress;

    ///@dev ICO start time
    uint256 public startTime;

    ///@dev ICO end time
    uint256 public endTime;

    ///@dev softcap of ICO
    uint256 public softcap;

    ///@dev hardcap of ICO
    uint256 public hardcap;

    ///@dev projectURI data
    string public projectURI;

    ///@dev investors address
    address[] public investors;

    ///@dev contributors address;
    address[] public contributors;

    ///@dev investments of investors
    mapping(address => uint256) public investments;

    ///@dev contributions of contributors
    mapping(address => uint256) public contributions;

    ///@dev ERC20 Token
    IERC20 public immutable silverToken;

    ///@dev tokenInfo
    TOKEN public tokenInfo;
    
    ///@dev test if funds are distributed
    DISTRIBUTION public distribution;

    ///@dev test if funds are refunded
    REFUND public refund;

    ///@dev investment history
    HISTORY[] public history
}
