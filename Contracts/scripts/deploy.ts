// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const SleepToken = await ethers.getContractFactory("SleepToken");
  console.log('Deploying SleepToken contract...');
  const sleepToken = await SleepToken.deploy();
  await sleepToken.deployed();
  console.log("SleepToken contract deployed to:", sleepToken.address);

  // 162
  const subscriptionId = 162;
  // Mumbai Testnet : 0x6168499c0cFfCaCD319c818142124B7A15E857ab 
  const vrfCoordinator = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
  // Mumbai Testnet : 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
  const link_token_contract = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
  // Mumbai Testnet : 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
  const keyHash = "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f";

  const BedroomNFT = await ethers.getContractFactory("BedroomNFT");
  console.log('Deploying BedroomNFT contract...');
  const bedroomNFT = await BedroomNFT.deploy(
    subscriptionId, 
    vrfCoordinator,
    link_token_contract,
    keyHash
  );
  await bedroomNFT.deployed();
  console.log("BedroomNFT contract deployed to:", bedroomNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
