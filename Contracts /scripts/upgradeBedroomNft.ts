import { ethers, upgrades } from 'hardhat';

async function main() {
    // Parameters
    const addressProxy = "0xb150a58d376DeF437AB8b19ab351db7BA2C1eDEe";

    // Upgrades
    const BedroomNftV2 = await ethers.getContractFactory('BedroomNft');
    console.log('Upgrading BedroomNft contract...');
    await upgrades.upgradeProxy(addressProxy, BedroomNftV2);
    console.log('BedroomNft contract upgraded');
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})