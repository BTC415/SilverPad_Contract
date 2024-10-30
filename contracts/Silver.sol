//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Silver is ReentrancyGuard {
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

    /// @dev ICO creator
    address public creator;

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

    ////@dev funds raised
    uint256 public fundsRaised;

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
    HISTORY[] public history;

    ///@dev checks if fundsRaisedAddress is valid
    modifier notZeroAdderss(address address_) {
        require(address_ != address(0), "Invalid Addresss");
        _;
    }

    ///@dev checks if Amount is greater than 0
    modifier notZeroAmount(uint256 amount_) {
        require(amount_ > 0, "Amount must be greater than 0");
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
    modifier totalSupplyAbleToReachHardcap(
        uint256 totalSupply_,
        uint256 price_,
        uint256 tokenDecimal_,
        uint256 hardcap_
    ) {
        console.log(
            "TotalTokenValue, hardcap----------->",
            (totalSupply_ * price_) / 10 ** tokenDecimal_,
            hardcap_
        );
        require(
            (totalSupply_ * price_) / 10 ** tokenDecimal_ >= hardcap_,
            "Insufficient total supply of token"
        );
        _;
    }

    ///@dev checks if Tokens fully charged for ICO
    modifier tokensChargedFully() {
        uint256 _tokensAvailable = tokensAvailable();
        uint256 _fundsAbleToRaise = (tokenInfo.price * _tokensAvailable) /
            10 ** tokenInfo.decimal;
        require(
            _fundsAbleToRaise > hardcap,
            "Tokens should be charged fully before ICO"
        );
        _;
    }

    ///@dev checks if amount is able to buy tokens
    modifier ableToBuy(uint256 amount_) {
        uint256 _tokensAvailable = tokensAvailable();
        uint256 _tokens = (amount_ * 10 ** tokenInfo.decimal) / tokenInfo.price;
        require(_tokens <= _tokensAvailable, "Insufficient tokens available");
        _;
    }

    ///@dev checks if total Supply is greater than 0
    modifier NotZeroTotalSupply(uint256 totalSupply_) {
        require(totalSupply_ > 0, "TotalSupply must be greater than 0");
        _;
    }

    ///@dev event for fee distributed after successful ico
    event FeeDistributed(
        address ico,
        address distributor,
        uint256 fundsRaised,
        uint256 daoFee,
        uint256 listerFee,
        uint256 creatorFee,
        uint256 timestamp
    );

    ///@dev event for invest
    event Invest(
        address ico,
        address investor,
        address contributor,
        uint256 amount,
        uint256 timestamp
    );

    ///@dev event for refundng all funds
    event FundsAllRefund(address ico, address refunder, uint256 timestamp);

    /**
     *@dev     constructor for ICO launch
     *@param   projectURI_ project metadata uri "https://ipfs..."
     *@param   name_ token name
     *@param   symbol_ token symbol
     *@param   totalSupply_ token totalSupply
     *@param   decimal_ token decimal
     *@param   price_ token price
     *@param   creator_ address of creator
     *@param   tokenAddress_ token tokenAdress
     *@param   listerAddress_ address of listing partner
     *@param   daoAddress_ address of DAO owner
     *@param   fundRaisedAddress_ address of raising funds after successful ico
     *@param   softcap_ softcap of ico
     *@param   hardcap_ hardcap of ico
     *@param   endTime_ endTime of ico
     */
    constructor(
        string memory projectURI_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 decimal_,
        uint256 price_,
        address creator_,
        address tokenAddress_,
        address listerAddress_,
        address daoAddress_,
        address fundRaisedAddress_,
        uint256 softcap_,
        uint256 hardcap_,
        uint256 endTime_
    )
        totalSupplyAbleToReachHardcap(totalSupply_, price_, decimal_, hardcap_)
        notZeroAmount(totalSupply_)
        notZeroAmount(decimal_)
        notZeroAdderss(creator_)
        notZeroAdderss(tokenAddress_)
        notZeroAdderss(listerAddress_)
        notZeroAdderss(daoAddress_)
        notZeroAdderss(fundRaisedAddress_)
        capSettingValid(softcap_, hardcap_)
        isICORunning(endTime_)
    {
        owner = msg.sender;
        projectURI = projectURI_;

        tokenInfo.name = name_;
        tokenInfo.symbol = symbol_;
        tokenInfo.totalSupply = totalSupply_;
        tokenInfo.decimal = decimal_;
        tokenInfo.price = price_;
        tokenInfo.tokenAddress = tokenAddress_;

        creator = creator_;
        lister = listerAddress_;
        daoAddress = daoAddress_;
        fundRaisedAddress = fundRaisedAddress_;
        softcap = softcap_;
        hardcap = hardcap_;

        startTime = block.timestamp;
        endTime = endTime_;

        silverToken = IERC20(tokenAddress_);
    }

    /**
     * @dev return remaining token balance for ICO
     * @return amount token balance as uint256
     */
    function maxTokenAmountToPurchase() public view returns (uint256) {
        uint256 _amount = silverToken.balanceOf(address(this));
        return _amount;
    }

    /// @dev test if tokens are charged fully to reach hardcap
    function tokensFullyCharged() public view returns (bool) {
        uint _tokensAvailable = tokensAvailable();
        uint _fundsAbleToRaise = (tokenInfo.price * _tokensAvailable) /
            10 ** tokenInfo.decimal;

        if (_fundsAbleToRaise >= hardcap) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev return remaining token balance for ICO
     * @return amount token balance as uint256
     */
    function tokensAvailable() public view returns (uint256) {
        uint256 _amount = silverToken.balanceOf(address(this));
        return _amount;
    }

    /**
     * @dev return minimum ETH available to purchase tokens
     * @return amount token balance as uint256
     */
    function minEthAvailable() public view returns (uint256) {
        return (tokenInfo.price * 10 ** tokenInfo.decimal) / 10 ** 18;
    }

    /**
     * @dev return token available to purchase using given Eth
     * @return amount token amount as uint256
     */
    function tokensAvailableByEth(uint256 eth_) public view returns (uint256) {
        return eth_ / tokenInfo.price;
    }

    /**
     * @dev Returns the Eth needed to purchase a equivalent amount of tokens.
     * @param amount_ the amount of tokens
     * @return amount eth as uint256
     */
    function ethdByTokens(uint256 amount_) public view returns (uint256) {
        return (tokenInfo.price * amount_) / 10 ** tokenInfo.decimal;
    }
    /**
     * @dev Returns a token that can be purchased with an equivalent amount of ETH.
     * @param amount_ the amount of eth
     * @return amount token amount as uint256
     */
    function tokensByEth(uint256 amount_) public view returns (uint256) {
        return (amount_ * 10 ** tokenInfo.decimal) / tokenInfo.price;
    }

    /**
     * @dev Calculate the amount of tokens to sell to reach the hard cap.
     * @return amount token amount as uint256
     */
    function totalCap() public view returns (uint256) {
        return hardcap / tokenInfo.price;
    }

    /**
     * @dev buy tokens using ETH
     * @param amount_ ETH amount to invest
     * @param contributor_ contribution partner's address
     */
    function invest(
        uint amount_,
        address contributor_
    ) external payable nonReentrant tokensChargedFully ableToBuy(amount_) {
        require(block.timestamp < endTime, "ICO is ended");
        require(amount_ > 0, "Invalid amount");
        require(msg.value >= amount_, "Insufficient Eth amount");
        require(contributor_ != address(0), "Invalid contributor's address");

        if (investments[msg.sender] == 0) investors.push(msg.sender);
        investments[msg.sender] += amount_;

        if (contributions[contributor_] == 0) contributors.push(contributor_);
        contributions[contributor_] += amount_;

        uint256 _gap = msg.value - amount_;
        if (_gap > 0) {
            payable(msg.sender).transfer(_gap); // If there is any ETH left after purchasing tokens, it will be refunded.
        }

        // save investment history
        history.push(
            HISTORY(msg.sender, contributor_, amount_, block.timestamp)
        );

        fundsRaised += amount_;
        if (fundsRaised >= hardcap) {
            // Once the funds raised reach the hard cap, the ICO is completed and the funds are distributed.
            endTime = block.timestamp - 1;
            distribute();
        }
        emit Invest(
            address(this),
            msg.sender,
            contributor_,
            amount_,
            block.timestamp
        );
    }

    /**
     * @dev when time is reach, creator finish ico
     */
    function finish() external payable nonReentrant {
        require(block.timestamp > endTime, "ICO not ended yet.");

        if (fundsRaised >= softcap) {
            distribute(); // If funds raised reach softcap, distribute funds
        } else {
            finishNotSuccess(); // If the funds don't reach softcap, all investments will be refunded to investors
        }
    }

    /**
     * @dev If the ICO fails to reach the soft cap before the end of the self-set time, all funds will be refunded to investors.
     */
    function finishNotSuccess() internal {
        // refunds all funds to investors
        for (uint256 i = 0; i < investors.length; i++) {
            address to = investors[i];
            uint256 _amount = investments[to];
            investments[to] = 0;
            if (_amount > 0) payable(to).transfer(_amount);
        }

        // refunds all tokens to creator
        uint256 _tokens = tokensAvailable();
        SafeERC20.safeTransfer(silverToken, creator, _tokens);

        // set refund information
        refund.refunded = true;
        refund.refunder = msg.sender;
        refund.timestamp = block.timestamp;

        emit FundsAllRefund(address(this), msg.sender, block.timestamp);
    }

    /**
     * @dev Distribute fees to dao and partners and send funds to creators' wallets, and send tokens to investors.
     */
    function distribute() internal {
        bool success = false;
        // funds raised
        uint256 _funds = fundsRaised;
        // cryptoSI DADAO fee 2.5%
        uint256 _daoFee = (_funds * 25) / 1000;
        (success, ) = payable(daoAddress).call{value: _daoFee}("");
        require(success, "Failed to send DAO fee.");
        //listing partner's fee 1%
        uint256 _listerFee = (_funds * 10) / 1000;
        (success, ) = payable(lister).call{value: _listerFee}("");
        require(success, "Failed to send listing partner's fee.");
        //creator's funds 95%
        uint256 _creatorFee = (_funds * 95) / 100;
        (success, ) = payable(fundRaisedAddress).call{value: _creatorFee}("");
        require(success, "Failed to send creator's funds.");

        // distribute investor's contribution fees to contribution partners
        for (uint256 i = 0; i < contributors.length; i++) {
            address _to = contributors[i];
            uint256 _amount = (contributions[_to] * 15) / 1000;
            // send 1.5% to contribution partner
            (success, ) = payable(_to).call{value: _amount}("");
            require(success, "Failed to send contribution partner's fee.");
        }
        // distribute tokens to investors
        for (uint256 i = 0; i < investors.length; i++) {
            address _to = investors[i];
            uint256 _amount = investments[_to];
            uint256 _tokens = (_amount * 10 ** tokenInfo.decimal) /
                tokenInfo.price;
            SafeERC20.safeTransfer(silverToken, _to, _tokens);
        }
        // set distribution information
        distribution.distributed = true;
        distribution.distributor = msg.sender;
        distribution.timestamp = block.timestamp;

        emit FeeDistributed(
            address(this),
            msg.sender,
            _funds,
            _daoFee,
            _listerFee,
            _creatorFee,
            block.timestamp
        );
    }

    /**
     * @dev get current state of this ICO
     */
    function getICOState() public view returns (ICOState _state) {
        if (block.timestamp < endTime) {
            _state = ICOState.SUCCESS;
        } else if (fundsRaised >= hardcap) {
            _state = ICOState.REACHEDHARDCAP;
        } else if (fundsRaised < softcap) {
            _state = ICOState.FAILED;
        } else {
            _state = ICOState.REACHEDSOFTCAP;
        }
        return _state;
    }

    /**
     * @dev get all investors
     */
    function getInvestors() public view returns (address[] memory) {
        return investors;
    }

    /**
     * @dev Get the investor's investment amount
     */
    function getInvestAmount(address from) public view returns (uint256) {
        return investments[from];
    }

    /**
     * @dev Get all contributors
     */
    function getContributors() public view returns (address[] memory) {
        return contributors;
    }

    /**
     * @dev Get contribution partner's fee
     */
    function getContributorAmount(address from) public view returns (uint256) {
        return contributions[from];
    }

    /**
     * @dev get all investment history
     */
    function getHistory() public view returns (HISTORY[] memory) {
        return history;
    }

    function getTokenAmountForInvestor(
        address from
    ) public view returns (uint256) {
        uint256 _amount = investments[from];
        uint256 _tokens = (_amount * 10 ** tokenInfo.decimal) / tokenInfo.price;
        return _tokens;
    }

    receive() external payable {}
    fallback() external payable {}
}
