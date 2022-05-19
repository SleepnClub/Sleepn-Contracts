import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const superToken = "0xEbD1E9E455744e87251dDD969BDa123ffce46229";
  const host = "0xEB796bdb90fFA0f28255275e16936D25d3418603";
  const cfa = "0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873";
  const bedroomNftContract = "";

  // Deployment
  const Reward = await ethers.getContractFactory('Reward');
  console.log('Deploying Reward contract...');
  const reward = await upgrades.deployProxy(
    Reward, 
    [superToken, host, cfa, bedroomNftContract], 
    { initializer: "initialize"}
  );
  await reward.deployed();
  console.log('Reward contract Proxy deployed to:', reward.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})




