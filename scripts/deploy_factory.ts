import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  /////Early Liquidity
  const dai = "0xdc1a36bc15d5255Bb7061ec78e735e5C4dA4Ce5e";
  const dao = "0x5B98a0c38d3684644A9Ada0baaeAae452aE3267B"

  console.log("Deploying SilverPadFactory contracts with the account:", deployer.address);
  const FACTORY = await ethers.getContractFactory("SilverPadFactory");
  const factory = await FACTORY.deploy(dai, dao);
  await factory.waitForDeployment();
  console.log("factory address:", await factory.getAddress());
  //https://sepolia.etherscan.io/address/0x0a86feB19b48Ad6ACDf1A476b4757A1abc3Ee82a#code
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
