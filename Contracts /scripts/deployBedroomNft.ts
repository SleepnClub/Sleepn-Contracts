import { ethers } from 'hardhat';

async function main() {
  // Parameters
  const subscriptionId = 33;
  const vrfCoordinator = "0xAE975071Be8F8eE67addBC1A82488F1C24858067";
  const keyHash = "0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8";
  
  // Deployment
  const BedroomNft = await ethers.getContractFactory('BedroomNft');
  console.log('Deploying BedroomNft contract...');
  const bedroomNft = await BedroomNft.deploy(subscriptionId, vrfCoordinator, keyHash);
  await bedroomNft.deployed();
  console.log('BedroomNft contract deployed to:', bedroomNft.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
