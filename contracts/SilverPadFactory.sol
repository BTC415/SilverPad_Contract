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
}