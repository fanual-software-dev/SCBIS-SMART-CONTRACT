


// contract InsuranceContract {
//     struct Claim {
//         string claimId;
//         string insuredName;
//         string driverName;
//         string vehicleNumber;
//         uint256 amountClaimed;
//         uint256 amountApproved;
//         string description;
//         string proforma;
//         string medicalRecords;
//         uint256 claimDate;
//         uint256 approvalDate;
//         bool isApproved;
//         string accidentType;
//     }

//     struct Policy {
//         string policyId;
//         string policyType;
//         uint256 premiumAmount;
//         string coverageArea;
//         uint256 policyStartDate;
//         uint256 policyEndDate;
//         bool isActive;
//         Claim[] claims;
//     }

//     struct PolicySummary {
//         string policyId;
//         string policyType;
//         uint256 premiumAmount;
//         string coverageArea;
//         uint256 policyStartDate;
//         uint256 policyEndDate;
//         bool isActive;
//         uint256 claimsCount;
//     }

//     address public admin;

//     mapping(address => Policy[]) private userPolicies;              // wallet => list of policies
//     mapping(string => address) private policyToOwner;              // policyId => wallet address

//     event PolicyIssued(address indexed user, string indexed policyId);
//     event ClaimAdded(address indexed user, string indexed policyId, string indexed claimId, uint256 amountClaimed);
//     event ClaimApproved(address indexed user, string indexed policyId, string indexed claimId, uint256 amountApproved);

//     modifier onlyAdmin() {
//         require(msg.sender == admin, "Only admin can perform this action");
//         _;
//     }

//     modifier onlyPolicyHolder(string memory _policyId) {
//         require(policyToOwner[_policyId] == msg.sender, "You do not own this policy");
//         _;
//     }

//     constructor() {
//         admin = msg.sender;
//     }

//     // Issue a new policy
//     function issuePolicy(
//         string memory _policyId,
//         string memory _policyType,
//         uint256 _premiumAmount,
//         string memory _coverageArea,
//         uint256 _durationInDays
//     ) public {
//         Policy[] storage policies = userPolicies[msg.sender];

//         for (uint256 i = 0; i < policies.length; i++) {
//             require(
//                 keccak256(bytes(policies[i].policyId)) != keccak256(bytes(_policyId)),
//                 "Policy ID already exists"
//             );
//         }

//         Policy storage newPolicy = userPolicies[msg.sender].push(); // Allocate new empty policy in storage

//         newPolicy.policyId = _policyId;
//         newPolicy.policyType = _policyType;
//         newPolicy.premiumAmount = _premiumAmount;
//         newPolicy.coverageArea = _coverageArea;
//         newPolicy.policyStartDate = block.timestamp;
//         newPolicy.policyEndDate = block.timestamp + (_durationInDays * 1 days);
//         newPolicy.isActive = true;

//         policyToOwner[_policyId] = msg.sender;

//         emit PolicyIssued(msg.sender, _policyId);
//     }


//     // Add a claim to a specific policy
//     function addClaimToPolicy(
//         string memory _policyId,
//         string memory _claimId,
//         uint256 _amountClaimed,
//         string memory _insuredName,
//         string memory _driverName,
//         string memory _description,
//         string memory _vehicleNumber,
//         string memory _proforma,
//         string memory _medicalRecords,
//         string memory _accidentType
//     ) public onlyPolicyHolder(_policyId) {
//         Policy[] storage policies = userPolicies[msg.sender];
//         bool added = false;

//         for (uint i = 0; i < policies.length; i++) {
//             if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
//                 require(policies[i].isActive, "Policy not active");

//                 for (uint j = 0; j < policies[i].claims.length; j++) {
//                     require(
//                         keccak256(bytes(policies[i].claims[j].claimId)) != keccak256(bytes(_claimId)),
//                         "Claim ID already exists"
//                     );
//                 }

//                 policies[i].claims.push(
//                     Claim({
//                         claimId: _claimId,
//                         amountClaimed: _amountClaimed,
//                         amountApproved: 0,
//                         claimDate: block.timestamp,
//                         approvalDate: 0,
//                         insuredName: _insuredName,
//                         driverName: _driverName,
//                         vehicleNumber: _vehicleNumber,
//                         description: _description,
//                         proforma: _proforma,
//                         medicalRecords: _medicalRecords,
//                         isApproved: false,
//                         accidentType: _accidentType
//                     })
//                 );

