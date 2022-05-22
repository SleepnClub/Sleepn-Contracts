import { ethers, upgrades } from 'hardhat';

async function main() {
    // Parameters
    const addressProxy = "0x3240E10ad3EBc6b66E8FaAA0E288123702B3A29f";

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