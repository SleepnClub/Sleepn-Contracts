import { expect } from "chai";
import { ethers } from "hardhat";
import { BedroomNFT } from "../typechain";

describe("SubscriptionManager contract", function () {  
    let BedroomNFT;
    let bedroomNFT: BedroomNFT;
    let owner;
    let addr1: any;
    let addr2;
    let contract;
    let address: any;
    
    it("Account 1 should own an NFT...", async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        // Test 1 : Mumbai Testnet 
        // Address Contract : 0x77D08C620728194fF1A4b3dA458f04975568CF1e
        BedroomNFT = await ethers.getContractFactory("BedroomNFT");;
        bedroomNFT = BedroomNFT.attach("0x77D08C620728194fF1A4b3dA458f04975568CF1e");
        await bedroomNFT.setThresholds(0, 60, 2, 0);
        await bedroomNFT.setThresholds(1, 80, 3, 0);
        await bedroomNFT.setThresholds(5, 70, 3, 0);
        await bedroomNFT.setThresholds(7, 50, 3, 0);
        await bedroomNFT.setThresholds(13, 90, 2, 0);
        await bedroomNFT.setThresholds(14, 40, 2, 0);
        bedroomNFT.on("BedroomNFTMinting", (tokenId, tokenURI, infos, bedroom, bed) => {
            address = infos.owner;
        })
        await bedroomNFT.mintingBedroomNft(0, addr1);
        expect(address).to.equal(addr1);
    });

});