//                 emit ClaimAdded(msg.sender, _policyId, _claimId, _amountClaimed);
//                 added = true;
//                 break;
//             }
//         }

//         require(added, "Policy not found");
//     }

//     // Admin approves a claim using policyId (without needing user address)
//     function approveClaimById(
//         string memory _policyId,
//         string memory _claimId,
//         uint256 _amountApproved
//     ) public onlyAdmin {
//         address user = policyToOwner[_policyId];
//         require(user != address(0), "Policy not found");

//         Policy[] storage policies = userPolicies[user];
//         bool found = false;

//         for (uint i = 0; i < policies.length; i++) {
//             if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
//                 for (uint j = 0; j < policies[i].claims.length; j++) {
//                     if (keccak256(bytes(policies[i].claims[j].claimId)) == keccak256(bytes(_claimId))) {
//                         require(!policies[i].claims[j].isApproved, "Already approved");
//                         require(_amountApproved <= policies[i].claims[j].amountClaimed, "Too much approved");

//                         policies[i].claims[j].amountApproved = _amountApproved;
//                         policies[i].claims[j].isApproved = true;
//                         policies[i].claims[j].approvalDate = block.timestamp;

//                         emit ClaimApproved(user, _policyId, _claimId, _amountApproved);
//                         found = true;
//                         break;
//                     }
//                 }
//             }
//         }

//         require(found, "Claim not found");
//     }

//     // Get all policies for the connected wallet
//     function getMyPolicies() public view returns (Policy[] memory) {
//         require(userPolicies[msg.sender].length > 0, "No policies found for this user");
//         return userPolicies[msg.sender];
//     }

//     // Get a specific claim for the caller
//     function getClaim(
//         string memory _policyId,
//         string memory _claimId
//     ) public view onlyPolicyHolder(_policyId) returns (Claim memory) {
//         Policy[] storage policies = userPolicies[msg.sender];

//         for (uint i = 0; i < policies.length; i++) {
//             if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
//                 Claim[] storage claims = policies[i].claims;

//                 for (uint j = 0; j < claims.length; j++) {
//                     if (keccak256(bytes(claims[j].claimId)) == keccak256(bytes(_claimId))) {
//                         return claims[j];
//                     }
//                 }
//             }
//         }

//         revert("Claim not found");
//     }

//     // Admin deactivates a policy
//     function deactivatePolicy(string memory _policyId) public onlyAdmin {
//         address user = policyToOwner[_policyId];
//         require(user != address(0), "Policy not found");

//         Policy[] storage policies = userPolicies[user];

//         for (uint i = 0; i < policies.length; i++) {
//             if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
//                 policies[i].isActive = false;
//                 return;
//             }
//         }

