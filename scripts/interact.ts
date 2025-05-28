// import { ethers } from "hardhat";
// import { BigNumber } from "ethers";

// const CONTRACT_ADDRESS = process.env.DEPLOYMENT_ADDRESS!;

// function formatDate(bigNum: BigNumber): string {
//   const timestamp = bigNum.toNumber(); // Convert BigNumber to number
//   const date = new Date(timestamp * 1000); // Convert to milliseconds

//   const month = String(date.getMonth() + 1).padStart(2, "0");
//   const day = String(date.getDate()).padStart(2, "0");
//   const year = date.getFullYear();

//   return `${month}-${day}-${year}`;
// }



// async function main() {
//   const [deployer] = await ethers.getSigners();

//   const InsuranceContract = await ethers.getContractAt("InsuranceContract", CONTRACT_ADDRESS);

//   // Example 1: Issue a policy (write)
//   const tx = await InsuranceContract.issuePolicy(
//     deployer.address, // customerAddress
//     "Car Insurance", //policyType
//     ethers.utils.parseEther("0.01"), // premiumAmount
//     ethers.utils.parseEther("2.0"),  // coverageAmount
//     30                                // durationInDays
//   );
//   await tx.wait();
//   console.log("Policy issued.");

//   // Example 2: Get the policy (read)
//   const policy = await InsuranceContract.getPolicy(5);
//   const policyStartDate = formatDate(policy.policyStartDate);
//   const policyEndDate = formatDate(policy.policyEndDate);
//   console.log("Policy:", policy,policyStartDate, policyEndDate);
// }

// main().catch(console.error);
