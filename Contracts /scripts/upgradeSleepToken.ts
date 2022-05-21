import { ethers, upgrades } from 'hardhat';

async function main() {
    // Parameters
    const addressProxy = "0x920907cbc06f10bcC141c4126eEd398492398793";

    // Upgrades
    const SleepTokenV2 = await ethers.getContractFactory('SleepToken');
    console.log('Upgrading SleepToken contract...');
    await upgrades.upgradeProxy(addressProxy, SleepTokenV2);
    console.log('SleepToken contract upgraded');
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})