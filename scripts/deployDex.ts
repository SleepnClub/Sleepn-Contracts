import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  const teamWallet = "0x151C165898908E827FF0389eA5a3A679AbD2aa54";
  const sleepTokenContract = "0x920907cbc06f10bcC141c4126eEd398492398793";
  const bedroomNftContract = "0xa7E90a744302c3B8e888dbf140dD4C6Afdb3e5B3";
  const upgradeNftContract = "0x3537980f3CB0C24A4a3B2541AD525fCFE5f18160";

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
