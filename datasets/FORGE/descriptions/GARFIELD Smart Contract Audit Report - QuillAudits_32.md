29. block.timestamp may not be reliable

 Description The Time contract uses the block.timestamp as part of the calculations and time checks. Nevertheless, timestamps can be slightly altered by miners to favor them in contracts that have logics that depend strongly on them. Consider taking into account this issue and warning the users that such a scenario could happen.

 0522


-----

###### Status: Acknowledged by the Auditee

 