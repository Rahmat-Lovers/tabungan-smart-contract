// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function allowance(
        address owner,
        address _spender
    ) external returns (uint256);
}

contract Lock {
    IERC20 private token;
    mapping(address => address) private acceptorAddress;
    mapping(address => bool) private isSettedAcceptorAddress;
    mapping(address => bool) private isAcceptedByAcceptor;
    mapping(address => string) private names;
    mapping(address => uint256) private balances;
    mapping(address => uint256) private unlockAtBalance;
    mapping(address => uint256) private unlockAtTime;
    mapping(address => bool) private disabledUnlockAtBalance;
    mapping(address => bool) private disabledUnlockAtTime;
    mapping(address => bool) private disabledAcceptor;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function serverTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function setAcceptor(address _addr) public payable returns (bool) {
        if (!isSettedAcceptorAddress[msg.sender]) {
            isSettedAcceptorAddress[msg.sender] = true;
            acceptorAddress[msg.sender] = _addr;
            return true;
        }
        return false;
    }

    function disableAcceptor() public payable returns (bool) {
        if (disabledAcceptor[msg.sender] != true) {
            disabledAcceptor[msg.sender] = true;
            return true;
        }
        return false;
    }

    function isAcceptorDisabled() public view returns (bool) {
        return disabledAcceptor[msg.sender] == true;
    }

    function disableUnlockAtBalance() public payable returns (bool) {
        if (disabledUnlockAtBalance[msg.sender] != true) {
            disabledUnlockAtBalance[msg.sender] = true;
            return true;
        }
        return false;
    }

    function isUnlockAtBalanceDisabled() public view returns (bool) {
        return disabledUnlockAtBalance[msg.sender] == true;
    }

    function disableUnlockAtTIme() public payable returns (bool) {
        if (disabledUnlockAtTime[msg.sender] != true) {
            disabledUnlockAtTime[msg.sender] = true;
            return true;
        }
        return false;
    }

    function isUnlockAtTimeDisabled() public view returns (bool) {
        return disabledUnlockAtTime[msg.sender] == true;
    }

    function getTimeUnlocked() public view returns (uint256) {
        return unlockAtTime[msg.sender];
    }

    function canWithdraw() public view returns (bool) {
        return
            (disabledAcceptor[msg.sender] != true &&
                isAcceptedByAcceptor[msg.sender]) ||
            (disabledUnlockAtBalance[msg.sender] != true &&
                unlockAtBalance[msg.sender] > 0 &&
                getBalance() >= unlockAtBalance[msg.sender]) ||
            (disabledUnlockAtTime[msg.sender] != true &&
                unlockAtTime[msg.sender] != 0 &&
                block.timestamp >= unlockAtTime[msg.sender]);
    }

    function setName(string memory name) public payable returns (bool) {
        names[msg.sender] = name;
        return true;
    }

    function setTargetBalance(uint256 amount) public payable returns (bool) {
        if (unlockAtBalance[msg.sender] == 0) {
            unlockAtBalance[msg.sender] = amount;
            return true;
        }
        return false;
    }

    function getTargetBalance() public view returns (uint256) {
        return unlockAtBalance[msg.sender];
    }

    function setTargetTime(uint256 unixtime) public payable returns (bool) {
        if (unlockAtTime[msg.sender] == 0) {
            unlockAtTime[msg.sender] = unixtime;
            return true;
        }
        return false;
    }

    function getName(address _addr) public view returns (string memory) {
        if (bytes(names[_addr]).length == 0) {
            return "Anonymous";
        } else {
            return names[_addr];
        }
    }

    function accept(address _addr) public payable {
        require(acceptorAddress[_addr] == msg.sender);
        isAcceptedByAcceptor[_addr] = true;
    }

    function getAcceptor() public view returns (address) {
        return acceptorAddress[msg.sender];
    }

    function accepted() public view returns (bool) {
        return isAcceptedByAcceptor[msg.sender];
    }

    function deposit(uint256 amount) public payable {
        require(amount > 0, "Harus lebih besar dari 0");
        require(amount <= token.balanceOf(msg.sender), "Dana tidak cukup");
        require(
            amount <= token.allowance(msg.sender, address(this)),
            "Tidak diizinkan"
        );
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public payable {
        require(
            acceptorAddress[msg.sender] != address(0),
            "Harus menyetel acceptor terlebih dahulu"
        );
        require(isAcceptedByAcceptor[msg.sender], "Harus disetujui acceptor");
        require(amount <= getBalance(), "Dana tidak cukup");
        isAcceptedByAcceptor[msg.sender] = false;

        token.transfer(msg.sender, amount);
    }
}
