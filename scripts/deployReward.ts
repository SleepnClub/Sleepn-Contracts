import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const host = "0x3E14dC1b13c488a8d5D310918780c983bD5982E7";
  const cfa = "0x6EeE6060f715257b970700bc2656De21dEdF074C";
  const bedroomNftContract = "0xb150a58d376DeF437AB8b19ab351db7BA2C1eDEe";

  // Deployment
  const Reward = await ethers.getContractFactory('Reward');
  console.log('Deploying Reward contract...');
  const reward = await upgrades.deployProxy(
    Reward, 
    [host, cfa, bedroomNftContract], 
    { initializer: "initialize"}
  );
  await reward.deployed();
  console.log('Reward contract Proxy deployed to:', reward.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})




