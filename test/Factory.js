const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Factory",  () => {
    const FEE = ethers.parseUnits("0.01",18)

    const deployFactoryFixture = async () => {

        const [deployer, creator] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory("Factory");


        const factory = await Factory.deploy(FEE);

        const transaction = await factory.connect(creator).create("COINflop", "COIN", { value:FEE });
        await transaction.wait();

        const tokenAddress = await factory.tokens(0);

        const Token = await ethers.getContractAt("Token", tokenAddress);

        return { factory, deployer, creator, token: Token }
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
    })
})
