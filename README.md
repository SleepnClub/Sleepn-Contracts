# Sleepn is a web3 game that pays you to sleep better
![How Sleepn Works](https://user-images.githubusercontent.com/3343429/169715829-8df70002-36ad-4794-9161-a4874e59ceda.png)

# GetSleepn - Smartcontracts
## Contracts Source Codes
- Bedroom NFT Contract : contracts/Contracts/Nfts/BedroomNft.sol  
- Upgrade NFT Contract : contracts/Contracts/Nfts/Upgrade.sol 
- Decentralized Exchange Contract : contracts/Contracts/Dex.sol
- Stream Reward Contract : contracts/Contracts/Reward.sol
- $Sleep Contract : contracts/Contracts/Tokens/$Sleep.sol
- $Health Contract : contracts/Contracts/Tokens/$Health.sol


## Contracts Addresses
GetSleepn Smartcontracts are deployed on Polygon Mainet.

| CONTRACTS | ADDRESSES |
| ------ | ------ |
| Bedroom NFT Contract | [0xDfC0E2eD1030E76b0489C9fcF0586b8dE0773f0F](https://polygonscan.com/address/0xDfC0E2eD1030E76b0489C9fcF0586b8dE0773f0F) 
| Upgrade NFT Contract | [0x2c23066E6b1E082664EBfd7784EaB79C8B744edF](https://polygonscan.com/address/0x2c23066E6b1E082664EBfd7784EaB79C8B744edF)
| Dex Contract | [0x84231d557b8f41aaC90Be9e4DD982D1085815283](https://polygonscan.com/address/0x84231d557b8f41aaC90Be9e4DD982D1085815283)
| Reward Contract | [0xB1e08b3f0b79F7ac31D6F0bA2d8B38626E7f771e](https://polygonscan.com/address/0xB1e08b3f0b79F7ac31D6F0bA2d8B38626E7f771e)
| $Sleep Contract | [0xD174dFE2C68802B6f6821152899BA061aA24C596](https://polygonscan.com/address/0xD174dFE2C68802B6f6821152899BA061aA24C596)
| $Health Contract | [0xd18a5fa2e49411Deacdd17E21808cBBf2B2e7392](https://polygonscan.com/address/0xd18a5fa2e49411Deacdd17E21808cBBf2B2e7392)
| Super $Sleep Contract | [0xeFf5435D6503d1bFE400B23E29DddC0c750dB4E5](https://polygonscan.com/address/0xeFf5435D6503d1bFE400B23E29DddC0c750dB4E5)

## Technologies
- Gnosis Safe : Cash management + Contracts Ownership management 

- IPFS : NFTs storage <br>

- Chainlink VRF V2 : Used in Bedroom and Upgrade NFTs contracts to generate random scores
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

- Superfluid : Used to stream $SLEEP to GetSleepn users in Reward contract
    ```solidity
    (, int96 outFlowRate, , ) = cfa.getFlow(
        superToken,
        address(this),
        _receiver
    );

    if (outFlowRate == 0) {
        cfaV1.createFlow(_receiver, superToken, flowrate);
    } else {
        cfaV1.updateFlow(_receiver, superToken, flowrate);
    }

    cfaV1.deleteFlow(address(this), _receiver, superToken);
    ```
- Uniswap : Used for the liquidity pool of $SLEEP/USDC in Sleep Token contract
    ```solidity
    function createNewPool(
        address _tokenB,
        uint24 _fee,
        uint160 _sqrtPriceX96
    ) external onlyOwner {
        address newPool = factory.createPool(address(this), _tokenB, _fee);
        // Set new pool address
        pool = IUniswapV3Pool(newPool);
        // Init price of the pool
        pool.initialize(_sqrtPriceX96);
    }

    function collectFee(int24 _tickLower, int24 _tickUpper) external onlyOwner {
        pool.collect(
            teamWallet,
            _tickLower,
            _tickUpper,
            type(uint128).max,
            type(uint128).max
        );
    }
    ```

## License
Distributed under the MIT License.

