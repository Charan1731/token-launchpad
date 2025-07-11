const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Factory",  () => {
    const FEE = ethers.parseUnits("0.01",18)
//comments
    const deployFactoryFixture = async () => {

        const [deployer,buyer, creator] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory("Factory");


        const factory = await Factory.deploy(FEE);

        const transaction = await factory.connect(creator).create("COINflop", "COIN", { value:FEE });
        await transaction.wait();

        const tokenAddress = await factory.tokens(0);

        const Token = await ethers.getContractAt("Token", tokenAddress);

        return { factory, deployer, buyer, creator, token: Token }
    }

    const buyTokenFixture = async () => {
        const {factory, token, creator, buyer} = await deployFactoryFixture();

        const AMOUNT = ethers.parseUnits("10000", 18);
        const COST = ethers.parseUnits("1",18);

        const transaction = await factory.connect(buyer).buy(await token.getAddress() ,AMOUNT, {value: COST});
        await transaction.wait();

        return {factory, token, creator, buyer}
    }

    describe("Deployment", () => {
        it("should set the fee", async () => {
            const { factory} = await deployFactoryFixture();

            const fee = await factory.fee();

            expect(fee).to.equal(FEE);
        })

        it("should set the owner", async () => {
            const {factory, deployer} = await deployFactoryFixture();

            const owner = await factory.owner();

            expect(owner).to.equal(deployer.address);
        })
    })

    describe("Create", () => {
        it("should set the owner", async () => {
            const { factory, token } = await deployFactoryFixture();

            const owner = await token.owner();

            expect(owner).to.equal( await factory.getAddress());
        })

        it("should set the creator", async () => {
            const {token, creator} = await deployFactoryFixture();

            const creatorAddress = await token.creator();

            expect(creatorAddress).to.equal(creator.address);
        })

        it("should set the supply", async () => {
            const {token} = await deployFactoryFixture();

            const supply = await token.totalSupply();

            expect(supply).to.equal(ethers.parseUnits("1000000", 18));
        })

        it("should update the ETH balance", async () => {
            const {factory} = await deployFactoryFixture();

            const balance = await ethers.provider.getBalance(factory.getAddress());

            expect(balance).to.equal(FEE);
        })

        it("should create a token sale", async () => {
            const {factory, token, creator} = await deployFactoryFixture();

            const count = await factory.tokenCount();

            expect(count).to.equal(1);
            const sale = await factory.getTokenSale(0);

            expect(sale.token).to.equal(await token.getAddress());
            expect(sale.name).to.equal("COINflop");
            expect(sale.creator).to.equal(creator.address);
            expect(sale.sold).to.equal(0);
            expect(sale.raised).to.equal(0);
            expect(sale.isOpen).to.equal(true);

        })
    })

    describe("Buying", () => {

        const AMOUNT = ethers.parseUnits("10000", 18);
        const COST = ethers.parseUnits("1",18);


        it("should update the ETH balance", async () => {
            const {factory} = await buyTokenFixture();

            const balance = await ethers.provider.getBalance(await factory.getAddress());

            expect(balance).to.equal(FEE+COST);
        })

        it("should update the token balance", async () => {
            const {token, buyer} = await buyTokenFixture();

            const balance = await token.balanceOf(buyer.address);

            expect(balance).to.equal(AMOUNT);
        })
    })
})
