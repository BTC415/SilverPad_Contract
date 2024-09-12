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

    enum ICOState {
      SUCCESS,
      FAILED,
      REACHEDSOFTCAP,
      REACHEDHARDCAP
    }

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

    ///@dev checks if listing partner's address is valid
    modifier notZeroListAddress(address lister_) {
      require(lister_ != address(0), "Invalid Address");
      _;
    }

    ///@dev checks if owner's address is valid
    modifier notZeroOwnerAddress(address owner_) {
      require(owner_ != address(0), "Invalid Address");
      _;
    }

    ///@dev checks if daoAddress is valid
    modifier notZeroDAOAddress(address daoAddress_) {
      require(daoAddress_ !=address(0), "Invalid Address");
      _;
    }

    ///@dev checks if fundsRaisedAddress is valid
    modifier notZeroFundsRaisedAdderss(address fundsRaisedAddress_) {
      require(fundsRaisedAddress_ != address(0), "Invalid Addresss");
      _;
    }

    ///@dev checks if totalSupply
    modifier notZeroTotalSuppy(uint256 totalSupply_) {
      require(totalSupply_ >0, "TotalSupply must be greater than 0");
      _;
    }

    ///@dev checks if token decimal
    modifier notZeroDecimal(uint256 decimal_) {
      require(decimal_ >0, "Token decimal must be greater than 0");
      _;
    }

    ///@dev Checks if cap setting valid
    modifier capSettingValid(uint256 softcap_, uint256 hardcap_) {
      require(softcap_ > 0, "Softcap should set greater than zero");
      require(hardcap_ > 0, "Hardcap should set greater than zero");
      require(hardcap_ > softcap_, "Hardcap should set greater than softcap");
      _;
    }

    ///@dev checks if ICO is still running
    modifier isICORunning(uint256 endTime_) {
      require(block.timestamp < endTime_, "ICO is still running");
      _;
    }

    ///@dev checks if total tokens can be able to reach hardcap
    modifier totalSupplyAbleToReachHardcap(uint256 totalSupply_, uint256 tokenPrice_, uint256 tokenDecimal_, uint256 hardcap_) {
       console.log("TotalTokenValue, hardcap----------->", (totalSupply_ * tokenPrice_) / 10 ** tokenDecimal_, hardcap_)
       require((totalSupply_ * tokenPrice_) / 10 ** tokenDecimal_ >= hardcap_, "Insufficient total supply of token");
       _; 
    }

    ///@dev checks if Tokens fully charged for ICO
    modifier tokensChargedFully() {
      uint256 _tokensAvailable = tokensAvailable();
      uint256 _fundsAbleToRaise = (tokenInfo.price * _tokensAvailable) /10 ** tokenInfo.decimal;
      require(_fundsAbleToRaise > hardcap, "Tokens should be charged fully before ICO");
      _;
    }

    ///@dev checks if amount is able to buy tokens
    modifier ableToBuy(uint256 amount_) {
        uint256 _tokensAvailable = tokensAvailable();
        uint256 _tokens = (amount_ * 10 ** tokenInfo.decimal) / tokenInfo.price;
        require(_tokens <= _tokensAvailable, "Insufficient tokens available");
        _;
    }

    ///@dev event for fee distributed after successful ico
    event FeeDistributed(
      address ico,
      address distributor,
      uint256 fundsRaised,
      uint256 listerFee,
      uint256 daoFee,
      uint256 timestamp
    )

    ///@dev event for invest
    event Invest(
      address ico,
      address investor,
      address contributor,
      uint256 amount,
      uint256 timestamp
    )

    ///@dev event for refundng all funds
    event FundsAllRefund(
      address ico,
      address refunder,
      uint256 timestamp
    )


}
