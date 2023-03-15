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

    function allowance(address owner, address _spender) external returns(uint256);
}

contract Lock {
    IERC20 private token;
    mapping(address => address) private acceptorAddress;
    mapping(address => bool) private isSettedAcceptorAddress;
    mapping(address => bool) private isAcceptedByAcceptor;
    mapping(address => string) private names;
    mapping(address => uint256) private balances;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
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

    function setName(string memory name) public payable returns(bool) {
        names[msg.sender] = name;
        return true;
    }

    function getName(address _addr) public view returns(string memory) {
        if (bytes(names[_addr]).length == 0) {
            return "Anonymous";
        } else {
            return names[_addr];
        }
    }

    function accept(address _addr) public payable {
        require(acceptorAddress[_addr] == msg.sender);
        isAcceptedByAcceptor[msg.sender] = true;
    }

    function deposit(uint amount) public payable {
        require(amount > 0, "Harus lebih besar dari 0");
        require(amount <= token.balanceOf(msg.sender), "Dana tidak cukup");
        require(amount <= token.allowance(msg.sender, address(this)), "Tidak diizinkan");
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
