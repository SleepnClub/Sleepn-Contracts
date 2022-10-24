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
- Upgrader Contract : contracts/Utils/Upgrader.sol
- Tracker Contract : contracts/Utils/Tracker.sol

## Contracts Addresses
Sleepn Smartcontracts are deployed on Polygon Mainet.

| CONTRACTS | ADDRESSES |
| ------ | ------ |
| Bedroom NFT Contract | [0x2AC6960E44ef6f4465Ea74Cc1a96fF0f7F05E5a3](https://polygonscan.com/address/0x2AC6960E44ef6f4465Ea74Cc1a96fF0f7F05E5a3) 
| Upgrade NFT Contract | [0xCBE4EC04ABb4593348f405B898Fa5a6DEcD325c6](https://polygonscan.com/address/0xCBE4EC04ABb4593348f405B898Fa5a6DEcD325c6)
| Dex Contract | [0x67b39c00f10d22B0cAFcf253a8D6cdA5290FBba6](https://polygonscan.com/address/0x67b39c00f10d22B0cAFcf253a8D6cdA5290FBba6)
| Sheepy Contract | [0x7eF3e3E4b46d43Aba61BA41c2d2d6c5569f4F2ab](https://polygonscan.com/address/0x7eF3e3E4b46d43Aba61BA41c2d2d6c5569f4F2ab)
| $Sleep Contract | [0xE4f187CEd8761e11D8464c6368FD792e0Ab60Da2](https://polygonscan.com/address/0xE4f187CEd8761e11D8464c6368FD792e0Ab60Da2)
| $Health Contract | [0x82BA26DcCF3C7d2CB31A37c073809f9b37398Ed1](https://polygonscan.com/address/0x82BA26DcCF3C7d2CB31A37c073809f9b37398Ed1)
| Tracker Contract | [0xCaEB84F7F812Ae85b2FBD9672B61e70BC79Dc410](https://polygonscan.com/address/0xCaEB84F7F812Ae85b2FBD9672B61e70BC79Dc410)
| Upgrader Contract | [0x93b255aaDe976758cb9C1B29593Fb739732c6A8d](https://polygonscan.com/address/0x93b255aaDe976758cb9C1B29593Fb739732c6A8d)

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

