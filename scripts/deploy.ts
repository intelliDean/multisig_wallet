import { ethers } from "hardhat";

async function main() {

  const [
            owner,
            account1,
            account2,
            account3,
            account4,
            account5
        ] = await ethers.getSigners()

  const multiSig = await ethers.deployContract("MultiSig", [[account1.address, account2.address, account3.address, account4.address, account5.address]]);

  await multiSig.waitForDeployment();

  console.log(`Contract: MultiSig is deployed to ${multiSig.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
