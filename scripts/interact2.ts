import { ethers } from "hardhat";

const CONTRACT_ADDRESS = process.env.DEPLOYMENT_ADDRESS!; // Replace with your deployed contract address

// Format timestamp to human-readable date
const formatDate = (timestamp: any) =>
  new Date(Number(timestamp) * 1000).toLocaleDateString();

// Convert BigNumber to string (MATIC)


async function main() {
  const [admin, user] = await ethers.getSigners();

  const contract = await ethers.getContractAt(
    "InsuranceContract",
    CONTRACT_ADDRESS,
    admin
  );

  console.log("🧑‍⚖️ Admin address:", admin.address);
  console.log("👤 User address :", user.address);

  // ===== Issue a policy to the user =====
  console.log("\n📤 Issuing policy for user...");

  const issueTx = await contract.issuePolicyByAdmin(
    user.address,
    "POL123",
    "Vehicle",
    1000,
    "Addis Ababa",
    30 // 30 days
  );
  await issueTx.wait();
  console.log("✅ Policy issued.");

  // ===== Get all users =====
  console.log("\n📋 Fetching all users...");
  const allUsers = await contract.getAllUsers();
  allUsers.forEach((addr: string, idx: number) =>
    console.log(`User ${idx + 1}: ${addr}`)
  );

  // ===== Admin retrieves user's policies =====
  console.log("\n🔎 Admin reading user's policies...");
  const adminPolicies = await contract.getUserPolicies(user.address);
  adminPolicies.forEach((policy: any, index: number) => {
    console.log(`\n📘 [Admin] Policy #${index + 1}`);
    console.log(`ID          : ${policy.policyId}`);
    console.log(`Type        : ${policy.policyType}`);
    console.log(`Premium     : ${(policy.premiumAmount)}`);
    console.log(`Coverage    : ${policy.coverageArea}`);
    console.log(`Start Date  : ${formatDate(policy.policyStartDate)}`);
    console.log(`End Date    : ${formatDate(policy.policyEndDate)}`);
    console.log(`Active      : ${policy.isActive}`);
    console.log(`Claims      : ${policy.claims.length}`);
  });

  // ===== Connect as user and get their own policy =====
  const contractAsUser = contract.connect(user);

  console.log("\n🙋 User reading their own policies...");
  const userPolicies = await contractAsUser.getMyPolicies();
  userPolicies.forEach((policy: any, index: number) => {
    console.log(`\n📗 [User] Policy #${index + 1}`);
    console.log(`ID          : ${policy.policyId}`);
    console.log(`Type        : ${policy.policyType}`);
    console.log(`Premium     : ${(policy.premiumAmount)}`);
    console.log(`Coverage    : ${policy.coverageArea}`);
    console.log(`Start Date  : ${formatDate(policy.policyStartDate)}`);
    console.log(`End Date    : ${formatDate(policy.policyEndDate)}`);
    console.log(`Active      : ${policy.isActive}`);
    console.log(`Claims      : ${policy.claims.length}`);
  });

  console.log("\n✅ Done.");
}

main().catch((err) => {
  console.error("❌ Error:", err);
});
