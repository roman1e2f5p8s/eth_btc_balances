import pandas as pd


def f(name):
    return name.replace('_', '-')[1:]


df1 = pd.read_csv('eth1.csv')
df1.drop(columns=['rank_'], inplace=True)
print(df1.shape)
print(df1)

df1.rename(mapper=f, axis=1, inplace=True)
df1.to_csv('eth.csv')
