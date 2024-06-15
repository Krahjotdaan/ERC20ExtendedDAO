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
    function mint(address to, uint256 amount) external returns (bool);
}

/// @title Official staking contract for Extended DAO
/// @author https://github.com/Krahjotdaan
/// @dev Open Source under MIT License
///
contract Staking {

    /// @notice stake struct for one token holder
    ///
    /// @param tokenValue - amount of tokens in stake
    /// @param stakeTime - time when stake was created
    /// @param unstakeTime - time when token holder will be able to withdraw his stake
    /// @param rewardTime - period of time for which the reward is granted
    /// @param rewardValue - percent from tokenValue that granted every rewardTime
    ///
    struct StakeStruct {
        uint256 tokenValue;
        uint256 stakeTime;
        uint256 unstakeTime;
        uint256 rewardTime;
        uint256 rewardValue;
    }
    
    /// @notice mintable ERC20
    address public TOD;

    /// @notice extended DAO
    address public dao;

    /// @notice staking contract creator
    address public creator;

    /// @notice percent from stake value that granted every rewardPeriod
    uint256 public rewardPercent = 0;

    /// @notice period of time for which the reward is granted
    uint256 public rewardPeriod = 0;

    /// @notice contains StakeStruct for each token holder
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

    /// @notice function of stake creation
    ///
    /// @param token - address of TOD
    /// @param value - amount of tokens to stake
    /// @param stakePeriod - time that must pass from the moment of stake creation for the holder to be able to withdraw his stake
    ///
    /// @dev causes interrupt if token is not TOD
    /// @dev causes interrupt if sender already has a stake
    /// @dev causes interrupt if value <= 0 or stakePeriod <= 0
    /// @dev causes interrupt if DAO has not setted rewardPercent or rewardPeriod
    ///
    function makeStake(address token, uint256 value, uint256 stakePeriod) external {
        require(token == TOD, "Staking: token is not TOD");
        require(stakes[msg.sender].tokenValue == 0, "Staking: you already have a stake");
        require(value > 0, "Staking: value must be over 0");
        require(stakePeriod > 0, "Staking: stakePeriod must be over 0");
        require(rewardPercent != 0 && rewardPeriod != 0, "Staking: dao has not setted rewardPercent and/or rewardPeriod");

        require(IERC20(token).transferFrom(msg.sender, address(this), value));
        stakes[msg.sender] = StakeStruct(value, block.timestamp, block.timestamp + stakePeriod, rewardPeriod, rewardPercent);

        emit Stake(msg.sender, value, block.timestamp + stakePeriod);
    }

    /// @notice function of unstaking and withdrawal stake and reward
    ///
    /// @dev causes interrupt if sender has not a stake
    /// @dev causes interrupt if current time <= unstake time
    ///
    function unstake() external {
        require(stakes[msg.sender].tokenValue > 0, "Staking: you don't have a stake for this token");
        require(block.timestamp > stakes[msg.sender].unstakeTime, "Staking: it's not yet time to take the steak out");
        
        uint256 reward = calculateReward(msg.sender);
        require(IERC20(TOD).transfer(msg.sender, stakes[msg.sender].tokenValue));
        require(IERC20(TOD).mint(msg.sender, reward));

        emit Unstake(msg.sender, stakes[msg.sender].tokenValue + reward);
        
        delete stakes[msg.sender];
    }

    /// @notice function of setting new reward percent
    ///
    /// @param percent - new reward percent
    ///
    /// @dev causes interrupt if sender is not DAO
    /// @dev causes interrupt if percent <= 0
    ///
    function setRewardPercent(uint256 percent) external {
        require(msg.sender == dao, "Staking: sender is not dao");
        require(percent > 0, "Staking: new percent must be over 0");

        rewardPercent = percent;
    }

    /// @notice function of setting new reward period
    ///
    /// @param time - new reward period
    ///
    /// @dev causes interrupt if sender is not DAO
    /// @dev causes interrupt if time <= 0
    ///
    function setRewardPeriod(uint256 time) external {
        require(msg.sender == dao, "Staking: sender is not dao");
        require(time > 0, "Staking: new time must be over 0");

        rewardPeriod = time;
    }

    /// @notice function of reward calculation
    ///
    /// @param owner - address of stake owner
    ///
    /// @dev counts how many periods of rewarding passed since stake creation and granted reward the same number of times
    /// @dev granting of reward according to the formula reward += (stake + reward) / 100 * rewardValue
    /// @dev values of stakes[owner].rewardValue and stakes[owner].rewardTime are values of rewardPercent and rewardPeriod at the moment of stake creation
    ///
    /// @return reward - total reward for this stake
    ///
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
