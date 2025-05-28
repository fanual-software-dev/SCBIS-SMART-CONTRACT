import { ethers } from "hardhat";

const CONTRACT_ADDRESS = process.env.DEPLOYMENT_ADDRESS!;

async function main() {
  const [signer] = await ethers.getSigners();
  const contract = await ethers.getContractAt("InsuranceContract", CONTRACT_ADDRESS, signer);

  console.log(`Connected to wallet: ${signer.address}`);
  console.log(`Reading policies for: ${signer.address}...`);

  const policies = await contract.getMyPolicies();

  if (policies.length === 0) {
    console.log("No policies found for this user.");
    return;
  }

  for (const policy of policies) {
    console.log("\n📘 Policy Details:");
    console.log(`- Policy ID        : ${policy.policyId}`);
    console.log(`- Policy Type      : ${policy.policyType}`);
    console.log(`- Premium Amount   : ${ethers.utils.formatEther(policy.premiumAmount)} MATIC`);
    console.log(`- Coverage Area    : ${policy.coverageArea}`);
    console.log(`- Start Date       : ${new Date(Number(policy.policyStartDate) * 1000).toLocaleDateString()}`);
    console.log(`- End Date         : ${new Date(Number(policy.policyEndDate) * 1000).toLocaleDateString()}`);
    console.log(`- Active           : ${policy.isActive ? "✅ Active" : "❌ Inactive"}`);
    console.log(`- Total Claims     : ${policy.claims.length}`);

    if (policy.claims.length > 0) {
      console.log("📄 Claims:");
      for (const claim of policy.claims) {
        console.log(`  - Claim ID        : ${claim.claimId}`);
        console.log(`    Insured Name    : ${claim.insuredName}`);
        console.log(`    Driver Name     : ${claim.driverName}`);
        console.log(`    Vehicle Number  : ${claim.vehicleNumber}`);
        console.log(`    Accident Type   : ${claim.accidentType}`);
        console.log(`    Claimed Amount  : ${ethers.utils.formatEther(claim.amountClaimed)} MATIC`);
        console.log(`    Approved Amount : ${ethers.utils.formatEther(claim.amountApproved)} MATIC`);
        console.log(`    Claim Date      : ${new Date(Number(claim.claimDate) * 1000).toLocaleString()}`);
        console.log(`    Approval Date   : ${claim.approvalDate.gt(0) ? new Date(claim.approvalDate.toNumber() * 1000).toLocaleString() : "Pending"}`);
        console.log(`    Approved        : ${claim.isApproved ? "✅ Yes" : "🕒 Pending"}`);
        console.log(`    Description     : ${claim.description}`);
        console.log(`    Proforma        : ${claim.proforma}`);
        console.log(`    Medical Records : ${claim.medicalRecords}`);
      }
    }
  }

  console.log("\n✅ Done reading data from blockchain.");
}

main().catch((error) => {
  console.error("❌ Error reading contract:", error);
});
