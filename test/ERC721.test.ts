import { expect } from 'chai';
import { ethers } from 'hardhat';

describle('ERC721', function (): void {
  it("Should return the owner address!", async function():	Promise<void> {
    const ERC721 = await ethers.getContractFactory('ERC721');
	const erc721 = await ERC721.deploy();
	await erc721.deployed();
	
	expect(await erc721.)
  });
});