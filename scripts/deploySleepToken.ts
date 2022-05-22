import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const totalSupply = 1000000000000;
  const rewardContract = "0x84c895074eA9aB9FF1ae1101A036fe8040352Dc9";
  const walletTeam = "0x151C165898908E827FF0389eA5a3A679AbD2aa54";

  // Deployment
  const SleepToken = await ethers.getContractFactory('SleepToken');
  console.log('Deploying SleepToken contract...');
  const sleepToken = await upgrades.deployProxy(
    SleepToken, 
    [totalSupply, rewardContract, walletTeam], 
    { initializer: "initialize" }
  );
  await sleepToken.deployed();
  console.log('SleepToken contract Proxy deployed to:', sleepToken.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

