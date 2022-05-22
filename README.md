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
| Bedroom NFT Contract | [0xa7E90a744302c3B8e888dbf140dD4C6Afdb3e5B3](https://polygonscan.com/address/0xa7E90a744302c3B8e888dbf140dD4C6Afdb3e5B3) 
| Upgrade NFT Contract | [0x3537980f3CB0C24A4a3B2541AD525fCFE5f18160](https://polygonscan.com/address/0x3537980f3CB0C24A4a3B2541AD525fCFE5f18160)
| Dex Contract | [0x3240E10ad3EBc6b66E8FaAA0E288123702B3A29f](https://polygonscan.com/address/0x3240E10ad3EBc6b66E8FaAA0E288123702B3A29f)
| Reward Contract | [0xa87637C7E74B6f74be80EA0507C7AfDb204F950A](https://polygonscan.com/address/0xa87637C7E74B6f74be80EA0507C7AfDb204F950A)
| Sleep Token Contract | [0x920907cbc06f10bcC141c4126eEd398492398793](https://polygonscan.com/token/0x920907cbc06f10bcC141c4126eEd398492398793)
| Super Sleep Token Contract | [0x38270a994843BeB153e9c7D1cb35878D83E6ab86](https://polygonscan.com/address/0x38270a994843BeB153e9c7D1cb35878D83E6ab86)

## Technologies
- Chainlink VRF V2 : Used in Bedroom and Upgrade NFTs contracts to generate random scores.
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

- Superfluid : Used to stream $SLEEP Token to GetSleepn users in Reward contract
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

- Gnosis Safe : Cash management and contract management  

- IPFS + Unstoppable Domains : NFTs storage <br>
Example -> [Click On Me](https://getsleepn.crypto/1.png)<br>
This requires a Web3.0 browser such as Brave, which supports IPFS and Unstoppable Domains.

## License
MIT

