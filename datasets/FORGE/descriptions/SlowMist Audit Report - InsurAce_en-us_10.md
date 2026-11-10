#### 4.3.3.5 FlashLoan attack risk

###### Unstake is judged by >= when there are already voting tasks. If claimsAssessorMinUnstakeTime is 0,

 then there will be a issue of using flashloan to vote.

  contracts/claim/Claim.sol


**function unstake(address insurTokenAddress, uint256 insurAmount) external payable whenNotPaused nonReentrant {**


require(insurTokenAddress != address(0), "USTK: 1");


address payable assessor = _msgSender();


ClaimReward(crw).recalculateAssessor(assessor);


bool canUnstake = false;


###### 33