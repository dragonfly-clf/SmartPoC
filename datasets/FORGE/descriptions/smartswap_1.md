#### CCF - Contradictory Contract Functionality


#### Description


The `DP2PTokenLegacyUSDT` contract is specifically designed to interact with the

`USDT` (Tether) token for handling the deal functionalities. Despite this implication, the

`startDeal` function within the contract does not enforce the use of the USDT token; it

accepts any token address provided by the user as the `deal.token` parameter. This


design allows for the possibility of initiating deals with any ERC20 token, not just `USDT .`


The result is a discrepancy between the contract's name and its actual functionality, as it is


capable of handling transactions with tokens other than `USDT, which could mislead`


users and stakeholders.


#### Recommendation


It is recommended to reconsider the contract's functionality to align with its naming


convention. If the purpose is to handle deals exclusively with the USDT token, the contract


should be modified to utilize a fixed USDT token address that cannot be altered by the user


inputs. This could involve hardcoding the USDT token address into the contract or providing


-----

it via a constructor or initializer that sets it as a constant or immutable state variable. By


doing so, the contract will enforce its specific use case with USDT, preventing any


ambiguity and ensuring that users interact with the contract as intended.


-----

