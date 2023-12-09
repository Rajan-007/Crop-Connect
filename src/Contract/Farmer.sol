// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@1inch/token-plugins/contracts/interfaces/IERC20Plugins.sol";
import { Plugin } from "@1inch/token-plugins/contracts/Plugin.sol";
import { IERC20Plugins } from "@1inch/token-plugins/contracts/interfaces/IERC20Plugins.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IFarmingPlugin } from "./FarmerToken.sol";


contract FarmerLoanContract is Plugin {
    struct Farmer {
        string farmerName;
        uint256 farmerAadhaarNo;
        uint256 loanAmount;
        string reasonForLoan;
        bool isLoanApproved;
        uint256 approvalTime;
    }
    IERC20 public immutable rewardsToken;
    address public farmableToken = address(farmableToken);
    mapping(uint256 => Farmer) public farmers;
    uint256[] public farmerIndexes;
    address private organizer;

constructor(IERC20Plugins farmableToken_, IERC20 rewardsToken_)
    Plugin(farmableToken_)
{
    if (address(farmableToken_) == address(0)) revert("Farmable token address cannot be zero.");
    if (address(rewardsToken_) == address(0)) revert("Rewards token address cannot be zero.");
    rewardsToken = rewardsToken_;
   
}
function _updateBalances(address from, address to, uint256 amount) internal virtual override {
   
    IERC20Plugins(farmableToken).transferFrom(from, to, amount);
    rewardsToken.transferFrom(to, from, amount);
}


    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action.");
        _;
    }

    function applyLoan(
        string memory _farmerName,
        uint256 _farmerAadhaarNo,
        uint256 _loanAmount,
        string memory _reasonForLoan
    ) public {
        farmers[_farmerAadhaarNo] = Farmer(_farmerName, _farmerAadhaarNo, _loanAmount, _reasonForLoan, false, block.timestamp);
        farmerIndexes.push(_farmerAadhaarNo);
    }

    function getAllLoanDetails() public view returns (Farmer[] memory) {
        Farmer[] memory allFarmers = new Farmer[](farmerIndexes.length);
        for (uint256 i = 0; i < farmerIndexes.length; i++) {
            uint256 farmerAadhaarNo = farmerIndexes[i];
            Farmer memory loanEntity = farmers[farmerAadhaarNo];
            allFarmers[i] = loanEntity;
        }
        return allFarmers;
    }

    function approveLoan(uint256 _farmerAadhaarNo) public onlyOrganizer {
        farmers[_farmerAadhaarNo].isLoanApproved = true;
        farmers[_farmerAadhaarNo].approvalTime = block.timestamp;
    }

    function updateOrganizer(address _newOrganizer) external onlyOrganizer {
        organizer = _newOrganizer;
    }

    function verifyLoan(uint256 _farmerAadhaarNo) public view returns (Farmer memory) {
        return farmers[_farmerAadhaarNo];
    }


}
