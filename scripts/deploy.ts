import { ethers } from "hardhat";

async function main() {
  const multiSig = await ethers.deployContract("MultiSig");

  await multiSig.waitForDeployment();

  console.log(`Contract: MultiSig is deployed to ${multiSig.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
