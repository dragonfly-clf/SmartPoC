pragma solidity ^0.8.26;

contract WalletEvents {
    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
    event RequirementChanged(uint newRequirement);
    event Deposit(address _from, uint value);
    event SingleTransact(address owner, uint value, address to, bytes data, address created);
    event MultiTransact(address owner, bytes32 operation, uint value, address to, bytes data, address created);
    event ConfirmationNeeded(bytes32 operation, address initiator, uint value, address to, bytes data);
}

abstract contract WalletAbi {
    function revoke(bytes32 _operation) external virtual;
    function changeOwner(address _from, address _to) external virtual;
    function addOwner(address _owner) external virtual;
    function removeOwner(address _owner) external virtual;
    function changeRequirement(uint _newRequired) external virtual;
    function isOwner(address _addr) external view virtual returns (bool);
    function hasConfirmed(bytes32 _operation, address _owner) external view virtual returns (bool);
    function setDailyLimit(uint _newLimit) external virtual;
    function execute(address _to, uint _value, bytes calldata _data) external virtual returns (bytes32 o_hash);
    function confirm(bytes32 _h) external virtual returns (bool o_success);
}

contract WalletLibrary is WalletEvents {
    struct PendingState {
        uint yetNeeded;
        uint ownersDone;
        uint index;
    }

    struct Transaction {
        address to;
        uint value;
        bytes data;
    }

    modifier onlyowner {
        if (isOwner(msg.sender))
            _;
    }

    modifier onlymanyowners(bytes32 _operation) {
        if (confirmAndCheck(_operation))
            _;
    }

    fallback() external payable {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {}

    function initMultiowned(address[] memory _owners, uint _required) public only_uninitialized {
        m_numOwners = _owners.length + 1;
        m_owners[1] = uint(uint160(msg.sender));
        m_ownerIndex[uint(uint160(msg.sender))] = 1;
        for (uint i = 0; i < _owners.length; ++i)
        {
            m_owners[2 + i] = uint(uint160(_owners[i]));
            m_ownerIndex[uint(uint160(_owners[i]))] = 2 + i;
        }
        m_required = _required;
    }

    function revoke(bytes32 _operation) external {
        uint ownerIndex = m_ownerIndex[uint(uint160(msg.sender))];
        if (ownerIndex == 0) return;
        uint ownerIndexBit = 2**ownerIndex;
        PendingState storage pending = m_pending[_operation];
        unchecked {
            if (pending.ownersDone & ownerIndexBit > 0) {
                pending.yetNeeded++;
                pending.ownersDone -= ownerIndexBit;
                emit Revoke(msg.sender, _operation);
            }
        }
    }

    function changeOwner(address _from, address _to) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        if (isOwner(_to)) return;
        uint ownerIndex = m_ownerIndex[uint(uint160(_from))];
        if (ownerIndex == 0) return;

        clearPending();
        m_owners[ownerIndex] = uint(uint160(_to));
        m_ownerIndex[uint(uint160(_from))] = 0;
        m_ownerIndex[uint(uint160(_to))] = ownerIndex;
        emit OwnerChanged(_from, _to);
    }

    function addOwner(address _owner) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        if (isOwner(_owner)) return;

        clearPending();
        if (m_numOwners >= c_maxOwners)
            reorganizeOwners();
        if (m_numOwners >= c_maxOwners)
            return;
        m_numOwners++;
        m_owners[m_numOwners] = uint(uint160(_owner));
        m_ownerIndex[uint(uint160(_owner))] = m_numOwners;
        emit OwnerAdded(_owner);
    }

    function removeOwner(address _owner) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        uint ownerIndex = m_ownerIndex[uint(uint160(_owner))];
        if (ownerIndex == 0) return;
        if (m_required > m_numOwners - 1) return;

        m_owners[ownerIndex] = 0;
        m_ownerIndex[uint(uint160(_owner))] = 0;
        clearPending();
        reorganizeOwners();
        emit OwnerRemoved(_owner);
    }

    function changeRequirement(uint _newRequired) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        if (_newRequired > m_numOwners) return;
        m_required = _newRequired;
        clearPending();
        emit RequirementChanged(_newRequired);
    }

    function getOwner(uint ownerIndex) external view returns (address) {
        return address(uint160(m_owners[ownerIndex + 1]));
    }

    function isOwner(address _addr) public view returns (bool) {
        return m_ownerIndex[uint(uint160(_addr))] > 0;
    }

    function hasConfirmed(bytes32 _operation, address _owner) external view returns (bool) {
        PendingState storage pending = m_pending[_operation];
        uint ownerIndex = m_ownerIndex[uint(uint160(_owner))];

        if (ownerIndex == 0) return false;

        uint ownerIndexBit = 2**ownerIndex;
        return !(pending.ownersDone & ownerIndexBit == 0);
    }

    function initDaylimit(uint _limit) public only_uninitialized {
        m_dailyLimit = _limit;
        m_lastDay = today();
    }

    function setDailyLimit(uint _newLimit) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        m_dailyLimit = _newLimit;
    }

    function resetSpentToday() external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        m_spentToday = 0;
    }

    modifier only_uninitialized { if (m_numOwners > 0) revert(); _; }

    function initWallet(address[] memory _owners, uint _required, uint _daylimit) public only_uninitialized {
        initDaylimit(_daylimit);
        initMultiowned(_owners, _required);
    }

    function kill(address _to) external onlymanyowners(keccak256(abi.encodePacked(msg.data))) {
        selfdestruct(payable(_to));
    }

    function execute(address _to, uint _value, bytes calldata _data) external onlyowner returns (bytes32 o_hash) {
        if ((_data.length == 0 && underLimit(_value)) || m_required == 1) {
            address created;
            if (_to == address(0)) {
                created = create(_value, _data);
            } else {
                (bool success, ) = _to.call{value: _value}(_data);
                if (!success) revert();
            }
            emit SingleTransact(msg.sender, _value, _to, _data, created);
        } else {
            o_hash = sha256(abi.encodePacked(msg.data, block.number));
            if (m_txs[o_hash].to == address(0) && m_txs[o_hash].value == 0 && m_txs[o_hash].data.length == 0) {
                m_txs[o_hash].to = _to;
                m_txs[o_hash].value = _value;
                m_txs[o_hash].data = _data;
            }
            if (!confirm(o_hash)) {
                emit ConfirmationNeeded(o_hash, msg.sender, _value, _to, _data);
            }
        }
    }

    function create(uint _value, bytes memory _code) internal returns (address o_addr) {
    }

    function confirm(bytes32 _h) public onlymanyowners(_h) returns (bool o_success) {
        if (m_txs[_h].to != address(0) || m_txs[_h].value != 0 || m_txs[_h].data.length != 0) {
            address created;
            if (m_txs[_h].to == address(0)) {
                created = create(m_txs[_h].value, m_txs[_h].data);
            } else {
                (bool success, ) = m_txs[_h].to.call{value: m_txs[_h].value}(m_txs[_h].data);
                if (!success) revert();
            }

            emit MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data, created);
            delete m_txs[_h];
            return true;
        }
    }

    function confirmAndCheck(bytes32 _operation) internal returns (bool) {
        uint ownerIndex = m_ownerIndex[uint(uint160(msg.sender))];
        if (ownerIndex == 0) return false;

        PendingState storage pending = m_pending[_operation];
        if (pending.yetNeeded == 0) {
            pending.yetNeeded = m_required;
            pending.ownersDone = 0;
            pending.index = m_pendingIndex.length;
            m_pendingIndex.push(_operation);
        }
        uint ownerIndexBit = 2**ownerIndex;
        if (pending.ownersDone & ownerIndexBit == 0) {
            emit Confirmation(msg.sender, _operation);
            if (pending.yetNeeded <= 1) {
                delete m_pendingIndex[pending.index];
                delete m_pending[_operation];
                return true;
            }
            else
            {
                unchecked {
                    pending.yetNeeded--;
                }
                pending.ownersDone |= ownerIndexBit;
            }
        }
        return false;
    }

    function reorganizeOwners() private {
        uint free = 1;
        while (free < m_numOwners)
        {
            while (free < m_numOwners && m_owners[free] != 0) free++;
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function underLimit(uint _value) internal onlyowner returns (bool) {
        if (today() > m_lastDay) {
            m_spentToday = 0;
            m_lastDay = today();
        }
        unchecked {
            if (m_spentToday + _value >= m_spentToday && m_spentToday + _value <= m_dailyLimit) {
                m_spentToday += _value;
                return true;
            }
        }
        return false;
    }

    function today() private view returns (uint) { return block.timestamp / 1 days; }

    function clearPending() internal {
        uint length = m_pendingIndex.length;

        for (uint i = 0; i < length; ++i) {
            delete m_txs[m_pendingIndex[i]];

            if (m_pendingIndex[i] != bytes32(0))
                delete m_pending[m_pendingIndex[i]];
        }

        delete m_pendingIndex;
    }

    uint public m_required;
    uint public m_numOwners;
    uint public m_dailyLimit;
    uint public m_spentToday;
    uint public m_lastDay;
    uint[256] m_owners;
    uint constant c_maxOwners = 250;
    mapping(uint => uint) m_ownerIndex;
    mapping(bytes32 => PendingState) m_pending;
    bytes32[] m_pendingIndex;
    mapping (bytes32 => Transaction) m_txs;
}