//         revert("Policy not found");
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract InsuranceContract {
    struct Claim {
        string claimId;
        string insuredName;
        string driverName;
        string vehicleNumber;
        uint256 amountClaimed;
        uint256 amountApproved;
        string description;
        string proforma;
        string medicalRecords;
        uint256 claimDate;
        uint256 approvalDate;
        bool isApproved;
        string accidentType;
    }

    struct Policy {
        string policyId;
        string policyType;
        uint256 premiumAmount;
        string coverageArea;
        uint256 policyStartDate;
        uint256 policyEndDate;
        bool isActive;
        Claim[] claims;
    }

    address public admin;

    mapping(address => Policy[]) private userPolicies;
    mapping(string => address) private policyToOwner;

    address[] private allUsers;
    mapping(address => bool) private hasPolicy;

    event PolicyIssued(address indexed user, string indexed policyId);
    event ClaimAdded(address indexed user, string indexed policyId, string indexed claimId, uint256 amountClaimed);
    event ClaimApproved(address indexed user, string indexed policyId, string indexed claimId, uint256 amountApproved);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyPolicyHolder(string memory _policyId) {
        require(policyToOwner[_policyId] == msg.sender, "You do not own this policy");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function issuePolicyByAdmin(
        address _user,
        string memory _policyId,
        string memory _policyType,
        uint256 _premiumAmount,
        string memory _coverageArea,
        uint256 _durationInDays
    ) public onlyAdmin {
        Policy[] storage policies = userPolicies[_user];

        for (uint256 i = 0; i < policies.length; i++) {
            require(
                keccak256(bytes(policies[i].policyId)) != keccak256(bytes(_policyId)),
                "Policy ID already exists"
            );
        }

        Policy storage newPolicy = userPolicies[msg.sender].push(); // Allocate new empty policy in storage

        newPolicy.policyId = _policyId;
        newPolicy.policyType = _policyType;
        newPolicy.premiumAmount = _premiumAmount;
        newPolicy.coverageArea = _coverageArea;
        newPolicy.policyStartDate = block.timestamp;
        newPolicy.policyEndDate = block.timestamp + (_durationInDays * 1 days);
        newPolicy.isActive = true;

        userPolicies[_user].push(newPolicy);
        policyToOwner[_policyId] = _user;

        if (!hasPolicy[_user]) {
            hasPolicy[_user] = true;
            allUsers.push(_user);
        }

        emit PolicyIssued(_user, _policyId);
    }

    function addClaimToPolicy(
        string memory _policyId,
        string memory _claimId,
        uint256 _amountClaimed,
        string memory _insuredName,
        string memory _driverName,
        string memory _description,
        string memory _vehicleNumber,
        string memory _proforma,
        string memory _medicalRecords,
        string memory _accidentType
    ) public onlyPolicyHolder(_policyId) {
        Policy[] storage policies = userPolicies[msg.sender];
        bool added = false;

        for (uint i = 0; i < policies.length; i++) {
            if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
                require(policies[i].isActive, "Policy not active");

                for (uint j = 0; j < policies[i].claims.length; j++) {
                    require(
                        keccak256(bytes(policies[i].claims[j].claimId)) != keccak256(bytes(_claimId)),
                        "Claim ID already exists"
                    );
                }

                policies[i].claims.push(
                    Claim({
                        claimId: _claimId,
                        amountClaimed: _amountClaimed,
                        amountApproved: 0,
                        claimDate: block.timestamp,
                        approvalDate: 0,
                        insuredName: _insuredName,
                        driverName: _driverName,
                        vehicleNumber: _vehicleNumber,
                        description: _description,
                        proforma: _proforma,
                        medicalRecords: _medicalRecords,
                        isApproved: false,
                        accidentType: _accidentType
                    })
                );

                emit ClaimAdded(msg.sender, _policyId, _claimId, _amountClaimed);
                added = true;
                break;
            }
        }

        require(added, "Policy not found");
    }

    function approveClaimById(
        string memory _policyId,
        string memory _claimId,
        uint256 _amountApproved
    ) public onlyAdmin {
        address user = policyToOwner[_policyId];
        require(user != address(0), "Policy not found");

        Policy[] storage policies = userPolicies[user];
        bool found = false;

        for (uint i = 0; i < policies.length; i++) {
            if (keccak256(bytes(policies[i].policyId)) == keccak256(bytes(_policyId))) {
                for (uint j = 0; j < policies[i].claims.length; j++) {
                    if (keccak256(bytes(policies[i].claims[j].claimId)) == keccak256(bytes(_claimId))) {
                        require(!policies[i].claims[j].isApproved, "Already approved");
                        require(_amountApproved <= policies[i].claims[j].amountClaimed, "Too much approved");

                        policies[i].claims[j].amountApproved = _amountApproved;
                        policies[i].claims[j].isApproved = true;
                        policies[i].claims[j].approvalDate = block.timestamp;

                        emit ClaimApproved(user, _policyId, _claimId, _amountApproved);
                        found = true;
                        break;
                    }
                }
            }
        }

        require(found, "Claim not found");
    }

    function getMyPolicies() public view returns (Policy[] memory) {
        return userPolicies[msg.sender];
    }

    function getAllUsers() public view onlyAdmin returns (address[] memory) {
        return allUsers;
    }

    function getUserPolicies(address _user) public view onlyAdmin returns (Policy[] memory) {
        return userPolicies[_user];
    }
}

