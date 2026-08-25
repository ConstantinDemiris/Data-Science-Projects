# Real Estate Data Cleaning Assignment

This project cleans the provided Real Estate dataset with Python and pandas.

## Completed requirements

- Renamed `transaction` to `transactionDate`.
- Removed `numberOfConvenienceStores` (the exact header used by the source CSV).
- Removed duplicate rows.
- Filled missing numeric values with each column's mean.
- Min-max normalized `houseAge` to the range 0-1 and saved the result in `houseAgeStandardized`.
- Displayed rows 0-10 with `.loc[0:10]`.
- Displayed the first 10 rows with `.iloc[:10]`.
- Saved all changes to `Realestate_cleaned.csv`.

## Run the script

```bash
pip install pandas
python clean_real_estate.py --input Realestate.csv --output Realestate_cleaned.csv
```

The script contains comments explaining every cleaning section.
