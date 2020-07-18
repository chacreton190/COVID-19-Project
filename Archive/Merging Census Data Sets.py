import pandas as pd
import os
from pathlib import Path
import sys


cwd = os.getcwd()
Blank = pd.DataFrame()
filepath = cwd+ "\\Data\\Census\\"
outpath = Path(filepath+"\\Ouput")


filelist_temp = os.listdir(filepath)
filelist = []

for csvs in filelist_temp:
    if csvs.find(".csv") > 0:
        filelist.append(csvs)


keeplist = ["S1901_C01_012E", "S1501_C02_002E", "S1501_C02_009E", "DP05_0001E", "DP05_0037PE", "DP05_0038PE", "DP05_0039PE", "DP05_0044PE", "DP05_0052PE"]

# if not outpath.exists():
#     os.mkdir(outpath)
print(len(filelist))
# sys.exit()
for files in filelist:
    # print(files)
    df = pd.read_csv(filepath + files)
    df.drop(index=0, inplace=True, axis=0)
    header = df.columns
    dfkeeplist = []
    for items in header:
        if items in keeplist:
            dfkeeplist.append(items)

    for keepers in dfkeeplist:
        df2 = df.filter(items=["GEO_ID", "NAME", keepers], axis = 1)
        print(df2)
        df2.sort_values(by='GEO_ID', inplace=True)
        #Blank = pd.DataFrame.append(Blank, df2, sort=True)
    Blank = pd.concat([Blank, df2], axis=1, join='inner')

print(Blank[0:])

Blank.to_csv(f"Combined Dataset.csv")
# print(outpath)
