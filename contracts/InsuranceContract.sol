// pragma solidity ^0.8.19;

// contract InsuranceContract {
//     struct Claim {
//         address claimant;
//         uint256 claimAmount;
//         uint256 claimDate;
//         string claimReason;
//         bool isApproved;
    
//     }

//     struct Policy {
//         uint256 policyId;
//         // address customer;
//         string policyType;
//         uint256 premiumAmount;
//         uint256 coverageAmount;
//         uint256 policyStartDate;
//         uint256 policyEndDate;
//         bool isActive;
//         bool isClaimed;
//         Claim[] claims; // Array to hold claims related to the policy
//     }

//     address public admin;
//     uint256 private nextPolicyId = 1;
//     mapping(uint256 => Policy) public policies;
//     mapping(address => uint256[]) public customerPolicies;

//     modifier onlyAdmin() {
//         require(msg.sender == admin, "Only admin can perform this action.");
//         _;
//     }

//     // modifier onlyPolicyHolder(uint256 _policyId) {
//     //     require(policies[_policyId].customer == msg.sender, "Not the policy owner.");
//     //     _;
//     // }

//     constructor() {
//         admin = msg.sender; // Set contract deployer as admin
//     }

//     event PolicyIssued(uint256 indexed policyId, address indexed customer);

//     // Function to issue a policy (Only Admin)
//     function issuePolicy(
//         address _customer,
//         string memory _policyType,
//         uint256 _premiumAmount,
//         uint256 _coverageAmount,
//         uint256 _durationInDays
//     ) public onlyAdmin returns (uint256) {
//         uint256 policyId = nextPolicyId++;
//         uint256 startDate = block.timestamp;
//         uint256 endDate = startDate + (_durationInDays * 1 days);

//         Policy storage newPolicy = policies[policyId];
//         newPolicy.policyId = policyId;
//         newPolicy.policyType = _policyType;
//         newPolicy.premiumAmount = _premiumAmount;
//         newPolicy.coverageAmount = _coverageAmount;
//         newPolicy.policyStartDate = startDate;
//         newPolicy.policyEndDate = endDate;
//         newPolicy.isActive = true;
//         newPolicy.isClaimed = false;
//         // newPolicy.claims is automatically initialized as an empty array

//         customerPolicies[_customer].push(policyId);
//         emit PolicyIssued(policyId, _customer);

//         return policyId;
//     }

//     // Function to get policy details
//     function getPolicy(uint256 _policyId) public view returns (Policy memory) {
//         return policies[_policyId];
//     }

//     // Function to claim insurance (Only the customer)
//     function claimInsurance(uint256 _policyId) public  {
//         require(policies[_policyId].isActive, "Policy is not active.");
//         require(!policies[_policyId].isClaimed, "Insurance already claimed.");

//         policies[_policyId].isClaimed = true;
//     }

