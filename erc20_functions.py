from keys import WALLET_ADDRESS, ERC20, w3, PRIVATE_KEY


def erc20_dao():
    dao = ERC20.functions.dao().call()
    print(f"dao: {dao}")


def erc20_staking():
    staking = ERC20.functions.staking().call()
    print(f"staking: {staking}")


def erc20_name():
    name = ERC20.functions.name().call()
    print(f"name: {name}")


def erc20_symbol():
    symbol = ERC20.functions.symbol().call()
    print(f"symbol: {symbol}")


def erc20_decimals():
    decimals = ERC20.functions.decimals().call()
    print(f"decimals: {decimals}")


def erc20_total_supply():
    total_supply = ERC20.functions.totalSupply().call()
    print(f"total supply: {total_supply}")


def erc20_balance_of():
    adr = input("Введите адрес для проверки баланса: ")
    balance = ERC20.functions.balanceOf(adr).call()
    print(f"balance: {balance}")


def erc20_allowance():
    owner = input("Введите адрес держателя токенов: ")
    spender = input("Введите адрес одобренного оператора: ")
    allowance = ERC20.functions.allowance(owner, spender).call()
    print(f"allowance: {allowance}")


def erc20_approve():
    spender = input("Введите адрес нового оператора: ")

    try:
        amount = int(input("Введите количество токенов для разрешения оператору: "))
    except ValueError:
        amount = int(input("Введите количество токенов для разрешения оператору: "))

    transaction = ERC20.functions.approve(spender, amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def erc20_increase_allowance():
    spender = input("Введите адрес одобренного оператора: ")

    try:
        amount = int(input("Введите количество токенов для увеличения разрешения оператору(количество разрешенных токенов увеличится на эту величину): "))
    except:
        amount = int(input("Введите количество токенов для увеличения разрешения оператору(количество разрешенных токенов увеличится на эту величину): "))

    transaction = ERC20.functions.increaseAllowance(spender, amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def erc20_decrease_allowance():
    spender = input("Введите адрес одобренного оператора: ")

    try:
        amount = int(input("Введите количество токенов для уменьшения разрешения оператору(количество разрешенных токенов уменьшится на эту величину): "))
    except ValueError:
        amount = int(input("Введите количество токенов для уменьшения разрешения оператору(количество разрешенных токенов уменьшится на эту величину): "))

    transaction = ERC20.functions.decreaseAllowance(spender, amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def erc20_transfer():
    to = input("Введите адрес получателя: ")
    try:
        amount = int(input("Введите количество токенов для отправки: "))
    except ValueError:
        amount = int(input("Введите количество токенов для отправки: "))

    transaction = ERC20.functions.transfer(to, amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def erc20_transfer_from():
    frm = input("Введите адрес, с которого отправятся токены: ")
    to = input("Введите адрес получателя: ")

    try:
        amount = int(input("Введите количество токенов для отправки: "))
    except ValueError:
        amount = int(input("Введите количество токенов для отправки: "))

    transaction = ERC20.functions.transferFrom(frm, to, amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def erc20_burn():
    try:
        amount = int(input("Введите количество токенов для уничтожения: "))
    except ValueError:
        amount = int(input("Введите количество токенов для уничтожения: "))
        
    transaction = ERC20.functions.burn(amount).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")
