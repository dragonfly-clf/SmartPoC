Low Level Calls (2 Items)
This contract uses low level calls, which may be unsafe.

```
**Function** **Severity** **Relevant Snippet**
```
Issue Location in Code function sendValue(address
                     payable recipient, uint256
Low level call in amount) internal
Address.sendValue(address, returns(bool){
uint256) Severity
(SlappyCat.sol#91-97): : High require(address(this).balance
    - (success) = >= amount, "Address:
recipient.call{value: insufficient balance");
amount}()   // solhint-disable-next(SlappyCat.sol#95) line avoid-low-level-calls,
                     avoid-call-value
                       (bool success, ) =
                     recipient.call{ value: amount
                     }("");
                       return success;
                     }
Issue Location in Code function
                     _functionCallWithValue(address
Low level call in target, bytes memory data,
Address._functionCallWithV uint256 weiValue, string
alue(address,bytes,uint256 memory errorMessage) private
,string) Severity returns (bytes memory) {
(SlappyCat.sol#116-137): : High
    - require(isContract(target),
(success,returndata) = "Address: call to nontarget.call{value: contract");
weiValue}(data)   // solhint-disable-next(SlappyCat.sol#120) line avoid-low-level-calls

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|Issue Location in Code Low level call in Address.sendValue(address, uint256) (SlappyCat.sol#91-97): - (success) = recipient.call{value: amount}() (SlappyCat.sol#95)|Severity : High|function sendValue(address payable recipient, uint256 amount) internal returns(bool){ require(address(this).balance >= amount, "Address: insufficient balance"); // solhint-disable-next- line avoid-low-level-calls, avoid-call-value (bool success, ) = recipient.call{ value: amount }(""); return success; }|


-----

```
  (bool success, bytes
memory returndata) =
target.call{ value: weiValue
}(data);
  if (success) {
    return returndata;
  } else {
    // Look for revert
reason and bubble it up if
present
    if (returndata.length
> 0) {
      // The easiest way
to bubble the revert reason is
using memory via assembly
      // solhintdisable-next-line no-inlineassembly
      assembly {
        let
returndata_size :=
mload(returndata)
        revert(add(32,
returndata), returndata_size)
      }
    } else {
revert(errorMessage);
    }
  }
}

```
|Col1|Col2|(bool success, bytes memory returndata) = target.call{ value: weiValue }(data); if (success) { return returndata; } else { // Look for revert reason and bubble it up if present if (returndata.length > 0) { // The easiest way to bubble the revert reason is using memory via assembly // solhint- disable-next-line no-inline- assembly assembly { let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size) } } else { revert(errorMessage); } } }|
|---|---|---|


-----

```
 