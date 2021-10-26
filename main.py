# from google.cloud import bigquery

# client = bigquery.Client()

# from web3.auto.infura import w3

# b = w3.eth.accounts
# print(b)
import pickle

with open('data.pickle', 'rb') as handle:
    b = pickle.load(handle)
print(len(b))
