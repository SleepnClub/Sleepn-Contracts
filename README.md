# Sleepn is a web3 game that pays you to sleep better
![How Sleepn Works](https://user-images.githubusercontent.com/3343429/169715829-8df70002-36ad-4794-9161-a4874e59ceda.png)

# GetSleepn - Smartcontracts
## Contracts Source Codes
- Bedroom NFT Contract : contracts/Nfts/BedroomNft.sol  
- Upgrade NFT Contract : contracts/Nfts/UpgradeNft.sol 
- Decentralized Exchange Contract : contracts/Dex.sol
- $Sleep Contract : contracts/Tokens/Sleep.sol
- $Health Contract : contracts/Tokens/Health.sol


## Contracts Addresses
GetSleepn Smartcontracts are deployed on Polygon Mainet.

| CONTRACTS | ADDRESSES |
| ------ | ------ |
| Bedroom NFT Contract | [0x4f55460FB038b27f9159D460c8Bc0ddB8aE1a760](https://polygonscan.com/address/0x4f55460FB038b27f9159D460c8Bc0ddB8aE1a760) 
| Upgrade NFT Contract | [0x69bB50BF41E249b7F11afEcC9A52B011494cFEA5](https://polygonscan.com/address/0x69bB50BF41E249b7F11afEcC9A52B011494cFEA5)
| Dex Contract | [0x8cD9C75c775C884128fF4Aa1508f6BfD1A0A1aAe](https://polygonscan.com/address/0x8cD9C75c775C884128fF4Aa1508f6BfD1A0A1aAe)
| Sheepy Contract | [0x1055179fd59b7F81Fa3D46286735CAB6897bF304](https://polygonscan.com/address/0x1055179fd59b7F81Fa3D46286735CAB6897bF304)
| $Sleep Contract | [0xb2C50393f487F734ee6902373A9dC3b898d2F243](https://polygonscan.com/address/0xb2C50393f487F734ee6902373A9dC3b898d2F243)
| $Health Contract | [0x9C0b42b450c855B7258dCeafa15fA4f5D25f21e6](https://polygonscan.com/address/0x9C0b42b450c855B7258dCeafa15fA4f5D25f21e6)

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

