import time
from threading import Thread
from keys import PRINT_EVENT, DAO, ERC20, STAKING


def dao_log_loop_add_proposal(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nNew proposal")
            print(f"proposal id: {event['args']['pId']}")
            print(f"proposal call data: {event['args']['pCallData'].hex()}")
            print(f"proposal call address: {event['args']['pCallAddress']}")
        time.sleep(poll_interval)


def dao_log_loop_finish_proposal(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print(f"\nProposal is finished")
            print(f"quorum: {event['args']['quorum']}")
            print(f"result: {event['args']['result']}")
            print(f"success: {event['args']['success']}")
        time.sleep(poll_interval)


def erc20_log_loop_transfer(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nTransfer")
            print(f"from: {event['args']['from']}")
            print(f"to: {event['args']['to']}")
            print(f"amount: {event['args']['amount']}")
        time.sleep(poll_interval)


def erc20_log_loop_approval(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nApproval")
            print(f"owner: {event['args']['owner']}")
            print(f"spender: {event['args']['spender']}")
            print(f"amount: {event['args']['amount']}")
        time.sleep(poll_interval)


def staking_log_loop_stake(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nNew stake")
            print(f"from: {event['args']['from']}")
            print(f"value: {event['args']['value']}")
            print(f"unstake time: {event['args']['unstakeTime']}")
        time.sleep(poll_interval)


def staking_log_loop_unstake(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nUnstake")
            print(f"to: {event['args']['to']}")
            print(f"value: {event['args']['value']}")
        time.sleep(poll_interval)


event_filter_dao_add_proposal = DAO.events.AddProposal.create_filter(fromBlock="latest")
event_filter_dao_finish_proposal = DAO.events.FinishProposal.create_filter(fromBlock="latest")
event_filter_erc20_transfer = ERC20.events.Transfer.create_filter(fromBlock="latest")
event_filter_erc20_approval = ERC20.events.Approval.create_filter(fromBlock="latest")
event_filter_staking_stake = STAKING.events.Stake.create_filter(fromBlock="latest")
event_filter_staking_unstake = STAKING.events.Unstake.create_filter(fromBlock="latest")

thread_dao_add_proposal = Thread(target=dao_log_loop_add_proposal, args=(event_filter_dao_add_proposal, 10))
thread_dao_finish_proposal = Thread(target=dao_log_loop_finish_proposal, args=(event_filter_dao_finish_proposal, 10))
thread_erc20_transfer = Thread(target=erc20_log_loop_transfer, args=(event_filter_erc20_transfer, 10))
thread_erc20_approval = Thread(target=erc20_log_loop_approval, args=(event_filter_erc20_approval, 10))
thread_staking_stake = Thread(target=staking_log_loop_stake, args=(event_filter_staking_stake, 10))
thread_staking_unstake = Thread(target=staking_log_loop_unstake, args=(event_filter_staking_unstake, 10))
