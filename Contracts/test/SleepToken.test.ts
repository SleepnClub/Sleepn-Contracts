import { expect } from "chai";
import { ethers } from "hardhat";

// Test 1 : Mumbai Testnet 
// Address Contract : 0x124AE849075ff729Ffdf49a49519777206F6fF64

// Vérifie que les jetons créés vont bien sur le compte du créateur
// describe("SleepToken contract", function () {
//     it("Deployment should assign the total supply of tokens to the owner", async function () {
//       const [owner] = await ethers.getSigners();
//       const SleepToken = await ethers.getContractFactory("SleepToken");
//       const token = await SleepToken.deploy();
//       const ownerBalance = await token.balanceOf(owner.address);
//       expect(await token.totalSupply()).to.equal(ownerBalance);
//     });
// });