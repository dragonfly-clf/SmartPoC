####  Low Severity Issues

###### 2. Event emitting

**Issue:**

###### • With each transfer to a burning wallet, its balance increases, but the

total supply decreases. And there is no emitting of decreasing total
supply event.

**Recommendation:**

Revise burn logic of the contract and add event emitting.