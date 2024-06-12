// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./Staking.sol" as Staking;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 indexed amount);
    event Approval(address indexed owner, address indexed spender, uint256 indexed amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address from, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title Mintable ERC20 for Extended DAO
/// @author https://github.com/Krahjotdaan
/// @dev Open Source under MIT License
///
contract ERC20 is IERC20 {

    /// @notice token total emission
    uint256 _totalSupply = 0;

    /// @notice token name
    string _name;

    /// @notice token symbol
    string _symbol;

    /// @notice extended DAO
    address public dao;

    /// @notice official DAO staking contract
    address public staking;

    /// @notice token creator
    address public creator;

    /// @notice number of zeros after the integer part
    uint8 _decimals;

    /// @notice contains balances for each token holder 
    mapping(address => uint256) balances;

    /// @notice contains permissions to dispose of tokens for each operator
    mapping(address => mapping(address => uint256)) allowed;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 amount, address dao_) {
        require(dao_.code.length > 0, "ERC20: dao_ is not a contract");
        
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = amount;
        balances[msg.sender] = amount;
        dao = dao_;
        creator = msg.sender;
    }

    /// @return token name
    function name() public view returns (string memory) {
        return _name;
    }

    /// @return token symbol
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /// @return number of zeros after the integer part
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /// @return token total emission
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @return account balance to its address
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /// @return amount of tokens that spender can spend from owner`s address
    function allowance(address _owner, address spender) public view returns (uint256) {
        return allowed[_owner][spender];
    }

    /// @notice function of issuing permission to spend of tokens
    ///
    /// @param spender - sender gives him permission to dispose of tokens
    /// @param amount - permitted amount of tokens for disposal by spender
    ///
    /// @dev causes interrupt if balance of sender < amount
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true 
    ///
    function approve(address spender, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "ERC20: not enough tokens");
        require(amount > 0, "ERC20: amount must be over 0");
        allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /// @notice function of increasing of amount of tokens for disposal by spender
    ///
    /// @param spender - sender gives him permission to dispose of tokens
    /// @param amount - increases permitted number of tokens by amount
    ///
    /// @dev causes interrupt if balance of sender < permitted number of tokens + amount
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= allowed[msg.sender][spender] + amount, "ERC20: not enough tokens");
        require(amount > 0, "ERC20: amount must be over 0");
        allowed[msg.sender][spender] += amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /// @notice function of decreasing of amount of tokens for disposal by spender
    ///
    /// @param spender - sender gives him permission to dispose of tokens
    /// @param amount - decreases permitted number of tokens by amount
    ///
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        require(amount > 0, "ERC20: amount must be over 0");
        allowed[msg.sender][spender] -= amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /// @notice function of tokens transfer
    ///
    /// @param to - recipient of tokens
    /// @param amount - amount of sent tokens
    ///
    /// @dev causes interrupt if sender`s balance < amount
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "ERC20: not enough tokens");
        require(amount > 0, "ERC20: amount must be over 0");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    /// @notice function of tokens transfer by operator
    ///
    /// @param from - token holder from whose address tokens are sent
    /// @param to - recipient of tokens
    /// @param amount - amount of sent tokens
    ///
    /// @dev decreasing of amount of tokens for disposal by sender
    /// @dev causes interrupt if permitted amount of tokens for sender < amount
    /// @dev causes interrupt if balance of token holder < amount
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function transferFrom(address from, address to, uint256 amount) public returns (bool) { 
        require(allowed[from][msg.sender] >= amount, "ERC20: no permission to spend");
        require(balances[from] >= amount, "ERC20: not enough tokens");
        require(amount > 0, "ERC20: amount must be over 0");

        allowed[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Approval(from, msg.sender, allowed[from][msg.sender]);
        emit Transfer(from, to, amount);

        return true;
    }

    /// @notice function of token emission
    ///
    /// @param to - address where tokens will be minted
    /// @param amount - amount of issued tokens
    ///
    /// @dev causes interrupt if sender is not DAO or staking
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function mint(address to, uint256 amount) external returns (bool) {
        require(msg.sender == dao || msg.sender == staking, "ERC20: no permission to coinage");
        require(amount > 0, "ERC20: amount must be over 0");

        balances[to] += amount;
        _totalSupply += amount;
        
        emit Transfer(address(0), to, amount);

        return true;
    }

    /// @notice function of token burning
    ///
    /// @param amount - amount of burned tokens
    ///
    /// @dev decreases total emission
    /// @dev causes interrupt if sender`s balance < amount
    /// @dev causes interrupt if amount <= 0
    ///
    /// @return true
    ///
    function burn(uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "ERC20: not enough tokens");
        require(amount > 0, "ERC20: amount must be over 0");

        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        balances[address(0)] += amount;
        
        emit Transfer(msg.sender, address(0), amount);

        return true;
    }

    /// @notice function of staking setting
    ///
    /// @param _staking - address of staking contract
    ///
    /// @dev causes interrupt if sender is not a creator of this contract
    /// @dev causes interrupt if staking creator is not a creator of this contract
    /// @dev causes interrupt if staking is already setted
    ///
    function setStaking(address _staking) external {
        require(msg.sender == creator, "ERC20: sender is not a creator");
        require(Staking.Staking(_staking).creator() == creator, "ERC20: creator of staking is not a creator of TOD");
        require(staking == address(0), "ERC20: staking is already setted");

        staking = _staking;
    }
}
