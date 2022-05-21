import { ethers, upgrades } from 'hardhat';

async function main() {
    // Parameters
    const addressProxy = "0x4FC7D46Ebc6165A72926d0711f0855f14bAeaAd7";

    // Upgrades
    const DexV2 = await ethers.getContractFactory('Dex');
    console.log('Upgrading Dex contract...');
    await upgrades.upgradeProxy(addressProxy, DexV2);
    console.log('Dex contract upgraded');
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})