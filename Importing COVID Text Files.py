#Import COVID text files merges them into one file

from glob import glob
import re

re.match()
def MergingDF(FilePath, OutFileName):
    import os
    import pandas as pd
    from pathlib import Path
    from datetime import date
    global completedf
    completedf = pd.DataFrame()
    cwd = os.getcwd()
    filepath = cwd + FilePath

    for files in os.listdir(filepath):
        if files.find('.txt') > 0:
            file = pd.read_csv(filepath + files, delimiter=",")
            headers = file.columns
            if "No result" in headers:
                file["Awaiting Testing"] = file["No result"]
                file.drop(labels="No result", axis=1, inplace=True)
            file["file_name"] = files
            completedf = pd.DataFrame.append(file, completedf, ignore_index=False, sort=False)
            completedf.sort_values(by=["County", "Date"], inplace=True)

            # print(files)
            # print(type(completedf.info()))
            completedf["Negative"] = completedf["Negative"].astype(float)


            completedf["Last_Pos_Count"] = completedf['Positive'].shift(1)
            completedf["Last_County"] = completedf['County'].shift(1)
            completedf["Last_Neg_Count"] = completedf['Negative'].shift(1)
            completedf["New_Negatives"] = completedf['Negative'] - completedf['Last_Neg_Count']
            completedf["New_Cases"] = completedf['Positive'] - completedf['Last_Pos_Count']
            completedf.loc[completedf["County"] != completedf["Last_County"], 'New_Cases' ] = ""
            completedf.loc[completedf["County"] != completedf["Last_County"], 'New_Negatives' ] = ""
            completedf.drop(labels=["Last_Pos_Count", "Last_County", "Last_Neg_Count"], inplace=True, axis=1)

    #         # print(completedf)
    # completedf.to_csv(f"C:\\Users\\Daniel chacreton\\Documents\\Python\\USF\\COVID-19 Project\\Data\\Txt\\Output\\{OutFileName} ({date.today()}).csv", sep=",")

    outpath = Path(filepath + "\\Output")
    if outpath.exists():
        completedf.to_excel(f"{outpath}\\{OutFileName} ({date.today()}).xlsx", index = False)
    else:
        outpath.mkdir()
        completedf.to_excel(f"{outpath}\\{OutFileName} ({date.today()}).xlsx", index = False)
    return completedf


MergingDF("\\Data\\Txt\\", "Complete COVID Data Set (unclean)")

