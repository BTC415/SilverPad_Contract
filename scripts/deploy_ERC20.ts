import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  /////Early Liquidity
  console.log("Deploying DAI token contracts with the account:", deployer.address);
  const DAI = await ethers.getContractFactory("DAI");
  const daiToken = await DAI.deploy(1000000000);
  await daiToken.waitForDeployment();
  console.log("DAI address:", await daiToken.getAddress());

  console.log("Deploying DEW token contracts with the account:", deployer.address);
  const DEW = await ethers.getContractFactory("DEW");
  const dewToken = await DEW.deploy();
  await dewToken.waitForDeployment();
  console.log("DEW address:", await dewToken.getAddress());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
