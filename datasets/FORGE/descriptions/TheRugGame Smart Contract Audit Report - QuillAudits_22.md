2. Funds stuck and transfer to incorrect address

 Description

 The funds were being sent to the TRG contract instead of the STRG contract. This issue persisted in the function bribe() of THERUGGAME contract and the rugLoser() function of the Factory contract. Due to this funds were being stuck in the TRG contract.

 Recommendation

 It was recommended and fixed by the team developer to send the funds to correct contract i.e. is the STRG contract on line: 171.

 Status

 Resolved

 