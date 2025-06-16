const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const USTYToken = await ethers.getContractFactory("USTYToken");
  const usty = await upgrades.deployProxy(USTYToken, [
    "USTY Token", 
    "USTY", 
    "0xYourFeeCollectorAddressHere"
  ], { initializer: "initialize" });

  await usty.deployed();
  console.log("USTYToken deployed to:", usty.address);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
