###### 6. Pragma Version not fixed


###### 7. Compiler version is too old


###### Slither


###### 10


###### 07

 07

 07

 08

 08

 09

 09

 09

 10


###### 11


###### Medium Severity Issues

 4. Improper error handling

 5. Tokens can be minted or burned

 Low Severity Issues

 6. Pragma Version not fixed

 7. Compiler version is too old

 Informational Issues

 8. Lack of unit tests

 Automated Tests


-----

##### Scope of the Audit

 Checked Vulnerabilities

###### vulnerabilities that we considered:

 Re-entrancy

 Timestamp Dependence

 Gas Limit and Loops

 DoS with Block Gas Limit

 Transaction-Ordering Dependence

 Use of tx.origin

 Exception disorder

 Gasless send

 Balance equality


###### Implicit visibility level

 audits.quillhash.com


-----

### Techniques and Methods

###### The overall quality of code. Use of best practices.
 mentioned in the whitepaper. Implementation of BEP-20 token standards. Efficient use of gas. Code is safe from re-entrancy and other vulnerabilities. 

 smart contracts.

 Structural Analysis
 structured in a way that will not result in future problems.

 Static Analysis


###### vulnerabilities. In this step, a series of automated tools are used to test the

 Manual analysis or review of code was done to identify new vulnerabilities or verify the vulnerabilities found during the static analysis. Contracts were completely manually analysed, their logic was checked and compared with the one described in the whitepaper. Besides, the results of the automated

 In this step, we have checked the behaviour of smart contracts in production. Checks were done to know how much gas gets consumed and the possibilities of optimization of code to reduce gas consumption.


###### Tools and Platforms used for Audit
 analysis, Theo.

 audits.quillhash.com


-----

|Risk-level|Description|
|---|---|
|High|A high severity issue or vulnerability means that your smart contract can be exploited. Issues on this level are critical to the smart contract’s performance or functionality, and we recommend these issues be fixed before moving to a live environment.|
|Medium|The issues marked as medium severity usually arise because of errors and deficiencies in the smart contract code. Issues on this level could potentially bring problems, and they should still be fixed.|
|Low|Low-level severity issues can cause minor impact and or are just warnings that can remain unfixed for now. It would be better to fix these issues at some point in the future.|
|Informational|These are severity issues that indicate an improvement request, a general question, a cosmetic or documentation error, or a request for information. There is low-to-no impact.|

|Type|High|Medium|Low|Informational|
|---|---|---|---|---|
|Open|0|0|0|1|
|Acknowledged|0|0|0|0|
|Closed 3 2 1 1|3|2|1||


### Issue Categories

###### Risk-level Description

 High

 environment.

 Medium

 be fixed.

 Low

 the future.


###### These are severity issues that indicate an improvement request, a general question, a cosmetic or documentation error, or a request for information. There is low-to-no impact.

 Medium Low Informational

 0 0 1

 0 0 0


###### Closed 3

 audits.quillhash.com


-----

|V|Date|Commit hash|Note|
|---|---|---|---|
|1|November|https://bscscan.com/address/0x82a3cd29ba ab1523a011b442ed37e9a86f824b6e#code||
|2|November|https://docs.google.com/document/d/ 12qaWXg7qHySOObTacHKqD8VxTJdC xxmWgyEd-0DbsaQ/edit?usp=sharing|T99_ Fixed.sol|
|3|November|https://docs.google.com/document/d/ 1tw7EVihpIuvf-Y5y5fTiisIP3wm34V OkpI_8t9qFDxA/edit?usp=sharing|T99_ Fixed2.sol|
|4|November|https://bscscan.com/address/ 0xB4a8Aed9b705D780B29D4 8cCa2A6Ca9d63feaf14#code||


### Introduction

###### Nov 10, 2021 - Nov 21,2021 audit for an BEP20 token smart contract -

 https://bscscan.com/

 V Date

 1 November

 2 November

 3 November


###### 1tw7EVihpIuvf-Y5y5fTiisIP3wm34V Fixed2.sol

 OkpI_8t9qFDxA/edit?usp=sharing

 https://bscscan.com/address/

 0xB4a8Aed9b705D780B29D4

 8cCa2A6Ca9d63feaf14#code


###### audits.quillhash.com


-----

|Line|Code|
|---|---|
|146-164|function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { require(tokenBlacklist[msg.sender] == false); require(_to != address(0)); require(_value <= balances[_from]); require(_value <= allowed[_from][msg.sender]); balances[_from] = balances[_from].sub(_value); balances[_to] = balances[_to].add(_value); allowed[_from][msg.sender] = allowed[_from] [msg.sender].sub(_value); emit Transfer(_from, _to, _value); return true; } function approve(address _spender, uint256 _value) public returns (bool) { allowed[msg.sender][_spender] = _value; emit Approval(msg.sender, _spender, _value); return true; }|


### Issues Found

##### A. Contract – T99(TNN)Token

 High severity issues

###### functionalities

 Line Code

 146-164 returns (bool) {
   require(_to != address(0));
 [msg.sender].sub(_value);   emit Transfer(_from, _to, _value);


######  function approve(address _spender, uint256 _value) public returns
   allowed[msg.sender][_spender] = _value;   emit Approval(msg.sender, _spender, _value);

 Any blacklisted user can pass the check by using approve and
 require(tokenBlacklist[from] == false); in  function. Document the extent and requirements of


###### blacklist functionality.

 Status: Closed. Issues has been fixed

 audits.quillhash.com


-----

