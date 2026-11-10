#### MCM - Misleading Comment Messages


#### Description


The contract is using misleading comment messages. These comment messages do not


accurately reflect the actual implementation, making it difficult to understand the source


code. As a result, the users will not comprehend the source code's actual implementation.


The comment suggests that the `tokenBurner` address is assigned when the contract is


deployed in the constructor. However the `tokenBurner` address is not actually


assigned within the constructor.


#### Recommendation


The team is advised to carefully review the comment in order to reflect the actual


implementation. To improve code readability, the team should use more specific and


descriptive comment messages.


-----

