

def ConvertWordtoTxt(inpath, outpath):
    import docx
    import os
    import re
    import csv
    filecounter = 0
    for file in os.listdir(inpath):
        headerlist = []
        datamatrix = []
        filecounter += 1
        datestart = file.index("2020")
        dateend = datestart + 10
        dateall = file[datestart: dateend].split("-")
        date = f"{dateall[1]}-{dateall[2]}-{dateall[0]}"
        infile = f"{inpath}\\{file}"
        newfilename = f"{outpath}\Florida COVID-19 Data {date}.txt"
        indoc = docx.Document(infile)
        tablecounter = 0
        startofdata = 0
        for table in indoc.tables:
            rowcounter = 0
            tablecounter += 1
            for row in table.rows:
                rowcounter += 1
                datalist = []
                for col in row.cells:
                    if re.search(re.compile("County"), col.text) and tablecounter == 1:
                        docheader = row
                        headerappendcounter = 0
                        for colheaders in docheader.cells:
                            if len(colheaders.text) < 23 and len(colheaders.text) > 0:
                                headerlist.append(colheaders.text.replace("\n"," "))
                                startofdata = rowcounter
                            headerappendcounter += 1
                            if headerappendcounter == len(docheader.cells):
                                headerlist.append("Date")
                                if len(headerlist) > 0:
                                    datamatrix.append(headerlist)
                    elif startofdata > 0 and rowcounter != startofdata and len(col.text) < 23:
                        datalist.append(col.text.replace(",",""))
                if len(datalist) != 0:
                    datalist.append(date)
                    datamatrix.append(datalist)
                print(f'{(round(filecounter/len(os.listdir(inpath)) * 100))}% complete',end ='\n')
                with open(newfilename, "w", newline='') as f:
                    wr = csv.writer(f, dialect ='excel', delimiter = ",")
                    wr.writerows(datamatrix)


filepath = 'Data\Word'
outfilepath ='Data\Txt\\'


ConvertWordtoTxt(filepath, outfilepath)
