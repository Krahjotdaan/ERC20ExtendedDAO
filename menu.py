from keys import PRINT_EVENT
from dao_functions import *
from erc20_functions import *
from staking_functions import *

def event_tracking_setup():
    global PRINT_EVENT
    print("1. Выводить сообщения о новых событиях")
    print("2. НЕ выводить сообщения о новых событиях")
    choice = int(input("\nВведите номер пункта меню, который выбрали: "))
    if choice == 1:
        PRINT_EVENT = True
    elif choice == 2:
        PRINT_EVENT = False
    menu()


def menu():
    while True:
        print("\nС каким контрактом будем работать?")
        print("1. DAO")
        print("2. ERC20")
        print("3. Staking")
        print("4. Настроить отслеживание событий")
        print("5. Выйти из программы")
        choice = int(input("\nВведите номер пункта меню, который выбрали: "))
        if choice == 1:
            dao_menu()
        elif choice == 2:
            erc20_menu()
        elif choice == 3:
            staking_menu()
        elif choice == 4:
            event_tracking_setup()
        elif choice == 5:
            exit()


def dao_menu():
    while True:
        print("\nКонтракт DAO")
        print("1. Вызвать функцию dao_call_time")
        print("2. Вызвать функцию dao_call_chairman")
        print("3. Вызвать функцию dao_call_tod")
        print("4. Вызвать функцию dao_call_staking")
        print("5. Вызвать функцию dao_get_deposit")
        print("6. Вызвать функцию dao_get_all_proposals")
        print("7. Вызвать функцию dao_get_proposal_by_id")
        print("8. Вызвать функцию dao_add_deposit")
        print("9. Вызвать функцию dao_withdraw_deposit")
        print("10. Вызвать функцию dao_add_proposal")
        print("11. Вызвать функцию dao_vote")
        print("12. Вызвать функцию dao_finish_proposal")
        print("13. Вернуться в главное меню")
        choice = int(input("\nВведите номер пункта меню, который выбрали: "))
        if choice == 1:
            dao_call_time()
        elif choice == 2:
            dao_call_chairman()
        elif choice == 3:
            dao_call_tod()
        elif choice == 4:
            dao_call_staking()
        elif choice == 5:
            dao_get_deposit()
        elif choice == 6:
            dao_get_all_proposals()
        elif choice == 7:
            dao_get_proposal_by_id()
        elif choice == 8:
            dao_add_deposit()
        elif choice == 9:
            dao_withdraw_deposit()
        elif choice == 10:
            dao_add_proposal()
        elif choice == 11:
            dao_vote()
        elif choice == 12:
            dao_finish_proposal()
        elif choice == 13:
            menu()


def erc20_menu():
    while True:
        print("\nКонтракт ERC20")
        print("1. Вызвать функцию erc20_dao")
        print("2. Вызвать функцию erc20_staking")
        print("3. Вызвать функцию erc20_name")
        print("4. Вызвать функцию erc20_symbol")
        print("5. Вызвать функцию erc20_decimals")
        print("6. Вызвать функцию erc20_total_supply")
        print("7. Вызвать функцию erc20_balance_of")
        print("8. Вызвать функцию erc20_allowance")
        print("9. Вызвать функцию erc20_approve")
        print("10. Вызвать функцию erc20_increase_allowance")
        print("11. Вызвать функцию erc20_decrease_allowance")
        print("12. Вызвать функцию erc20_transfer")
        print("13. Вызвать функцию erc20_transfer_from")
        print("14. Вызвать функцию erc20_burn")
        print("15. Вернуться в главное меню")
        choice = int(input("\nВведите номер пункта меню, который выбрали: "))
        if choice == 1:
            erc20_dao()
        elif choice == 2:
            erc20_staking()
        elif choice == 3:
            erc20_name()
        elif choice == 4:
            erc20_symbol()
        elif choice == 5:
            erc20_decimals()
        elif choice == 6:
            erc20_total_supply()
        elif choice == 7:
            erc20_balance_of()
        elif choice == 8:
            erc20_allowance()
        elif choice == 9:
            erc20_approve()
        elif choice == 10:
            erc20_increase_allowance()
        elif choice == 11:
            erc20_decrease_allowance()
        elif choice == 12:
            erc20_transfer()
        elif choice == 13:
            erc20_transfer_from()
        elif choice == 14:
            erc20_burn()
        elif choice == 15:
            menu()


def staking_menu():
    while True:
        print("\nКонтракт ERC20")
        print("1. Вызвать функцию staking_tod")
        print("2. Вызвать функцию staking_dao")
        print("3. Вызвать функцию staking_reward_percent")
        print("4. Вызвать функцию staking_reward_period")
        print("5. Вызвать функцию staking_make_stake")
        print("6. Вызвать функцию staking_unstake")
        print("7. Вернуться в главное меню")
        choice = int(input("\nВведите номер пункта меню, который выбрали: "))
        if choice == 1:
            staking_tod()
        elif choice == 2:
            staking_dao()
        elif choice == 3:
            staking_reward_percent()
        elif choice == 4:
            staking_reward_period()
        elif choice == 5:
            staking_make_stake()
        elif choice == 6:
            staking_unstake()
        elif choice == 7:
            menu()
