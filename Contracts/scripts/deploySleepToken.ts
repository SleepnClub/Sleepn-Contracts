import { ethers, upgrades } from "hardhat";


async function main() {
  const SleepToken = await ethers.getContractFactory("SleepToken");

  const sleepToken = await upgrades.deployProxy(SleepToken);

  await sleepToken.deployed();
  console.log("SleepToken deployed to:",sleepToken.address);
}

main();