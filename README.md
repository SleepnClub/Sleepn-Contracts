# Sleepn is a web3 game that pays you to sleep better
![How Sleepn Works](https://user-images.githubusercontent.com/3343429/169715829-8df70002-36ad-4794-9161-a4874e59ceda.png)

# Sleepn - Smartcontracts
## Contracts Source Codes
- Bedroom NFT Contract : contracts/Nfts/BedroomNft.sol  
- Upgrade NFT Contract : contracts/Nfts/UpgradeNft.sol 
- Decentralized Exchange Contract : contracts/Dex.sol
- Sheepy Contract : contracts/Sheepy.sol
- $Sleep Contract : contracts/Tokens/Sleep.sol
- $Health Contract : contracts/Tokens/Health.sol


## Contracts Addresses
Sleepn Smartcontracts are deployed on Polygon Mainet.

| CONTRACTS | ADDRESSES |
| ------ | ------ |
| Bedroom NFT Contract | [0xC51cB791bb89aBaA16718dAEE6052D5f8FEaC9F4](https://polygonscan.com/address/0xC51cB791bb89aBaA16718dAEE6052D5f8FEaC9F4) 
| Upgrade NFT Contract | [0xFb61e907AAcA297f5491C6E1c5f82A76f38f4681](https://polygonscan.com/address/0xFb61e907AAcA297f5491C6E1c5f82A76f38f4681)
| Dex Contract | [0x478628AF527868e07c97120BAF885F1c178BE43f](https://polygonscan.com/address/0x478628AF527868e07c97120BAF885F1c178BE43f)
| Sheepy Contract | [0x1055179fd59b7F81Fa3D46286735CAB6897bF304](https://polygonscan.com/address/0x1055179fd59b7F81Fa3D46286735CAB6897bF304)
| $Sleep Contract | [0xF0F03172d0487A1B3f9731a31fa59F5381BFE47f](https://polygonscan.com/address/0xF0F03172d0487A1B3f9731a31fa59F5381BFE47f)
| $Health Contract | [0xbbFd0a0923F939bDD5D672D4a0121c039838e658](https://polygonscan.com/address/0xbbFd0a0923F939bDD5D672D4a0121c039838e658)

## Technologies
- Gnosis Safe : Cash management + Contracts Ownership management 

- IPFS : NFTs storage <br>

- Chainlink VRF V2 : Used in Bedroom NFTs contract to generate random scores
    ```solidity
    uint256 requestId = COORDINATOR.requestRandomWords(
        keyHash,
        subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
    );

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        _mintingBedroomNft(requestIdToTokenId[_requestId], _randomWords);
        emit ReturnedRandomness(_randomWords);
    }
    ```

## License
Distributed under the MIT License.

