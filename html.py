import pdftotree
import tkinter
from pathlib import Path
import os

input_path = Path('C:\\Users\\Dan\'s Laptop\\OneDrive\\Documents\\Coding\\Python\\USF\\COVID-19 Project\\Data\\Unclean PDF')
output_path = Path('C:\\Users\\Dan\'s Laptop\\OneDrive\\Documents\\Coding\\Python\\USF\\COVID-19 Project\\Data\\html')
file_n = len(os.listdir(input_path))
file_ct = 0
error_list = []
for files in os.listdir(input_path):
    file_ct += 1
    print(files)
    new_file_name = files.replace('.pdf','')
    html = pdftotree.parse('Data\\Unclean PDF\\'+ files)
    try:
        with open(f"{output_path}/{new_file_name}.html",'w') as f:
            f.write(html)
    except: error_list.append(files)
    print(f'{round((file_ct/file_n),3)*100}% Complete')
    break
print(error_list)