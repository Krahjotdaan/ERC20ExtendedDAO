from web3 import Web3, HTTPProvider
from threading import Thread
import time
from keys import *


w3 = Web3(HTTPProvider(PROVIDER))

dao = w3.eth.contract(address=DAO, abi=DAO_ABI)
erc20 = w3.eth.contract(address=ERC20, abi=ERC20_ABI)
staking = w3.eth.contract(address=STAKING, abi=STAKING_ABI)

print_event = True

def main():
    pass


if __name__ == "__main__":
    main()
    