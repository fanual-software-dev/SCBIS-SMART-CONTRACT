import { ethers, artifacts } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // Get the ContractFactory
  const InsuranceContract = await ethers.getContractFactory("InsuranceContract");

  console.log("Deploying the InsuranceContract...");

  // Deploy the contract
  const insurance = await InsuranceContract.deploy();

  // Wait until deployment is done
  await insurance.deployTransaction.wait();

  console.log(`InsuranceContract deployed to: ${insurance.address}`);

  // Save deployed address and ABI automatically
  saveFrontendFiles(insurance);
}

function saveFrontendFiles(contract: any) {
  const contractsDirBackend = path.join(__dirname, "../../backend/src/contracts");
  const contractsDirFrontend = path.join(__dirname, "../../frontend/contracts");

  if (!fs.existsSync(contractsDirBackend)) {
    fs.mkdirSync(contractsDirBackend, { recursive: true });
  }

  if (!fs.existsSync(contractsDirFrontend)) {
    fs.mkdirSync(contractsDirFrontend, { recursive: true });
  }

  // Write Contract Address
  fs.writeFileSync(
    path.join(contractsDirBackend, "ContractAddress.json"),
    JSON.stringify({ address: contract.address }, null, 2)
  );

  fs.writeFileSync(
    path.join(contractsDirFrontend, "ContractAddress.json"),
    JSON.stringify({ address: contract.address }, null, 2)
  );

  // Write Contract ABI
  const artifact = artifacts.readArtifactSync("InsuranceContract");

  fs.writeFileSync(
    path.join(contractsDirBackend, "ContractABI.json"),
    JSON.stringify(artifact.abi, null, 2)
  );

  fs.writeFileSync(
    path.join(contractsDirFrontend, "ContractABI.json"),
    JSON.stringify(artifact.abi, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
