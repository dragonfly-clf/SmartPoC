8. Lack of upper bound for fees and system parameters|Col2|
|---|---|
|Severity: Informational|Difcfiulty: High|
|Type: Data Validation|Finding ID: TOB-ONDO-8|
|Target: contracts/PSM.sol||


##### Description
The PSM contract’s setMintFee and setRedeemFee functions, used by privileged actors to
set optional minting and redeeming fees, do not have an upper bound on the fee amount
that can be set; therefore, a privileged actor could set minting and redeeming fees to any
value. Excessively high fees resulting from typos would likely not be noticed until they
cause disruptions in the system.
```
 289 * @notice Sets PSM's mint fee
 290 *
 291 * @param _mintFee new mint fee specified in basis points
 292 */
 293 function setMintFee(uint256 _mintFee) external onlyMono {
 294 mintFee = _mintFee;
 295 emit MintFeeSet(_mintFee);
 296  }
 297
 298 /**
 299 * @notice Sets PSM's redeem fee.
 300 *
 301 * @param _redeemFee new redem fee specified in basis points
 302 */
 303 function setRedeemFee(uint256 _redeemFee) external onlyMono {
 304 redeemFee = _redeemFee;
 305 emit RedeemFeeSet(_redeemFee);
 306  }

```
_[Figure 8.1: The setMintFee and setRedeemFee functions in PSM.sol#L289–306](https://github.com/ondoprotocol/monopoly/blob/814cfcfa04a7bfa4ae3fa395cafa329767dc67ec/contracts/PSM.sol#L289-L306)_

Additionally, a large number of system parameters throughout the Rewarder, Treasury,
```
PSM, and PolyMinter contracts are unbounded.

##### Recommendations
```
Short term, set upper limits for the minting and redeeming fees and for all the system
parameters that do not currently have upper bounds. The upper bounds for the fees
should be high enough to encompass any reasonable value but low enough to catch
mistakenly or maliciously entered values that would result in unsustainably high fees.

Trail of Bits 35 Ondo Finance Security Assessment