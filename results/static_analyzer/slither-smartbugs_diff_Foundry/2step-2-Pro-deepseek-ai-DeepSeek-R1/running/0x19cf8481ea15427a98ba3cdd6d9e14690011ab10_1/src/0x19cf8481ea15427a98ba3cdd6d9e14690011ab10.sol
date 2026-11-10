pragma solidity ^0.8.26;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

interface MigrationAgent {
    function migrateFrom(address _from, uint256 _value) external;
}

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        unchecked {
            uint c = a * b;
            assert(a == 0 || c / a == b);
            return c;
        }
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        unchecked {
            uint c = a / b;
            assert(a == b * c + a % b);
            return c;
        }
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        unchecked {
            return a - b;
        }
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        unchecked {
            uint c = a + b;
            assert(c>=a && c>=b);
            return c;
        }
    }

    function max64(uint64 a, uint64 b) internal view returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal view returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal view returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal view returns (uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}

abstract contract StandardToken is ERC20, SafeMath {
    mapping(address => uint) public balances;
    mapping(address => uint) public balancesRAW;
    mapping (address => mapping (address => uint)) public allowed;

    event Minted(address receiver, uint amount);

    function isToken() public view returns (bool weAre) {
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];
        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}

contract daoPOLSKAtokens {
    string public name = "DAO POLSKA TOKEN version 1";
    string public symbol = "DPL";
    uint8 public constant decimals = 18;

    address public owner;
    address public migrationMaster;
    uint256 public otherchainstotalsupply = 1.0 ether;
    uint256 public supplylimit = 10000.0 ether;
    uint256 public totalSupply = 0.0 ether;
    address public Chain1 = address(0);
    address public Chain2 = address(0);
    address public Chain3 = address(0);
    address public Chain4 = address(0);
    address public migrationAgent = 0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);
    event UpdatedTokenInformation(string newName, string newSymbol);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event receivedEther(address indexed _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    struct sendTokenAway {
        StandardToken coinContract;
        uint amount;
        address recipient;
    }
    mapping(uint => sendTokenAway) public transfers;
    uint public numTransfers = 0;

    mapping (address => uint256) public balances;
    mapping (address => uint256) public balancesRAW;
    mapping (address => mapping (address => uint256)) public allowed;

    bool public supplylimitset = false;
    bool public otherchainstotalset = false;
    uint public tokenCreationRate = 1000;
    uint public bonusCreationRate = 1000;
    uint public CreationRate = 1761;
    uint256 public constant oneweek = 36000;
    uint256 public fundingEndBlock = 5433616;
    bool public funding = true;
    bool public refundstate = false;
    bool public migratestate = false;

    constructor() {
        owner = msg.sender;
        migrationMaster = msg.sender;
    }

    function setSupply(uint256 supplyLOCKER) public {
        if (msg.sender != owner) revert();
        if (supplylimitset != false) revert();
        supplylimitset = true;
        unchecked {
            supplylimit = supplyLOCKER * (10 ** uint256(decimals));
        }
    }

    function setotherchainstotalsupply(uint256 supplyLOCKER) public {
        if (msg.sender != owner) revert();
        if (supplylimitset != false) revert();
        otherchainstotalset = true;
        unchecked {
            otherchainstotalsupply = supplyLOCKER * (10 ** uint256(decimals));
        }
    }

    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
        return false;
    }

    function burn(uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) revert();
        unchecked {
            balances[msg.sender] -= _value;
            totalSupply -= _value;
        }
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        if (balances[_from] < _value) revert();
        if (_value > allowed[_from][msg.sender]) revert();
        unchecked {
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            totalSupply -= _value;
        }
        emit Burn(_from, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            unchecked {
                balances[msg.sender] -= _value;
                balances[_to] += _value;
            }
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { 
            return false; 
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            unchecked {
                balances[_to] += _value;
                balances[_from] -= _value;
                allowed[_from][msg.sender] -= _value;
            }
            emit Transfer(_from, _to, _value);
            return true;
        } else { 
            return false; 
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    receive() external payable {
        if(funding){ 
            emit receivedEther(msg.sender, msg.value);
            unchecked {
                balances[msg.sender] += msg.value;
            }
        } else revert();
    }

    function setTokenInformation(string memory _name, string memory _symbol) public {
        if (msg.sender != owner) revert();
        name = _name;
        symbol = _symbol;
        emit UpdatedTokenInformation(name, symbol);
    }

    function setChainsAddresses(address chainAd, int chainnumber) public {
        if (msg.sender != owner) revert();
        if(chainnumber==1){Chain1=chainAd;}
        if(chainnumber==2){Chain2=chainAd;}
        if(chainnumber==3){Chain3=chainAd;}
        if(chainnumber==4){Chain4=chainAd;}		
    }

    function DAOPolskaTokenICOregulations() external pure returns(string memory wow) {
        return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
    }

    function sendTokenAw(address StandardTokenAddress, address receiver, uint amount) public {
        if (msg.sender != owner) revert();
        sendTokenAway storage t = transfers[numTransfers];
        t.coinContract = StandardToken(StandardTokenAddress);
        t.amount = amount;
        t.recipient = receiver;
        t.coinContract.transfer(receiver, amount);
        numTransfers++;
    }

    function createDaoPOLSKAtokens(address holder) public payable {
        if (!funding) revert();
        if (msg.value == 0) revert();
        if (msg.value > (supplylimit - totalSupply) / CreationRate) revert();

        uint numTokensRAW = msg.value;
        uint numTokens;
        unchecked {
            numTokens = msg.value * CreationRate;
            totalSupply += numTokens;
            balances[holder] += numTokens;
            balancesRAW[holder] += numTokensRAW;
        }
        emit Transfer(address(0), holder, numTokens);

        uint256 additionalTokens;
        unchecked {
            uint256 percentOfTotal = 12;
            additionalTokens = numTokens * percentOfTotal / (100);
            totalSupply += additionalTokens;
            balances[migrationMaster] += additionalTokens;
        }
        emit Transfer(address(0), migrationMaster, additionalTokens);
    }

    function setBonusCreationRate(uint newRate) public {
        if(msg.sender == owner) {
            bonusCreationRate = newRate;
            CreationRate = tokenCreationRate + bonusCreationRate;
        }
    }

    function FundsTransfer() external {
        if(funding) revert();
        payable(owner).send(address(this).balance);
    }

    function PartialFundsTransfer(uint SubX) external {
        if (msg.sender != owner) revert();
        payable(owner).send(address(this).balance - SubX);
    }

    function turnrefund() external {
        if (msg.sender != owner) revert();
        refundstate = !refundstate;
    }

    function fundingState() external {
        if (msg.sender != owner) revert();
        funding = !funding;
    }

    function turnmigrate() external {
        if (msg.sender != migrationMaster) revert();
        migratestate = !migratestate;
    }

    function finalize() external {
        if (block.number <= fundingEndBlock + 8 * oneweek) revert();
        funding = false;	
        refundstate = !refundstate;
        if (msg.sender == owner) {
            payable(owner).send(address(this).balance);
        }
    }

    function migrate(uint256 _value) external {
        if (migratestate) revert();
        if (_value == 0) revert();
        if (_value > balances[msg.sender]) revert();
        unchecked {
            balances[msg.sender] -= _value;
            totalSupply -= _value;
            totalMigrated += _value;
        }
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        emit Migrate(msg.sender, migrationAgent, _value);
    }

    function refundTRA() external {
        if (funding) revert();
        if (!refundstate) revert();
        uint DAOPLTokenValue = balances[msg.sender];
        uint ETHValue = balancesRAW[msg.sender];
        if (ETHValue == 0) revert();
        balancesRAW[msg.sender] = 0;
        unchecked {
            totalSupply -= DAOPLTokenValue;
        }
        emit Refund(msg.sender, ETHValue);
        payable(msg.sender).transfer(ETHValue);
    }

    function preICOregulations() external pure returns(string memory wow) {
        return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
    }
}