import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Using address:", deployer.address);

  if (!deployer.provider) {
    throw new Error("Provider is undefined for the deployer.");
  }
  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("Balance:", ethers.utils.formatEther(balance), "MATIC");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
