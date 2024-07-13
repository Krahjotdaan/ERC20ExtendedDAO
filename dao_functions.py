from keys import WALLET_ADDRESS, DAO, w3, PRIVATE_KEY


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
    print(f"your deposit:")
    print(f"all tokens: {deposit[0]}")
    print(f"frozen tokens: {deposit[1]}")
    print(f"unfrozen time: {deposit[2]}")


def dao_get_all_proposals():
    proposals = DAO.functions.getAllProposal().call()
    i = 1
    for pr in proposals:
        print(f"{i}.")
        print(f"end time: {pr[0]}")
        print(f"tokens 'yes': {pr[1]}")
        print(f"tokens 'no': {pr[2]}")
        print(f"call address: {pr[3]}")
        print(f"status: {pr[4]}")
        print(f"call data: {pr[5].hex()}\n")
        i += 1


def dao_get_proposal_by_id():
    try:
        n = int(input("Введите номер голосования: "))
    except ValueError:
        n = int(input("Введите номер голосования: "))

    proposal = DAO.functions.getProposalById(n).call()
    print(f"end time: {proposal[0]}")
    print(f"tokens 'yes': {proposal[1]}")
    print(f"tokens 'no': {proposal[2]}")
    print(f"call address: {proposal[3]}")
    print(f"status: {proposal[4]}")
    print(f"call data: {proposal[5].hex()}")


# Чтобы пополнить депозит, сначала надо вызвать функцию approve на контракте ERC20 и передать в аргументы адрес DAO и значение, на которое хотите пополнить депозит
def dao_add_deposit():
    try:
        amount = int(input("Укажите количество токенов, которое хотите внести: "))
    except ValueError:
        amount = int(input("Укажите количество токенов, которое хотите внести: "))

    transaction = DAO.functions.addDeposit(amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def dao_withdraw_deposit():
    try:
        amount = int(input("Укажите количество токенов, которое хотите вывести: "))
    except ValueError:
        amount = int(input("Укажите количество токенов, которое хотите вывести: "))

    transaction = DAO.functions.withdrawDeposit(amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def dao_add_proposal():
    calldata = input("Введите данные вызова: ")
    calladdress = input("Введите адрес, на который будет совершен вызов функции: ")
    transaction = DAO.functions.withdrawDeposit(calldata, calladdress).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def dao_vote():
    try:
        id = int(input("Введите id голосования: "))
    except:
        id = int(input("Введите id голосования: "))

    try:
        tokens = int(input("Введите количество токенов, которыми хотите проголосовать: "))
    except ValueError:
        tokens = int(input("Введите количество токенов, которыми хотите проголосовать: "))
    
    try:
        choice = int(input("Введите выбор (1 - за, 0 - против): "))
    except ValueError:
        choice = int(input("Введите выбор (1 - за, 0 - против): "))
    if choice != 1 and choice != 0:
        choice = int(input("Введите выбор (1 - за, 0 - против): "))

    transaction = DAO.functions.vote(id, tokens, bool(choice)).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def dao_finish_proposal():
    try:
        id = int(input("Введите id голосования: "))
    except:
        id = int(input("Введите id голосования: "))

    transaction = DAO.functions.finishProposal(id).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")
    
