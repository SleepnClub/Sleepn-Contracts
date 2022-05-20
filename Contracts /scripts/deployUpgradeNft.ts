import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const subscriptionId = 33;
  const vrfCoordinator = "0xAE975071Be8F8eE67addBC1A82488F1C24858067";
  const link_token_contract = "0xb0897686c545045aFc77CF20eC7A532E3120E0F1";
  const keyHash = "0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8";
  const bedroomNftContract = "0xb150a58d376DeF437AB8b19ab351db7BA2C1eDEe";
  
  // Deployment
  const UpgradeNft = await ethers.getContractFactory('UpgradeNft');
  console.log('Deploying UpgradeNft contract...');
  const upgradeNft = await upgrades.deployProxy(
    UpgradeNft, 
    [
      subscriptionId, 
      vrfCoordinator, 
      link_token_contract, 
      keyHash,
      bedroomNftContract
    ], 
    { initializer: "initialize"}
  );
  await upgradeNft.deployed();
  console.log('UpgradeNft contract Proxy deployed to:', upgradeNft.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
