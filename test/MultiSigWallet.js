const { expect } = require("chai");
const { assert } = require("console");
const { ethers } = require("hardhat");

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage of Hardhat Network's snapshot functionality.
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("MultiSigWallatet contract", function() {
	let accounts;
	let hardhatMultiSigWallet;
	var deployer;
	async function deployTokenFixture() {
		[deployer] = await ethers.getSigners();
		accounts = await ethers.provider.listAccounts();
		const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
		
		//const addresses = ["0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","0x70997970c51812dc3a010c7d01b50e0d17dc79c8","0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc"];
		//const requireds = 2;
			 //"0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
			 //"0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc"];
		
		//const ONEHUNDRED_ETH = 100;
		//const WalletAmount = ONEHUNDRED_ETH;
		
		hardhatMultiSigWallet = await MultiSigWallet.deploy(accounts.slice(0, 3), 2);
		await hardhatMultiSigWallet.deployed();
		console.log('Multisigwallet deployed to:', hardhatMultiSigWallet.address );//显示合约地址
		// Fixtures can return anything you consider useful for your tests
		return { hardhatMultiSigWallet, deployer, accounts };
	}
	describe("Deployment", function () {
		it("Deployment account is one of owners", async function(){
			const owners = await hardhatMultiSigWallet.getOwners();
			console.log(`Owner1 ${owners[0]}`);
			console.log(`Deployer ${deployer.address}`);
			expect(owners[0]).to.equal(deployer.address);
		});
	})


	describe('Submit Transaction', function () {
		//var txid;
		const oneEther = ethers.utils.parseEther("1");
		beforeEach(async () => {
			await expect(hardhatMultiSigWallet.submitTransaction(accounts[3], oneEther, "0x"))
			.to.emit(hardhatMultiSigWallet, "SubmitTransaction")
			.withArgs(accounts[0], 0, accounts[3], oneEther, "0x");
			//console.log(`Recipient ${accounts[3]}`);
			//console.log(`Txid ${txid}`);
		});

		//it('Submit Transaction success!', async () => {
			//const transaction = ;
			//assert.equal(await hardhatMultiSigWallet.transactions()[txid][4], txid);
		//});
	});
	describe("Return a transaction", function () {
		it("Should return the transaction 0", async function () {
			const { hardhatMultiSigWallet } = await loadFixture(deployTokenFixture);
			const tx = await hardhatMultiSigWallet.getTransaction( 0 );
			console.log(tx);
		});
	});

});

