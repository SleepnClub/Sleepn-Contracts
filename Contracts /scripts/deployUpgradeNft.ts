import { ethers } from 'hardhat';

async function main() {
  // Parameters
  const subscriptionId = 33;
  const vrfCoordinator = "0xAE975071Be8F8eE67addBC1A82488F1C24858067";
  const keyHash = "0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8";
  
  // Deployment
  const UpgradeNft = await ethers.getContractFactory('UpgradeNft');
  console.log('Deploying UpgradeNft contract...');
  const upgradeNft = await UpgradeNft.deploy(subscriptionId, vrfCoordinator, keyHash);
  await upgradeNft.deployed();
  console.log('UpgradeNft contract deployed to:', upgradeNft.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
