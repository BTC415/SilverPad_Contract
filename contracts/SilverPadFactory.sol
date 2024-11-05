//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Silver.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

contract SilverPadFactory {
    ///@dev owner of the factory
    address public owner;

    ///@dev cryptoSIDADAO address
    address public cryptoSIDADAO = 0x5B98a0c38d3684644A9Ada0baaeAae452aE3267B;

    ///@dev DAI ERC20 token
    IERC20 public immutable daiToken;

    ///@dev spam filter fee amount 100DAI with 18 decimals
    uint256 public feeAmount = 100 ether;

    ///@dev tracks spam filter fee contributions of investors
    mapping(address => uint256) public feeContributions;

    ///@dev created ICOs
    address[] public silvers;

    ///@dev ICO is launched
    mapping(address => bool) public isSilver;

    /// @dev event when user paid 100DAI spam filter fee
    event PaidSpamFilterFee(address user, uint256 amount);

    /// @dev event when new ICO is created
    event ICOCreated(
        address creator,
        address ico,
        string projectURI,
        uint256 softcap,
        uint256 hardcap,
        uint256 startTime,
        uint256 endTime,
        string name,
        string symbol,
        uint256 price,
        uint256 decimal,
        uint256 totalSupply,
        address tokenAddress,
        address fundsAddress,
        address lister
    );

    /// @dev validate if address is non-zero
    modifier notZeroAddress(address address_) {
        require(address_ != address(0), "Invalid address");
        _;
    }

    /// @dev validate if paid 100DAI spam filter fee
    modifier spamFilterFeePaid(address user_) {
        require(
            feeContributions[user_] >= feeAmount,
            "Not paid spam filter fee"
        );
        _;
    }

    /// @dev validate endtime is valid
    modifier isFuture(uint256 endTime_) {
        require(endTime_ > block.timestamp, "End time should be in the future");
        _;
    }

    /// @dev validate softcap & hardcap setting
    modifier capSettingValid(uint256 softcap_, uint256 hardcap_) {
        require(softcap_ > 0, "Softcap must be greater than 0");
        require(hardcap_ > softcap_, "Hardcap must be greater than softcap");
        _;
    }

    /// @dev validate if token price is zero
    modifier notZeroValue(uint256 price_) {
        require(price_ > 0, "Value must be greater than 0");
        _;
    }

    /// @dev validate if funds can reach the hardcap for this token
    modifier totalSupplyAbleToReachHardcap(
        uint price_,
        uint totalSupply_,
        uint decimal_,
        uint hardcap_
    ) {
        require(
            (price_ * totalSupply_) / 10 ** decimal_ >= hardcap_,
            "Have to be able to reach hardcap"
        );
        _;
    }

}
