from selenium import webdriver
import os
import wget
import PyPDF2 as pdf
from PyPDF2 import PdfFileReader, PdfFileWriter
import time
import pandas as pd
import re

#creates a dictionary with all of the state names
# chrome_path = 'C:\\Users\\chacr\\OneDrive\\Documents\\Coding\\home\\Dan\'s Laptop\\Class Project\\RWJ CHR\\chromedriver.exe'
chrome_path = r"chromedriver.exe"
cwd = os.getcwd()
driver = webdriver.Chrome(chrome_path)

driver.get('https://floridadisaster.org/covid19/covid-19-data-reports/')

title = driver.title
driver.find_elements_by_link_text('/globalassets/covid19/dailies')
result = driver.find_elements_by_xpath("//a[@href]")

df2 = pd.DataFrame(columns=['County', 'Num Col', 'Source'])
text_line_search = '\w+\s[\w,:]+\s.*\Z'  # '^[\w+\s\D+].+\Z'
digit_search = '^\d.*\Z'
date_search = '^\w+\s\d.+'
# turn into a function
page_counter = 0

today = datetime.date.today()
for files in os.listdir(pdf_output_path):

    pdf_writer = PdfFileWriter()
    header = []
    #     print(files)
    #     print(f'This is the start of the output for: {files}')
    headerset = 0
    data_row = []
    pdf_file = open(f'{pdf_output_path}/{files}', 'rb')
    pdfreader = PdfFileReader(pdf_file)
    num_pages = pdfreader.numPages
    if num_pages < 23:
        up_limit = num_pages
    else:
        up_limit = 23
    dfset = 0
    county_added_list = []
    for pages in range(3, up_limit):

        datalines = 0
        page = pdfreader.getPage(pages)

        if page.extractText().find('Coronavirus: PUI testing by county') > 0 or page.extractText().find(
                'Coronavirus: All persons with tests reported') > 0:
            pdf_writer.addPage(page)
            page_text = page.extractText()
            col_num = 0
            index_num = 0
            for lines in page_text.split('\n'):
                line_n = len(page_text.split('\n'))
                write_line = 0
                if not re.match(text_line_search, lines, flags=0) and not re.match(date_search, lines,
                                                                                   flags=0) and datalines == 0 and lines not in county_list and headerset != 1:
                    header.append(lines)
                if re.match(date_search, lines, flags=0):
                    date = lines[0:12]
                if lines in county_list:
                    datalines = 1
                    data_row = []
                    data_row_app_n = 0
                    col_num = 0
                if datalines == 1:
                    for names in header:
                        if names == 'Awaiting ':
                            header[index_num + 1] = 'Awaiting Testing'
                            header.pop(index_num)
                        if names == 'Percent ':
                            header[index_num + 1] = 'Pecent Positive'
                            header.pop(index_num)
                        index_num += 1
                    headerset = 1
                    if headerset == 1 and dfset == 0 and len(lines) < 30:
                        df = pd.DataFrame(columns=header)
                        dfset = 1
                    if (len(data_row) + 1) <= len(header) and len(lines) < 20:
                        if len(lines) == 0:
                            #                             data_row[col_num] = 0
                            #                             data_row.append('0')
                            print('')

                        else:
                            data_row.append(lines)
                            data_row_app_n += 1

                    if datalines == 1 and len(lines) > 2 and not re.match(date_search, lines, flags=0) and not re.match(
                            text_line_search, lines, flags=0):
                        write_line = 1
                    if len(data_row) == len(header):
                        if data_row[0] not in county_added_list:
                            data = pd.DataFrame([data_row], columns=header)
                            df = pd.concat([df, data])
                            county_added_list.append(data_row[0])
                try:
                    data2 = [data_row[0], data_row_app_n, files]
                    data2df = pd.DataFrame([data2], columns=['County', 'Num Col', 'Source'])
                    df2 = pd.concat([df2, data2df])
                except:
                    IndexError
                col_num += 1
    df.to_csv(f'data/TXT2/Text files of {files}.txt', index=False, sep="\t")
    output = f'Data/Unclean PDF/Unclean Extract from {files} ({today})'
    with open(output, 'wb') as output_pdf:
        pdf_writer.write(output_pdf)
print(round(1/2,))
df.describe()
    #             print(df)

import pdftotree
