import pandas as pd
import sys

csv_file = sys.argv[1]

data = pd.read_csv(csv_file)

new_data = data[['Time','system\context switches/sec','processor information(_total)\% processor utility',
            'processor information(_total)\% processor time','processor(_total)\% processor time',
            'memory\\available mbytes','memory\page faults/sec','memory\% committed bytes in use']]

new_data.to_csv(csv_file[:-4]+"_short.csv", index=False)
print("Completed")
