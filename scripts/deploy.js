require('dotenv').config()

const hre = require("hardhat");

async function main() {
  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(process.env.TARGET_ERC20_ADDRESS);

  await lock.deployed();

  console.log("Smart Contract Address: " + lock.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
