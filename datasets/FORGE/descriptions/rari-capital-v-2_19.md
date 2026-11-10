## QSP-20 Experimental features should not be used on Mainnet deployments

#### Severity: Informational

 Status: Mitigated

###### File(s) affected: Several contracts

 Description: Until solidity 0.6.0, the ABIEncoderV2 feature is still technically in experimental state. Although there are no known security risks associated with it, these features should be used judiciously.


###### Recommendation:


###### Upgrade the contracts to a more recent solidity version such as 0.5.16 or 0.6.6. All contracts that depend upon ABIEncoderV2 functionality should be tested thoroughly.


###### Update: From dev team: "We have locked all Solidity version pragmas to 0.5.17."

