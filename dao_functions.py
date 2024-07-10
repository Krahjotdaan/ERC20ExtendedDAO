from keys import WALLET_ADDRESS, DAO, w3


def dao_call_time():
    proposal_time = DAO.functions.time().call()
    print(f"proposal time: {proposal_time}")


def dao_call_chairman():
    chairman = DAO.functions.chairman().call()
    print(f"chairman: {chairman}")


def dao_call_tod():
    tod = DAO.functions.TOD().call()
    print(f"TOD: {tod}")


def dao_call_staking():
    staking = DAO.functions.staking().call()
    print(f"staking: {staking}")


def dao_get_deposit():
    deposit = DAO.functions.getDeposit().call()
    print(f"your deposit: {deposit}")


def dao_get_all_proposals():
    proposals = DAO.functions.getAllProposals().call()
    i = 1
    for pr in proposals:
        print(f"{i}. {pr}")
        i += 1


def dao_get_proposal_by_id():
    n = int(input("Введите номер голосования: "))
    proposal = DAO.functions.getProposalById(n).call()
    print(proposal)


def dao_add_deposit():
    amount = int(input("Укажите количество токенов, которое хотите внести: "))
    transaction = DAO.functions.addDeposit(amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    w3.eth.send_transaction(transaction)


def dao_withdraw_deposit():
    amount = int(input("Укажите количество токенов, которое хотите вывести: "))
    transaction = DAO.functions.withdrawDeposit(amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    w3.eth.send_transaction(transaction)


def dao_add_proposal():
    calldata = input("Введите данные вызова: ")
    calladdress = input("Введите адрес, на который будет совершен вызов функции: ")
    transaction = DAO.functions.withdrawDeposit(calldata, calladdress).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    w3.eth.send_transaction(transaction)


def dao_vote():
    id = int(input("Введите id голосования: "))
    tokens = int(input("Введите количество токенов, которыми хотите проголосовать: "))
    choice = int(input("Введите выбор (1 - за, 0 - против): "))
    if choice != 1 and choice != 0:
        choice = int(input("Введите выбор (1 - за, 0 - против): "))
    transaction = DAO.functions.vote(id, tokens, choice).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    w3.eth.send_transaction(transaction)


def dao_finish_proposal():
    id = int(input("Введите id голосования для завершения: "))
    transaction = DAO.functions.finishProposal(id).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    w3.eth.send_transaction(transaction)
    