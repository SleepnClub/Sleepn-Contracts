import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const superToken = "";
  const host = "";
  const cfa = "";

  // Deployment
  const Reward = await ethers.getContractFactory('Reward');
  console.log('Deploying Reward contract...');
  const reward = await upgrades.deployProxy(Reward, [superToken, host, cfa], { initializer: "initialize"});
  await reward.deployed();
  console.log('Reward contract Proxy deployed to:', reward.address);
  console.log(await upgrades.erc1967.getImplementationAddress(reward.address)," getImplementationAddress");
  console.log(await upgrades.erc1967.getAdminAddress(reward.address)," getAdminAddress");
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})




