// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./ERC20.sol" as ERC20;
import "./Staking.sol" as Staking;

contract DAO {
    struct Deposit {
        uint256 allTokens;
        uint256 frozenToken;
        uint256 unfrozenTime;
    }

    struct Proposal {
        uint256 pEndTime;
        uint256 pTokenYes;
        uint256 pTokenNo;
        address pCallAddress;
        bool pStatus;
        bytes pCallData;
    }

    uint256 time;
    address public chairman;
    address public TOD;
    address public staking;

    Proposal[] allProposals;

    mapping(uint256 => mapping(address => bool)) voters;
    mapping(address => Deposit) deposits;

    event AddProposal(uint256 pId, bytes pCallData, address pCallAddress);
    event FinishProposal(bool quorum, bool result, bool success);

    constructor(uint256 _time) {
        require(_time >= 60, "DAO: _time must be over or equals 1 minute"); 
        time = _time;
        chairman = msg.sender;
    }

    /// @notice функция добавления депозита
    ///
    /// @dev вызывается функция transferFrom() на токене TOD
    /// @dev изменяется значение депозита для пользователя, вызвавшего функцию
    ///
    function addDeposit(uint256 _amount) external {
        require(TOD != address(0), "DAO: TOD is not defined");
        require(_amount > 0, "DAO: _amount must be over 0");
        require(ERC20.ERC20(TOD).transferFrom(msg.sender, address(this), _amount));
        deposits[msg.sender].allTokens += _amount;
    } 

    /// @notice функция вывода депозита
    ///
    /// @param _amount - количество токенов, выводимых из депозита
    ///
    /// @dev нельзя вывести депозит, пока не закончены все голосования, в которых он участвует
    /// @dev нельзя вывести из депозита больше токенов, чем в нём есть
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

    /// @notice функция добавления нового голосования
    ///
    /// @param _pCallData - закодированные сигнатура функции и аргументы
    /// @param _pCallAddress - адрес вызываемого контракта
    ///
    /// @dev только chairman может создавать новое голосование
    /// @dev добавляет новую структуру голосования Proposal в массив allProposals
    /// @dev вызывает прерывание, если _pCallAddress не токен или стейкинг, или он является address(0) или DAO
    /// @dev вызывает прерывание, если токен не привязан
    /// @dev вызывает событие AddProposal
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

    /// @notice Функция голосования
    ///
    /// @param _pId - id голосования
    /// @param _choice - голос за или против
    ///
    /// @dev вызывает прерывание, если голосующий не внёс депозит
    /// @dev вызывает прерывание, если голосование не существует
    /// @dev вызывает прерывание при попытке повторного голосования с одного адреса
    /// @dev вызывает прерывание, если время голосования истекло
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

    /// @notice Функция окончания голосования
    ///
    /// @param _pId - id голосования
    ///
    /// @dev вызывает прерывание, если голосование не существует
    /// @dev вызывает прерывание, если время голосования не истекло
    /// @dev вызывает прерывание, если голосование уже было завершено ранее
    ///
    /// @dev выставляет статус, что голосование завершено
    /// @dev проверяет, что набрался кворум
    /// @dev если набрался кворум количество токенов ЗА больше, количество токнов ПРОТИВ, вызывается функция
    /// @dev вызывает событие FinishProposal
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

    /// @notice функция для получения информации о депозите
    ///
    /// @return возвращает структуру deposit с информацией о депозите пользователя, вызвавшего функцию
    ///
    function getDeposit() external view returns (Deposit memory) {
        return deposits[msg.sender];
    }

    /// @notice Функция для получения списка всех голосований
    ///
    /// @return возвращает массив allProposals со всеми голосованиями
    ///
    function getAllProposal() external view returns (Proposal[] memory) {
        return allProposals;
    }

    /// @notice Функция для получения информации об одном голосовании по его id
    ///
    /// @param _pId - id голосования
    ///
    /// @dev вызывает прерывание, если такого id не существует
    ///
    /// @return возвращает одно голосование - структуру Proposal
    ///
    function getProposalByID(uint256 _pId) external view returns (Proposal memory) {
        require(_pId < allProposals.length, "DAO: proposal does not exist");
        return allProposals[_pId];
    }

    /// @notice Функция для привязки токена к DAO
    ///
    /// @param _TOD - адрес токена ERC20
    ///
    /// @dev вызывает прерывание, если sender не chairman, chairman не создатель токена или токен уже привязан
    ///
    function setTOD(address _TOD) public {
        require(msg.sender == chairman, "DAO: you are not a chairman");
        require(TOD == address(0), "DAO: TOD is already setted");
        require(ERC20.ERC20(_TOD).creator() == chairman, "DAO: chairman is not a creator of _TOD");
        TOD = _TOD;
    }

    /// @notice Функция для привязки контракта стейкинга к DAO
    ///
    /// @param _staking - адрес стейкинга
    ///
    /// @dev вызывает прерывание, если sender не chairman, chairman не создатель стейкинга или стейкинг уже привязан
    ///
    function setStaking(address _staking) public {
        require(msg.sender == chairman, "DAO: you are not a chairman");
        require(staking == address(0), "DAO: staking is already setted");
        require(Staking.Staking(_staking).creator() == chairman, "DAO: chairman is not a creator of _staking");
        staking = _staking;
    }
}
