from web3 import Web3, HTTPProvider


provider = ""
WALLET_ADDRESS = ""
PRIVATE_KEY = ""
dao = ""
erc20 = ""
staking = ""

true = True
false = False

PRINT_EVENT = True

DAO_ABI = None
ERC20_ABI = None
STAKING_ABI = None

w3 = Web3(HTTPProvider(provider))

DAO = w3.eth.contract(address=dao, abi=DAO_ABI)
ERC20 = w3.eth.contract(address=erc20, abi=ERC20_ABI)
STAKING = w3.eth.contract(address=staking, abi=STAKING_ABI)
