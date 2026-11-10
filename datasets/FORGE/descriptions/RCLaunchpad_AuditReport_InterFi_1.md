Note ⚠

```
v Active smart contract owner: 0xb645fe26043501b918ddce8252a35edbd816ef51

v **_Be aware that active smart contract owner privileges constitute an elevated impact to_**

**_smart contract’s safety and security._**

v Smart contract owner can change the launchpad service fees. 2% fees set.


### ✅

```
  function changeLaunchpadServiceFee(uint256 fee) public onlyOwner {

```
```
    launchPadServiceFeePercentage = fee;
  }

```
```
  string private _name = "RCLaunchpad";
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
   require(c >= a, "SafeMath: addition overflow");
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
   return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
   require(c / a == b, "SafeMath: multiplication overflow");
   return c;
function div(uint256 a, uint256 b) internal pure returns (uint256) {
   return div(a, b, "SafeMath: division by zero");
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
   return mod(a, b, "SafeMath: modulo by zero");

### ⚠

```
v Active smart contract owner: 0xb645fe26043501b918ddce8252a35edbd816ef51

v **_Be aware that active smart contract owner privileges constitute an elevated impact to_**

**_smart contract’s safety and security._**

v Smart contract owner can change the launchpad service fees. 2% fees set.
```
function changeLaunchpadServiceFee(uint256 fee) public onlyOwner {
    launchPadServiceFeePercentage = fee;
}

```

-----

v Smart contract owner can withdraw BNBs and tokens. Smart contract owner can call “BNB

Withdrawal” even after the testing.
```
  function withdrawTokensEmergency(address recipient,uint256 amount) public onlyOwner{
    token.transfer(recipient, amount);
  }
  function withdrawBNBEmergency() public onlyOwner { // only for testing purposes
     sendValue( payable(owner()), address(this).balance);
  }
}

```
v The smart contract has **_low severity issue which may or may not create any functional_**

```
}
function withdrawBNBEmergency() public onlyOwner { // only for testing purposes
   sendValue( payable(owner()), address(this).balance);
}

```
v The smart contract has **_low severity issue which may or may not create any functional_**

vulnerability.

{

"resource": " /RCLaunchpad.sol",

"owner": "_generated_diagnostic_collection_name_#0",

**"severity": 8, (! Low Severity)**

**"** **Expected pragma, import directive or contract/interface/library definition”,**

"source": "solc",

}


-----

## 