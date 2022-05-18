import { ethers, upgrades } from 'hardhat';

async function main() {
  const BedroomNft = await ethers.getContractFactory('BedroomNft');
  console.log('Deploying BedroomNft contract...');
  const totalSupply = 1000000000000;
  const bedroomNft = await upgrades.deployProxy(BedroomNft, [totalSupply], { initializer: "initialize"});

  await bedroomNft.deployed();
  console.log('BedroomNft contract Proxy deployed to:', bedroomNft.address);
  console.log(await upgrades.erc1967.getImplementationAddress(bedroomNft.address)," getImplementationAddress");
  console.log(await upgrades.erc1967.getAdminAddress(bedroomNft.address)," getAdminAddress");
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
