import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Factory Contract Test", function () {

    let vulcanPadFactory: any;
    let ico: any;

    let dew:any;
    let dai:any;
    let owner:any;
    let user:any;
    let user1:any;
    let user2:any;
    let lister:any;
    let contributor1:any;
    let contributor2:any ;
    const daoAddress:any = "0x5B98a0c38d3684644A9Ada0baaeAae452aE3267B";

    const _endTime = Math.floor(new Date("2024-04-30").getTime() / 1000);


    it("should deploy DAI contract", async function(){

        [owner, user, user1, user2, lister, contributor1, contributor2] = await ethers.getSigners();

        // Get the first account as the owner
        const DAIInstance = await ethers.getContractFactory("DAI") ;
        dai = await DAIInstance.connect(user).deploy(1000000) ;

        console.log('\tDAI token deployed at:', await dai.getAddress());
        console.log("\tuser's dai balance: ", await dai.balanceOf(await user.address));
    })

    it("should deploy DEW contract", async function(){
        // Get the first account as the owner
        const DEWInstance = await ethers.getContractFactory("DEW") ;
        dew = await DEWInstance.connect(user).deploy() ;
        
        console.log('\tDEW token deployed at:', await dew.getAddress());
        console.log("\tuser's dew balance: ", await dew.balanceOf(await user.address));
    });

    it("should deploy Factory contract", async function(){
        const VulcanFactoryInstance = await ethers.getContractFactory("VulcanPadFactory") ;
        vulcanPadFactory = await VulcanFactoryInstance.deploy(await dai.getAddress(), daoAddress) ;
        
        console.log('\tVulcanPadFactory deployed at:', await vulcanPadFactory.getAddress());
    });


    it("test for deploying Vulcan ICO", async function () {

        // console.log("user's fee before: ", await vulcanPadFactory.feeContributions(await user.address));
        // console.log("user's dai balance before: ", await dai.balanceOf(await user.address));
        // console.log("user's isPaidSpmaFilterFee", await vulcanPadFactory.paidSpamFilterFee(user.address));

        await dai.connect(user).approve(await vulcanPadFactory.getAddress(), ethers.parseEther("100"));
        await vulcanPadFactory.connect(user).paySpamFilterFee();
        
        // console.log("user's fee: ", await vulcanPadFactory.feeContributions(await user.address));
        // console.log("user's dai balance: ", await dai.balanceOf(await user.address));
        // console.log("user's isPaidSpmaFilterFee", await vulcanPadFactory.paidSpamFilterFee(user.address));
        
        //ICO information for deployment...
        const _projectURI = "https://ipfs:werwqerwerqwer";
        const _softcap = ethers.parseEther("0.5");
        const _hardcap = ethers.parseEther("1");
        const _symbol = "DEW";
        const _name = "Dreams Evolving Widely";
        const _price = ethers.parseEther("0.000000393218720152");
        const _decimals = 18;
        const _totalSupply = "10,000,000,000,000,000,000,000,000,000,000,000";
        const _tokenAddress = await dew.getAddress();
        const _fundsAddress = "0xC80e9598cC9B3474Ac55888b01521a1E206385da";

        await vulcanPadFactory.connect(user).launchNewICO(
            _projectURI,
            _softcap,
            _hardcap,
            _endTime,
            _symbol,
            _name,
            _price,
            _decimals,
            _totalSupply,
            _tokenAddress,
            _fundsAddress,
            lister.address
        );
        // console.log("user's fee: ", await vulcanPadFactory.feeContributions(await user.address))
        const _vulcans = await vulcanPadFactory.getVulcans();
        console.log("ICOs: ", _vulcans);

        const vulcanInstance = await ethers.getContractFactory("Vulcan") ;
        ico = await vulcanInstance.attach(_vulcans[0]);
    });

    it("test ICO info", async function () {
        const _totalCap = await ico.totalCap()
        const _tokenInfo = await ico.tokenInfo();
        const _hardcap = await ico.hardcap();
        const _softcap = await ico.softcap();
        const _creator = await ico.creator();

        const _distribution = await ico.distribution ();
        const _refund = await ico.refund ();
        const _history = await ico.getHistory ();

        console.log({
            _distribution,
            _refund,
            _history,
            _tokenInfo,
            _softcap,
            _hardcap,
            _creator,
            _totalCap,
        });
    });


    it("Check the balance of all addresses", async function(){
        const listerAmount = await ethers.provider.getBalance(lister.address) ;
        console.log("lister ", ethers.formatEther(listerAmount)) ;
        const contributor1Amount = await ethers.provider.getBalance(contributor1.address) ;
        console.log("contributor1 ", ethers.formatEther(contributor1Amount)) ;
        const contributor2Amount = await ethers.provider.getBalance(contributor2.address) ;
        console.log("contributor2 ",await ethers.formatEther(contributor2Amount)) ;
        const daoAmount = await ethers.provider.getBalance(daoAddress) ;
        console.log("dao ", await ethers.formatEther(daoAmount)) ;
        const userAmount = await ethers.provider.getBalance(user.address) ;
        console.log("creator ", await ethers.formatEther(userAmount)) ;
    });


    it("Try to invest", async function () {

        await dew.connect(user).transfer(await ico.getAddress(), ethers.parseUnits("1543114.817261654", 18));
        console.log("status -----------", await ico.tokensFullyCharged ());
        await dew.connect(user).transfer(await ico.getAddress(), ethers.parseUnits("1000000", 18));
        console.log("status -----------", await ico.tokensFullyCharged ());
        // await dew.connect(user).transfer(await ico.getAddress(), 200000*1e10);

        let _user1Balance = await dew.balanceOf(user1.address);
        let _user1Eth = await ethers.provider.getBalance(user1.address);
        console.log("user1 balance before buy: ", { tokens: ethers.formatUnits(_user1Balance, 10), eth: ethers.formatEther(_user1Eth) });
        console.log("ICO state ", await ico.getICOState ());
        
        // invest 0.1 via contributor1
        await ico.connect(user1).invest(ethers.parseEther("0.500000353643214943"), contributor1, {value: ethers.parseEther("1.000000353643214943")});
        _user1Balance = await dew.balanceOf(user1.address);
        let _history = await ico.getHistory ();
        console.log("history ------", _history);


        
        
        _user1Balance = await dew.balanceOf(user1.address);
        _user1Eth = await ethers.provider.getBalance(user1.address);
        console.log("user1 balance after buy: ", { tokens: ethers.formatUnits(_user1Balance, 10), eth: ethers.formatEther(_user1Eth) });
        console.log("ICO state ", await ico.getICOState ());
        
        // invest 59.9 via contributor2
        await ico.connect(user1).invest(ethers.parseEther("0.5"), contributor2,  {value: ethers.parseEther("60")});
        _history = await ico.getHistory ();
        console.log("history ------", _history);
        await time.increaseTo(_endTime) ;
        
        _user1Balance = await dew.balanceOf(user1.address);
        _user1Eth = await ethers.provider.getBalance(user1.address);
        console.log("user1 balance after buy: ", { tokens: ethers.formatUnits(_user1Balance, 10), eth: ethers.formatEther(_user1Eth) });
        console.log("ICO state ", await ico.getICOState ());
    });

    // it("claim with creator when finish ICO", async function () {
    //     console.log("ICO state ", await ico.getICOState ());
    //     await ico.connect(user1).finish() ;

    //     const distribution = await ico.distribution ();
    //     const refund = await ico.refund ();

    //     console.log({ distribution, refund });
    // });

    it("Check the balance of all addresses", async function(){
        const listerAmount = await ethers.provider.getBalance(lister.address) ;
        const contributor1Amount = await ethers.provider.getBalance(contributor1.address) ;
        const contributor2Amount = await ethers.provider.getBalance(contributor2.address) ;
        const daoAmount = await ethers.provider.getBalance(daoAddress);
        const userAmount = await ethers.provider.getBalance(user.address);
        const user1Amount = await ethers.provider.getBalance(user1.address);
        const tokensRemain = await dew.balanceOf(await ico.getAddress());
        const tokens = await dew.balanceOf(user1.address);
        const tokenAmount = await dew.balanceOf(user1.address);
        const creatorTokens = await dew.balanceOf(user.address);
        
        console.log("user1: ", {
            eth: ethers.formatEther(user1Amount),
            tokens: ethers.formatUnits(tokenAmount, 10)
        });
        console.log("lister ", {
            eth: ethers.formatEther(listerAmount)
        });
        console.log("contributor1 ", {
            eth: ethers.formatEther(contributor1Amount)
        });
        console.log("contributor2 ", {
            eth: ethers.formatEther(contributor2Amount)
        });
        console.log("dao: ", {
            eth: ethers.formatEther(daoAmount)
        });
        console.log("ico tokens remain", ethers.formatUnits(tokensRemain, 10));
        console.log("user: ", {
            eth: ethers.formatEther(userAmount),
            tokens: ethers.formatUnits(creatorTokens, 10)
        });
    });
});
