from web3 import Web3

w3 = Web3(Web3.HTTPProvider(''))

b = w3.eth.getBlock('latest')
print(b.number)

b = w3.eth.getBalance(
        account=Web3.toChecksumAddress('0x506c73b83d5a514c8832fc1fb40aaa5ed35b8d43'),
        block_identifier=b.number-120)
print(b)
