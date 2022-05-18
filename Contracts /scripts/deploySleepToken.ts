import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const totalSupply = 1000000000000;

  // Deployment
  const SleepToken = await ethers.getContractFactory('SleepToken');
  console.log('Deploying SleepToken contract...');
  const sleepToken = await upgrades.deployProxy(SleepToken, [totalSupply], { initializer: "initialize"});
  await sleepToken.deployed();
  console.log('SleepToken contract Proxy deployed to:', sleepToken.address);
  console.log(await upgrades.erc1967.getImplementationAddress(sleepToken.address)," getImplementationAddress");
  console.log(await upgrades.erc1967.getAdminAddress(sleepToken.address)," getAdminAddress");
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

