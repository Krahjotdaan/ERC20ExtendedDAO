// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./ERC20.sol" as ERC20;
import "./Staking.sol" as Staking;

/// @title Extended decentralized autonomous organization with mintable ERC20 and official staking contract
/// @author https://github.com/Krahjotdaan
/// @dev Open Source under MIT License
///
contract DAO {

    /// @notice struct of DAO member`s deposit
    /// @param allTokens - tokens that DAO member can use for votings
    /// @param frozenTokens - tokens that DAO member used in current voting
    /// @param unfrozenTime - time when DAO member will be able to use frozenTokens again
    ///
    struct Deposit {
        uint256 allTokens;
        uint256 frozenToken;
        uint256 unfrozenTime;
    }

    /// @notice struct of proposal
    /// @param pEndTime - proposal end time
    /// @param pTokenYes - amount of tokens that used for voting "for"
    /// @param pTokenNo - amount of tokens that used for voting "against"
    /// @param pCallAddress - address of contract where it is called function
    /// @param pStatus - shows whether proposal is completed or not
    /// @param pCallData - encoded signature and arguments of called function
    ///
    struct Proposal {
        uint256 pEndTime;
        uint256 pTokenYes;
        uint256 pTokenNo;
        address pCallAddress;
        bool pStatus;
        bytes pCallData;
    }

    /// @notice time allotted for proposal
    uint256 time;
    /// @notice creator of DAO
    address public chairman;
    /// @notice mintable ERC20
    /// @dev can only be binded once
    address public TOD;
    /// @notice official DAO staking contract
    /// @dev can only be binded once
    address public staking;

    /// @notice array of structs Proposal for all proposals
    Proposal[] allProposals;

    /// @notice contains confirmation of the fact of voting in all proposals for each DAO member
    mapping(uint256 => mapping(address => bool)) voters;
    /// @notice contains structs Deposit for each DAO member
    mapping(address => Deposit) deposits;

    event AddProposal(uint256 pId, bytes pCallData, address pCallAddress);
    event FinishProposal(bool quorum, bool result, bool success);

    constructor(uint256 _time) {
        require(_time >= 60, "DAO: _time must be over or equals 1 minute"); 
        time = _time;
        chairman = msg.sender;
    }

    /// @notice function of deposit addition
    ///
    /// @param _amount - amount of tokens that sender adds to his deposit
    ///
    /// @dev calls function transferFrom() on TOD contract
    /// @dev causes interrupt if TOD is address(0) or _amount <= 0
    ///
    function addDeposit(uint256 _amount) external {
        require(TOD != address(0), "DAO: TOD is not defined");
        require(_amount > 0, "DAO: _amount must be over 0");
        require(ERC20.ERC20(TOD).transferFrom(msg.sender, address(this), _amount));
        deposits[msg.sender].allTokens += _amount;
    } 

    /// @notice function of deposit withdrawal
    ///
    /// @param _amount - amount of tokens that sender withdraws from his deposit
    ///
    /// @dev DAO member cannot withdraw frozen tokens until all proposals in which he participates has ended
    /// @dev causes interrupt if _amount over then amount of unfrozen tokens
    ///
    function withdrawDeposit(uint256 _amount) external {
        require(_amount > 0, "DAO: _amount must be over 0");
        Deposit storage deposit = deposits[msg.sender];
        require(deposit.allTokens - deposit.frozenToken >= _amount, "DAO: not enough tokens");

        if (deposit.frozenToken > 0 && deposit.unfrozenTime < block.timestamp) {
            deposit.frozenToken = 0;
            deposit.unfrozenTime = 0;
        }

        require(ERC20.ERC20(TOD).transfer((msg.sender), _amount));
        deposit.allTokens -= _amount;
    }

    /// @notice function of new proposal addition
    ///
    /// @param _pCallData - encoded signature and arguments of called function
    /// @param _pCallAddress - address of contract where it is called function
    ///
    /// @dev only chairman can create new proposal
    /// @dev causes interrupt if _pCallAddress is address(0) or DAO or it is not TOD or staking
    /// @dev causes interrupt if TOD does not linked
    ///
    function addProposal(bytes calldata _pCallData, address _pCallAddress) external {
        require(TOD != address(0), "DAO: TOD is not defined");
        require(_pCallAddress != address(0), "DAO: _pCallAddress is address(0)");
        require(_pCallAddress != address(this), "DAO: _pCallAddress is DAO");
        require(_pCallAddress == address(TOD) || _pCallAddress == address(staking), "DAO: _pCallAddress is not address of TOD or staking");
        require(msg.sender == chairman, "DAO: you are not a chairman");

        allProposals.push(
            Proposal(
                block.timestamp + time,
                0,
                0,
                _pCallAddress,
                false,
                _pCallData
            )
        );

        emit AddProposal(allProposals.length - 1, _pCallData, _pCallAddress);
    }

    /// @notice function of voting 
    ///
    /// @param _pId - id of proposal
    /// @param _choice - vote "for" or "against"
    ///
    /// @dev causes interrupt if _tokens <= 0 or DAO member`s deposit < _tokens
    /// @dev causes interrupt if proposal does not exist
    /// @dev causes interrupt if DAO member has already voted
    /// @dev causes interrupt if proposal time is over
    ///
    function vote(uint256 _pId, uint256 _tokens, bool _choice) external {
        require(_tokens > 0, "DAO: _tokens must be over 0");
        Deposit memory deposit = deposits[msg.sender];
        require(_pId < allProposals.length, "DAO: proposal does not exist");
        Proposal memory proposal = allProposals[_pId];
        require(_tokens <= deposit.allTokens, "DAO: not enough tokens");
        require(block.timestamp < proposal.pEndTime, "DAO: proposal time is over");
        require(!voters[_pId][msg.sender], "DAO: you have already voted");

        voters[_pId][msg.sender] = true;

        if (_choice) {
            allProposals[_pId].pTokenYes += _tokens;
        } 
        else {
            allProposals[_pId].pTokenNo += _tokens;
        }

        deposits[msg.sender].frozenToken = _tokens;

        if (proposal.pEndTime > deposit.unfrozenTime) {
            deposits[msg.sender].unfrozenTime = proposal.pEndTime;
        }
    }

    /// @notice function of proposal ending
    ///
    /// @param _pId - id of proposal
    ///
    /// @dev causes interrupt if proposal does not exist
    /// @dev causes interrupt if proposal is still going on
    /// @dev causes interrupt if proposal is already completed
    ///
    /// @dev displays status that proposal is completed
    /// @dev checks that quorum is reached
    /// @dev if quorum is reached and the amount of tokens "for" is greater than the amount of tokens "against", the function is called
    ///
    function finishProposal(uint256 _pId) external {
        require(_pId < allProposals.length, "DAO: proposal does not exist");
        Proposal memory proposal = allProposals[_pId];
        require(block.timestamp > proposal.pEndTime, "DAO: proposal is still going on");
        require(!proposal.pStatus, "DAO: proposal is already completed");

        allProposals[_pId].pStatus = true;

        bool quorum = (proposal.pTokenYes + proposal.pTokenNo) > ERC20.ERC20(TOD).totalSupply() / 2 + 1;
        bool result = proposal.pTokenYes > proposal.pTokenNo;
        bool success = false;

        if (quorum && result) {
            (success, ) = proposal.pCallAddress.call(proposal.pCallData);
            require(success);
        }

        emit FinishProposal(quorum, result, success);
    }

    /// @notice function of receiving info about sender`s deposit
    ///
    /// @return returns sender`s struct Deposit 
    ///
    function getDeposit() external view returns (Deposit memory) {
        return deposits[msg.sender];
    }

    /// @notice function of receiving array of all proposals
    ///
    /// @return returns array allProposals
    ///
    function getAllProposal() external view returns (Proposal[] memory) {
        return allProposals;
    }

    /// @notice function of receiving info about proposal by its id
    ///
    /// @param _pId - id of proposal
    ///
    /// @dev causes interrupt if proposal does not exist
    ///
    /// @return returns one struct Proposal
    ///
    function getProposalByID(uint256 _pId) external view returns (Proposal memory) {
        require(_pId < allProposals.length, "DAO: proposal does not exist");
        return allProposals[_pId];
    }

    /// @notice function of binding TOD to DAO
    ///
    /// @param _TOD - address of mintable ERC20
    ///
    /// @dev causes interrupt if sender is not a chairman, creator of TOD is not a chairman or TOD is already binded
    ///
    function setTOD(address _TOD) public {
        require(msg.sender == chairman, "DAO: you are not a chairman");
        require(TOD == address(0), "DAO: TOD is already setted");
        require(ERC20.ERC20(_TOD).creator() == chairman, "DAO: chairman is not a creator of _TOD");
        TOD = _TOD;
    }

    /// @notice function of binding staking to DAO
    ///
    /// @param _staking - address of staking
    ///
    /// @dev causes interrupt if sender is not a chairman, creator of staking is not a chairman or staking is already binded
    ///
    function setStaking(address _staking) public {
        require(msg.sender == chairman, "DAO: you are not a chairman");
        require(staking == address(0), "DAO: staking is already setted");
        require(Staking.Staking(_staking).creator() == chairman, "DAO: chairman is not a creator of _staking");
        staking = _staking;
    }
}
