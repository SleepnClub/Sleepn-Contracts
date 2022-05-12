import { expect } from "chai";
import { ethers } from "hardhat";
import { BedroomNft } from "../typechain";

describe("SubscriptionManager contract", function () {  
    let BedroomNft: BedroomNft;
    let owner;
    let addr1: any;
    let addr2;
    let contract;
    let address: any;
    
    it("Account 1 should own an NFT...", async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        // Test 1 : Mumbai Testnet 
        // Address Contract : 0x77D08C620728194fF1A4b3dA458f04975568CF1e
        BedroomNft = await ethers.getContractFactory("BedroomNft");;
        BedroomNft = BedroomNft.attach("0x77D08C620728194fF1A4b3dA458f04975568CF1e");
        await BedroomNft.setThresholds(0, 60, 2, 0);
        await BedroomNft.setThresholds(1, 80, 3, 0);
        await BedroomNft.setThresholds(5, 70, 3, 0);
        await BedroomNft.setThresholds(7, 50, 3, 0);
        await BedroomNft.setThresholds(13, 90, 2, 0);
        await BedroomNft.setThresholds(14, 40, 2, 0);
        BedroomNft.on("BedroomNftMinting", (tokenId, tokenURI, infos, bedroom, bed) => {
            address = infos.owner;
        })
        await BedroomNft.mintingBedroomNft(0, addr1);
        expect(address).to.equal(addr1);
    });

});