5. Lack of contract existence check on call|Col2|
|---|---|
|Severity: Informational|Difcfiulty: High|
|Type: Data Validation|Finding ID: TOB-ONDO-5|
|Target: contracts/factory/MonoFactory.sol, contracts/factory/PolyFactory.sol, contracts/RegistryClient.sol||


##### Description
The factories and the registry client all have a multiexcall function, which is designed to
create batched calls to various target addresses. To do this, it uses the call opcode to
execute arbitrary calldata. If the target address is set to an incorrect address, the address
of an externally owned account (EOA), or the address of a contract that is subsequently
destroyed, a call to the target will still return true. However, the multiexcall functions
in the factories and the registry client do not include contract existence checks to account
for this behavior.
```
 function multiexcall(ExCallData[] calldata exCallData)
  external
  payable
  override
  onlyGuardian
  returns (bytes[] memory results)
 {
  results = new bytes[](exCallData.length);
  for (uint256 i = 0; i < exCallData.length; ++i) {
   (bool success, bytes memory ret) =
    address(exCallData[i].target).call{value: exCallData[i].value}(
     exCallData[i].data
    );
   require(success, "Call Failed");
   results[i] = ret;
  }
 }

```
_[Figure 5.1: The multiexcall function in MonoFactory.sol:#L120–L136](https://github.com/ondoprotocol/monopoly/blob/814cfcfa04a7bfa4ae3fa395cafa329767dc67ec/contracts/factory/MonoFactory.sol#L120-L136)_

The Solidity documentation includes the following warning:
```
 The low-level functions call, delegatecall and staticcall return true as their first
 return value if the account called is non-existent, as part of the design of the
 EVM. Account existence must be checked prior to calling if needed.

```
_Figure 5.2: A snippet of the Solidity documentation detailing unexpected behavior related to_
```
                    call

```
Trail of Bits 30 Ondo Finance Security Assessment


-----

##### Exploit Scenario
Bob, the guardian of the Ondo protocol contracts, uses the multiexcall function but
accidentally passes in an incorrect address that points to an EOA. As a result, the call
succeeds without executing any code.

##### Recommendations
Short term, implement a contract existence check before each call. Document the fact
that calling an EOA or self-destructed contract will still return true.

[Long term, carefully review the Solidity documentation, especially the “Warnings” section,](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)
[and the pitfalls of using low-level patterns.](https://blog.trailofbits.com/2018/09/05/contract-upgrade-anti-patterns/)

Trail of Bits 31 Ondo Finance Security Assessment


-----

|