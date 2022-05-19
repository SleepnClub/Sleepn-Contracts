import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const teamWallet = "";

  // Deployment
  const Dex = await ethers.getContractFactory('Dex');
  console.log('Deploying Dex contract...');
  const dex = await upgrades.deployProxy(Dex, [teamWallet], { initializer: "initialize"});
  await dex.deployed();
  console.log('Dex contract Proxy deployed to:', dex.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
