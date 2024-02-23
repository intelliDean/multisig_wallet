import {loadFixture,} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {ethers} from "hardhat";
import {expect} from "chai";

describe("MultiSignature Wallet test", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployMultiSig() {
        // Contracts are deployed using the first signer/account by default
        const [
            owner,
            account1,
            account2,
            account3,
            account4,
            account5
        ] = await ethers.getSigners();

        const MultiSig = await ethers.getContractFactory("MultiSig");
        const multiSig =
            await MultiSig.deploy([
                account1.address,
                account2.address,
                account3.address,
                account4.address,
                account5.address
            ]);

        return {multiSig, owner, account1, account2, account3, account4, account5};
    }

    describe("Deployment", function () {
        it("Should make sure the contract deploys successfully", async function () {
            const {
                multiSig,
                owner,
                account1
            } = await loadFixture(deployMultiSig);
            expect(await multiSig.getAddress()).exist;
          //  expect(owner).to.be.equal(await multiSig.owner())
        });
    });
});
