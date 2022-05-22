import { ethers, upgrades } from 'hardhat';

async function main() {
    // Parameters
    const addressProxy = "0x84c895074eA9aB9FF1ae1101A036fe8040352Dc9";

    // Upgrades
    const RewardV2 = await ethers.getContractFactory('Reward');
    console.log('Upgrading Reward contract...');
    await upgrades.upgradeProxy(addressProxy, RewardV2);
    console.log('Reward contract upgraded');
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})