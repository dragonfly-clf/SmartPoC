## MAJOR : Owner 가 사용자의 token 의 전송을 제한할 수 있습니다.

 (Found - v.1.0)

[https://etherscan.io/address/0x6e571032eb3d09e5bd049cc3f4786b8708eaaedb#code#L124]

_ARMYDOLLAR#transferWithLocking() 함수는_ 특정 주소에게 token 을 전송하고, 일정

기간동안 token 의 전송을 제한하는 함수입니다.

하지만 Contract Owner 가 _ARMYDOLLAR#transferWithLocking() 함수의 input parameter 에_

전송을 제한할 주소와 0 을 넣고 함수를 실행시키면 토큰을 보내지 않고 사용자의 token

전송을 제한할 수 있습니다.

COPYRIGHT 2021. HAECHI AUDIT. all rights reserved 7


-----

