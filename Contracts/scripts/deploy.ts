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
  
  // Mumbai Testnet : 0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed
  // Polygon Mainnet : 0xAE975071Be8F8eE67addBC1A82488F1C24858067
  const vrfCoordinator = "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed";

  // Mumbai Testnet : 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
  // Polygon Mainnet : 0xb0897686c545045aFc77CF20eC7A532E3120E0F1
  const link_token_contract = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";

  // Mumbai Testnet : 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92
  // Polygon Mainnet : 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd
  const keyHash = "0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92";

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
