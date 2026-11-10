4. Early token unlocks

 Description

 The releaseTime is checked to confirm it’s not zero but does not check to see if releaseTime is greater than contractCreatedTime.

  function setRealeaseTime(uint256 _time) external onlyOwner{     require(_time != 0, "Should not be Zero");     releaseTime = _time;  }

 This would mean the claim function can be manipulated to dispense more tokens much earlier than expected if the owner sets it that way.  Also, salesEndTime can be manipulated in the same way to pass the check:

   require(block.timestamp > contractCreatedTime + saleEndTime, ...);

 Remediation

 Ensure the arithmetic checks are not easily manipulated to avoid privileged users gaming the system.

 Status

 Acknowledged

 