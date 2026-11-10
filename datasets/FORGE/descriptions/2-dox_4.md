#### FSA - Fixed Swap Address

**Criticality** Minor / Informative

**Location** contracts/Twelve_Days_Of_Xmas.sol#L176

**Status** Unresolved

#### Description

The swap address is assigned once and it can not be changed. It is a common practice in

decentralized exchanges to create new swap versions. A contract that cannot change the

swap address may not be able to catch up to the upgrade. As a result, the contract will not

be able to migrate to a new liquidity pool pair or decentralized exchange.
```
   constructor () Auth(msg.sender) {
      router =
 IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
 //router address pcs v2
      WBNB = router.WETH();
      pair = IDEXFactory(router.factory()).createPair(WBNB,
 address(this));
      ...
      }

#### Recommendation

```
The team is advised to add the ability to change the pair and router address in order to

cover potential liquidity pool migrations. It would be better to support multiple pair

addresses so the token will be able to have the same behavior in all the decentralized

liquidity pairs.


-----

