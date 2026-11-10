##### SWC-127 | Arbitrary Jump With Function Type Variable

```
function checkSellEligibility(address user) public view returns(bool){

```
```
if(UserLastSellTimeStamp[user]==0) {

```
```
return true;

```

**Recommendation**

###### The use of Assembly should be minimal. Do not allow users to assign arbitrary values to function type variables.

```
  }

```
**Recommendation**

###### The use of Assembly should be minimal. Do not allow users to assign arbitrary values to function type variables.


-----

