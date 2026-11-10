#### Reusable Code Segments

**Criticality** low

**Location** https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c
ode#L614,L659

##### Description

There are similar code segments in the application. The creation of the round
structure is a good example. Both in the startGame and buyTicket functions, a
```
round structure is created. The only different variation is the prizePool.

```
|Criticality|low|
|---|---|
|Location|https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c ode#L614,L659|

```
Round storage curRound = rounds[currentRound];
curRound.ticketPrice = startPrice;
curRound.prizePool = 0;
curRound.startTimestamp = block.timestamp;
curRound.closeTimestamp = block.timestamp + roundPeriod;
curRound.additionalTime = increaseTimePerTicket;

```

##### Recommendation

The author could create reusable functions that will make the contract code smaller
and more readable.