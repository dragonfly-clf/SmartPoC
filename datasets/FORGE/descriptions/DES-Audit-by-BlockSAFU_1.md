Medium-risk 1 medium-risk code issue found Should be fixed, could bring problems.

Potentially semantic imprecision amount of tokenomic. Solidity can’t take decimal in amount, if the
number is decimal in division result, solidity will read as imprecision number, Token Scanner also
read this algorithm as a minting event. Recommendation is doing multiply first before division and
using Tax Denominator for avoid imprecision decimal amount.

function _tokenTransfer(

address sender, address
recipient, uint256
tAmount, bool takeFee
) private {

if (_tOwned[sender] > tAmount) {

_tOwned[sender] -= tAmount;
} else {

_tOwned[sender] = 0; }
uint256 currentRate = _getRate(); uint256 rAmount =
tAmount * currentRate; _rOwned[sender] =
_rOwned[sender] - rAmount;
uint256 rate; if
(takeFee) {

_shareTransfer( sender, fundAddress,

(tAmount / 100) * otherFee,
currentRate
);
_nftTransfer( sender, fundAddress,

(tAmount / 100) * nftFee,
currentRate
);
_takeTransfer(

sender, burnAddress, (tAmount /
100) * burnFee, currentRate
);
_reflectFee(

(rAmount / 100) * dividendFee,
(tAmount / 100) * dividendFee );
rate = fundFee + dividendFee + otherFee + burnFee +
nftFee;

}
uint256 recipientRate = 100 - rate;
_takeTransfer( sender, recipient, (tAmount /
100) * recipientRate, currentRate


-----

);
}

### 