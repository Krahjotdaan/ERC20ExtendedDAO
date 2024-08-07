from keys import WALLET_ADDRESS, STAKING, w3, PRIVATE_KEY


def staking_tod():
    tod = STAKING.functions.TOD().call()
    print(f"tod: {tod}")


def staking_dao():
    dao = STAKING.functions.dao().call()
    print(f"dao: {dao}")


def staking_reward_percent():
    reward_percent = STAKING.functions.rewardPercent().call()
    print(f"reward percent: {reward_percent}")


def staking_reward_period():
    reward_period = STAKING.functions.rewardPercent().call()
    print(f"reward period: {reward_period}")


def staking_make_stake():
    token = STAKING.functions.TOD().call()

    try:
        amount = int(input("Введите количество токенов для внесения в стейк (токены нельзя будет вывести до окончания периода стейка): "))
    except ValueError:
        amount = int(input("Введите количество токенов для внесения в стейк (токены нельзя будет вывести до окончания периода стейка): "))

    try:       
        period = int(input("Введите количество секунд, на которое будут заморожены токены: "))
    except ValueError:
        period = int(input("Введите количество секунд, на которое будут заморожены токены: "))

    transaction = STAKING.functions.makeStake(token, amount, period).build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")


def staking_unstake():
    transaction = STAKING.functions.unstake().build_transaction({
        'from': WALLET_ADDRESS,
        'chainId': 11155111,
        'gas': 300000,
        'maxFeePerGas': w3.eth.gas_price + 300000,
        'nonce': w3.eth.get_transaction_count(WALLET_ADDRESS)
    })
    signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    print(f"transaction hash: {w3.to_hex(tx_hash)}")
