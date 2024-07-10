import time
from keys import PRINT_EVENT


def dao_log_loop_add_proposal(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nNew proposal")
            print(f"proposal id: {event['args']['pId']}")
            print(f"proposal call data: {event['args']['pCallData']}")
            print(f"proposal call address: {event['args']['pCallAddress']}")
        time.sleep(poll_interval)


def dao_log_loop_finish_proposal(event_filter, poll_interval):
    while True:
        while not PRINT_EVENT:
            time.sleep(poll_interval)
        for event in event_filter.get_new_entries():
            print("\nProposal is finished")
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
        