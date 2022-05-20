import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const teamWallet = "0x151C165898908E827FF0389eA5a3A679AbD2aa54";
  const sleepTokenContract = "0x920907cbc06f10bcC141c4126eEd398492398793";
  const bedroomNftContract = "0xb150a58d376DeF437AB8b19ab351db7BA2C1eDEe";
  const upgradeNftContract = "0x45D484c35f13e6FFe370a881728508bf48da77CB";

  // Deployment
  const Dex = await ethers.getContractFactory('Dex');
  console.log('Deploying Dex contract...');
  const dex = await upgrades.deployProxy(
    Dex,
    [teamWallet, sleepTokenContract, bedroomNftContract, upgradeNftContract],
    { initializer: "initialize" });
  await dex.deployed();
  console.log('Dex contract Proxy deployed to:', dex.address);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
