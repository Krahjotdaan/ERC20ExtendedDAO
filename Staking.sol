// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

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
    function mint(address to, uint256 amount) external;
}

struct StakeStruct {
    uint256 tokenValue;
    uint256 stakeTime;
    uint256 unstakeTime;
    uint256 rewardTime;
    uint256 rewardValue;
}

contract Staking {
    
    address TOD;
    address public dao;
    address public creator;
    uint256 public rewardPercent = 0;
    uint256 public rewardPeriod = 0;
    mapping(address => StakeStruct) public stakes;

    event Stake(address from, uint256 value, uint256 unstakeTime);
    event Unstake(address to, uint256 value);

    constructor(address _dao, address _TOD) {
        require(_dao.code.length > 0, "Staking: _dao is not a contract");
        require(_TOD.code.length > 0, "Staking: _TOD is not a contract");
        dao = _dao;
        TOD = _TOD;
        creator = msg.sender;
    }

    function makeStake(address token, uint256 value, uint256 unstakeTime) external {
        require(token == TOD, "Staking: token is not TOD");
        require(stakes[msg.sender].tokenValue == 0, "Staking: you already have a stake");
        require(unstakeTime > block.timestamp, "Staking: that time has passed");
        require(IERC20(token).allowance(msg.sender, address(this)) >= value, "Staking: not enough approved tokens to staking. Call function 'approve' to grant permission to staking to dispose of tokens");
        require(rewardPercent != 0 && rewardPeriod != 0, "Staking: dao has not setted rewardPercent and/or rewardPeriod");

        IERC20(token).transferFrom(msg.sender, address(this), value);
        stakes[msg.sender] = StakeStruct(value, block.timestamp, unstakeTime, rewardPeriod, rewardPercent);

        emit Stake(msg.sender, value, unstakeTime);
    }

    function unstake() external {
        require(stakes[msg.sender].tokenValue > 0, "Staking: you don't have a stake for this token");
        require(block.timestamp > stakes[msg.sender].unstakeTime, "Staking: it's not yet time to take the steak out");
        
        uint256 reward = calculateReward(msg.sender);
        IERC20(TOD).transfer(msg.sender, stakes[msg.sender].tokenValue);
        IERC20(TOD).mint(msg.sender, reward);

        emit Unstake(msg.sender, stakes[msg.sender].tokenValue + reward);
        stakes[msg.sender].tokenValue = 0;
    }

    function setRewardPercent(uint256 percent) external {
        require(msg.sender == dao, "Staking: sender is not dao");
        require(percent > 0, "Staking: new percent must be over 0");
        rewardPercent = percent;
    }

    function setRewardPeriod(uint256 time) external {
        require(msg.sender == dao, "Staking: sender is not dao");
        require(time > 0, "Staking: new time must be over 0");
        rewardPeriod = time;
    }

    function calculateReward(address owner) internal view returns(uint256) {
        uint256 time = (block.timestamp - stakes[owner].stakeTime) / stakes[owner].rewardTime;
        uint256 reward = 0;
        uint256 stake = stakes[owner].tokenValue;
        
        for (uint256 i = 0; i < time; i++) {
            reward += (stake + reward) / 100 * stakes[owner].rewardValue;
        }

        return reward;
    }
}
