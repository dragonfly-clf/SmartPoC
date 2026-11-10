4. Renounce Ownership

 Description

 The renounceOwnership function can be called accidentally by the admin leading to immediate renouncement of ownership to zero address after which any onlyOwner functions will not be callable which can be risky.

 Remediation

 It is advised that the Owner cannot call renounceOwnership without first transferring ownership to a different address. Additionally, if a multi-signature wallet is utilized, executing the renounceOwnership method for two or more users should be confirmed. Alternatively, the Renounce Ownership functionality can be disabled by overriding it. Refer this post for additional info- https://www.linkedin.com/posts/razzor_github-razzorsecrazzorsec-contracts- activity-6873251560864968705-HOS8

 Status

 Acknowledged

 Informational Issues

 