import pandas as pd


def f(name):
    return name.replace('_', '-')[1:]


df1 = pd.read_csv('btc1.csv')
df1.drop(columns=['rank_'], inplace=True)
print(df1.shape)

df2 = pd.read_csv('btc2.csv')
df2.drop(columns=['rank_'], inplace=True)
print(df2.shape)

df3 = pd.read_csv('btc3.csv')
df3.drop(columns=['rank_'], inplace=True)
print(df3.shape)

df = pd.concat([df1, df2, df3], axis=1)
df.rename(mapper=f, axis=1, inplace=True)
print(df.shape)
print(df)

df.to_csv('btc.csv')
