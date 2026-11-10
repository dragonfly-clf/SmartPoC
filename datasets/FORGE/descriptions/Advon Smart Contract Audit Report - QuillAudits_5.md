6. Input sanitization/Parity checks

 Description

 Although underflows and overflows are checked internally in solidity versions >0.8.0, multiple logical arithmetic checks would be needed in the codebase dependent on the client. setReleaseTime(), setSupply_Team_Allocation(), setBuyandSellTax(), setTokenPrice() are likely pivots to exploit this vulnerability.  When eligible resellers are added, the NumberofResellers variable is incremented by 1. The function does not check if the address to be added is already an eligibleReseller so the NumberofResellers variable can be incremented to the limit of uint256. Due to the capacity of uint256 it is unlikely to result in a denial of service but it still is an issue of improper accounting.

 Remediation

  - setReleaseTime() has been described in the exploit scenario above  - setSupply_Team_Allocation() can be done with hardcoded values because the whitepaper clearly    specifies how much will be allocated to Founder, Marketing, Ecosystem, and Staking,   - setBuyandSellTax() if implemented properly could lead to users swapping and losing all their    tokens because there is currently no cap to how much tax would be deducted per transaction,   - setTokenPrice() can be updated to any value without prior notice by the owner but with the values    corresponding to the epoch stated in the whitepaper a struct can be implemented to avoid    mistaken allocations of price by the owner.  - setProcessingFee() and setNetworkingFee() also should be checked, updated or removed if not in    use.  - Add checks for address existence before updating

 Status

 Acknowledged

 