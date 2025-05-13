// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract InsuranceContract {
    struct Policy {
        uint256 policyId;
        address customer;
        string policyType;
        uint256 premiumAmount;
        uint256 coverageAmount;
        uint256 policyStartDate;
        uint256 policyEndDate;
        bool isActive;
        bool isClaimed;
    }

    address public admin;
    uint256 private nextPolicyId = 1;
    mapping(uint256 => Policy) public policies;
    mapping(address => uint256[]) public customerPolicies;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier onlyPolicyHolder(uint256 _policyId) {
        require(policies[_policyId].customer == msg.sender, "Not the policy owner.");
        _;
    }

    constructor() {
        admin = msg.sender; // Set contract deployer as admin
    }

    // Function to issue a policy (Only Admin)
    function issuePolicy(
        address _customer,
        string memory _policyType,
        uint256 _premiumAmount,
        uint256 _coverageAmount,
        uint256 _durationInDays
    ) public onlyAdmin {
        uint256 policyId = nextPolicyId++;
        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (_durationInDays * 1 days);

        policies[policyId] = Policy(
            policyId,
            _customer,
            _policyType,
            _premiumAmount,
            _coverageAmount,
            startDate,
            endDate,
            true,
            false
        );

        customerPolicies[_customer].push(policyId);
    }

    // Function to get policy details
    function getPolicy(uint256 _policyId) public view returns (Policy memory) {
        return policies[_policyId];
    }

    // Function to claim insurance (Only the customer)
    function claimInsurance(uint256 _policyId) public onlyPolicyHolder(_policyId) {
        require(policies[_policyId].isActive, "Policy is not active.");
        require(!policies[_policyId].isClaimed, "Insurance already claimed.");

        policies[_policyId].isClaimed = true;
    }

    // Function for admin to deactivate a policy
    function deactivatePolicy(uint256 _policyId) public onlyAdmin {
        policies[_policyId].isActive = false;
    }
}