//     // Function for admin to deactivate a policy
//     function deactivatePolicy(uint256 _policyId) public onlyAdmin {
//         policies[_policyId].isActive = false;
//     }
// }



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InsuranceContract {
    struct Claim {
        string claimId;
        string insuredName; // Name of the insured person
        string driverName; // Name of the driver (if applicable)
        string vehicleNumber; // Vehicle number (if applicable)
        uint256 amountClaimed; // Amount claimed
        uint256 amountApproved; // Amount approved for the claim
        string description; // Optional description for the claim
        // string status; // e.g., "Pending", "Approved", "Rejected"
        string proforma; // proforma invoice or document related to the claim
        string medicalRecords; // Medical records if applicable
        uint256 claimDate; // Date of the claim
        string accidentType; // Type of accident (e.g., Personal Injury, Property Damage)
    }

    struct Policy {
        string policyId;
        string policyType;
        uint256 premiumAmount;
        uint256 coverageAmount;
        uint256 policyStartDate;
        uint256 policyEndDate;
        bool isActive;
        Claim[] claims;
    }

    struct Insurance {
        string userId;
        Policy[] policies;
    }

    address public admin;

    mapping(string => Insurance) private insurances;         // userId => Insurance
    mapping(string => address) private policyOwners;         // userId => wallet address

    event PolicyIssued(string indexed userId, string indexed policyId, address indexed owner);
    event ClaimAdded(string indexed userId, string indexed policyId, string indexed claimId, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyPolicyHolder(string memory _userId) {
        require(policyOwners[_userId] == msg.sender, "Not the policy owner");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Issue a policy by manually provided policyId
    function issuePolicy(
        string memory _userId,
        string memory _policyId,
        string memory _policyType,
        uint256 _premiumAmount,
        uint256 _coverageAmount,
        uint256 _durationInDays,
        address _ownerAddress
    ) public onlyAdmin {
        Insurance storage insurance = insurances[_userId];

        if (bytes(insurance.userId).length == 0) {
            insurance.userId = _userId;
        }

        // Prevent duplicate policyId for this user
        for (uint256 i = 0; i < insurance.policies.length; i++) {
            require(
                keccak256(bytes(insurance.policies[i].policyId)) != keccak256(bytes(_policyId)),
                "Policy ID already exists"
            );
        }

        Policy memory newPolicy = Policy({
            policyId: _policyId,
            policyType: _policyType,
            premiumAmount: _premiumAmount,
            coverageAmount: _coverageAmount,
            policyStartDate: block.timestamp,
            policyEndDate: block.timestamp + (_durationInDays * 1 days),
            isActive: true,
            claims: new Claim 
        });

        insurance.policies.push(newPolicy);
        policyOwners[_userId] = _ownerAddress;

        emit PolicyIssued(_userId, _policyId, _ownerAddress);
    }

    // Add a claim to a specific policy
    function addClaimToPolicy(
        string memory _userId,
        string memory _policyId,
        string memory _claimId,
        uint256 _amount
    ) public onlyPolicyHolder(_userId) {
        Insurance storage insurance = insurances[_userId];
        bool found = false;

        for (uint256 i = 0; i < insurance.policies.length; i++) {
            if (keccak256(bytes(insurance.policies[i].policyId)) == keccak256(bytes(_policyId))) {
                require(insurance.policies[i].isActive, "Policy not active");
                require(_amount <= insurance.policies[i].coverageAmount, "Exceeds coverage");

                // Prevent duplicate claimId
                for (uint256 j = 0; j < insurance.policies[i].claims.length; j++) {
                    require(
                        keccak256(bytes(insurance.policies[i].claims[j].claimId)) != keccak256(bytes(_claimId)),
                        "Claim ID already exists"
                    );
                }

                insurance.policies[i].claims.push(
                    Claim({
                        claimId: _claimId,
                        amount: _amount,
                        date: block.timestamp
                    })
                );

                emit ClaimAdded(_userId, _policyId, _claimId, _amount);
                found = true;
                break;
            }
        }

        require(found, "Policy not found");
    }

    // Get all policies for a user
    function getAllPolicies(string memory _userId)
        public
        view
        returns (Policy[] memory)
    {
        return insurances[_userId].policies;
    }

    // Get a specific policy
    function getPolicy(string memory _userId, string memory _policyId)
        public
        view
        returns (Policy memory)
    {
        Policy[] storage policies = insurances[_userId].policies;

        for (uint256 i = 0; i < policies.length; i++) {
            if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
                return policies[i];
            }
        }

        revert("Policy not found");
    }

    // Get a specific claim
    function getClaimById(string memory _userId, string memory _policyId, string memory _claimId)
        public
        view
        returns (Claim memory)
    {
        Policy[] storage policies = insurances[_userId].policies;

        for (uint256 i = 0; i < policies.length; i++) {
            if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
                Claim[] storage claims = policies[i].claims;

                for (uint256 j = 0; j < claims.length; j++) {
                    if (keccak256(bytes(claims[j].claimId)) == keccak256(bytes(_claimId))) {
                        return claims[j];
                    }
                }
            }
        }

        revert("Claim not found");
    }

    // Deactivate a policy (admin only)
    function deactivatePolicy(string memory _userId, string memory _policyId)
        public
        onlyAdmin
    {
        Policy[] storage policies = insurances[_userId].policies;

        for (uint256 i = 0; i < policies.length; i++) {
            if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
                policies[i].isActive = false;
                return;
            }
        }

        revert("Policy not found");
    }

    // Get the wallet address of the policy owner
    function getPolicyOwner(string memory _userId)
        public
        view
        returns (address)
    {
        return policyOwners[_userId];
    }
}


