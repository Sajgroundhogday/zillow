const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe('Escrow', () => {
    let buyer, seller;
    let realEstate, escrow;
    it('saves the addresses', async () => {
        //setup accounts
        [buyer , seller, inspector, lender] = await ethers.getSigners();
        // const buyer = signers[0];
        // const seller = signers[1];

        let RealEstate = await ethers.getContractFactory("RealEstate");
        realEstate = await RealEstate.deploy();

        //mint
        let transaction = await realEstate.connect(seller).mint("https://ipfs.io/ipfs/QmQVcpsjrA6cr1iJjZAodYwmPekYgbnXGo4DFubJiLc2EB/1.json");
        await transaction.wait();
        
        const Escrow = await ethers.getContractFactory('Escrow');
        escrow = await Escrow.deploy(
            realEstate.address,
            seller.address,
            inspector.address,
            lender.address
        )
    });
});