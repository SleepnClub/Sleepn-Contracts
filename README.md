# Sleepn is a web3 game that pays you to sleep better
![How Sleepn Works](https://user-images.githubusercontent.com/3343429/169715829-8df70002-36ad-4794-9161-a4874e59ceda.png)

# GetSleepn - Smartcontracts
## Contracts Source Codes
- Bedroom NFT Contract : contracts/BedroomNft.sol  
- Upgrade NFT Contract : contracts/Upgrade.sol 
- Decentralized Exchange Contract : contracts/Dex.sol
- Stream Reward Contract : contracts/Reward.sol
- Sleep Token Contract : contracts/SleepToken.sol

## Contracts Addresses
GetSleepn Smartcontracts are deployed on Polygon Mainet.

| CONTRACTS | ADDRESSES |
| ------ | ------ |
| Bedroom NFT Contract | [0x9765209cD1CcC89Ed6B9A57c5e6407F53A7a6991](https://polygonscan.com/address/0x9765209cD1CcC89Ed6B9A57c5e6407F53A7a6991) 
| Upgrade NFT Contract | [0xe6EFeb9F1CaE75bA2bd671B34c2c310b8547d6Fd](https://polygonscan.com/address/0xe6EFeb9F1CaE75bA2bd671B34c2c310b8547d6Fd)
| Dex Contract | [0x3240E10ad3EBc6b66E8FaAA0E288123702B3A29f](https://polygonscan.com/address/0x3240E10ad3EBc6b66E8FaAA0E288123702B3A29f)
| Reward Contract | [0xa87637C7E74B6f74be80EA0507C7AfDb204F950A](https://polygonscan.com/address/0xa87637C7E74B6f74be80EA0507C7AfDb204F950A)
| Sleep Token Contract | [0x920907cbc06f10bcC141c4126eEd398492398793](https://polygonscan.com/address/0x920907cbc06f10bcC141c4126eEd398492398793)
| Super Sleep Token Contract | [0x38270a994843BeB153e9c7D1cb35878D83E6ab86](https://polygonscan.com/address/0x38270a994843BeB153e9c7D1cb35878D83E6ab86)

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

