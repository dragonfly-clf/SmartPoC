## TIPS : 누락된 Event가 있습니다

다음은 Event가 누락된 함수들의 목록입니다.

**Function** **Expected Event** **Emitted Event** **Omitted Event**

contract/ARMYDOLLAR

**transferFrom** **Transfer, Approval** **Transfer** **Approval**

Event가 없는 경우, 블록체인에 정확한 값의 기록 여부를 실시간으로 파악하는데

어려움이 있습니다. 이 경우, application에서 해당 값의 변경 여부 및 해당 함수 호출

여부를 파악하기 어렵습니다.

따라서, 해당 함수에서 발생하는 변화에 해당하는 Event를 추가하시는 것을 추천

드립니다.

COPYRIGHT 2021. HAECHI AUDIT. all rights reserved 8

|Function|Expected Event|Emitted Event|Omitted Event|
|---|---|---|---|
|contract/ARMYDOLLAR||||
|transferFrom|Transfer, Approval|Transfer|Approval|