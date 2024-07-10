from events_trackers import thread_dao_add_proposal, \
                            thread_dao_finish_proposal, \
                            thread_erc20_approval, \
                            thread_erc20_transfer, \
                            thread_staking_stake, \
                            thread_staking_unstake
from menu import event_tracking_setup


def main():
    thread_dao_add_proposal.start()
    thread_dao_finish_proposal.start()
    thread_erc20_approval.start()
    thread_erc20_transfer.start()
    thread_staking_stake.start()
    thread_staking_unstake.start()

    event_tracking_setup()


if __name__ == "__main__":
    main()
    