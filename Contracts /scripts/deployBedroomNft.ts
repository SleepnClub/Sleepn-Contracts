import { ethers, upgrades } from 'hardhat';

async function main() {
  // Parameters
  // Deployment
  const BedroomNft = await ethers.getContractFactory('BedroomNft');
  console.log('Deploying BedroomNft contract...');
  const totalSupply = 1000000000000;
  uint64 _subscriptionId, 
        address _vrfCoordinator, 
        address _link_token_contract,
        bytes32 _keyHash
  
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
