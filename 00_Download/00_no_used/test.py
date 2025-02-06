from datetime import date
from calendar import monthrange
import pandas as pd

YEAR = 2023

df = pd.DataFrame()

for month in range(1, 13):
    start = date(YEAR, month, 1)
    end = date(YEAR, month, monthrange(YEAR, month)[1])
    df1 = pd.DataFrame({"start":[start], "end":[end]})
    df = pd.concat([df, df1], ignore_index=True)
    print(df1)


idx_l = list(range(len(df)))
idx_l