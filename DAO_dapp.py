from keys import *


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
    pass


def main():
    pass


if __name__ == "__main__":
    main()
    