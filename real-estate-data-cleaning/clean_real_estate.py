"""Clean and normalize the Real Estate CSV dataset for the assignment."""

from pathlib import Path
import argparse

import pandas as pd


def clean_real_estate(input_path: Path, output_path: Path) -> pd.DataFrame:
    """Apply the required cleaning steps and save the cleaned dataset."""

    # Section 1: Load the original Real Estate CSV file into a DataFrame.
    df = pd.read_csv(input_path)

    # Section 2: Rename the transaction column to transactionDate.
    df.rename(columns={"transaction": "transactionDate"}, inplace=True)

    # Section 3: Drop the convenience-store count column permanently.
    # The source file uses "Convenience" rather than "Convenient" in its header.
    store_column = "numberOfConvenienceStores"
    if store_column not in df.columns:
        raise KeyError(f"Expected column not found: {store_column}")
    df.drop(columns=[store_column], inplace=True)

    # Section 4: Find and remove complete duplicate rows, then reset the row index.
    duplicate_count = int(df.duplicated().sum())
    df.drop_duplicates(inplace=True)
    df.reset_index(drop=True, inplace=True)

    # Section 5: Find missing values and fill each numeric column with its mean.
    missing_before = df.isna().sum()
    numeric_columns = df.select_dtypes(include="number").columns
    df[numeric_columns] = df[numeric_columns].fillna(df[numeric_columns].mean())
    missing_after = df.isna().sum()

    # Section 6: Min-max normalize houseAge to the range 0-1 and store the
    # normalized values in the required houseAgeStandardized column.
    house_age_min = df["houseAge"].min()
    house_age_max = df["houseAge"].max()
    house_age_range = house_age_max - house_age_min
    if house_age_range == 0:
        df["houseAgeStandardized"] = 0.0
    else:
        df["houseAgeStandardized"] = (
            (df["houseAge"] - house_age_min) / house_age_range
        )

    # Section 7: Use .loc[] to display rows with index labels 0 through 10.
    print("\nRows 0-10 displayed with .loc[]:")
    print(df.loc[0:10])

    # Section 8: Use .iloc[] to display the first 10 rows by position.
    print("\nFirst 10 rows displayed with .iloc[]:")
    print(df.iloc[:10])

    # Section 9: Display a short cleaning summary for verification.
    print(f"\nDuplicate rows removed: {duplicate_count}")
    print("\nMissing values before mean imputation:")
    print(missing_before)
    print("\nMissing values after mean imputation:")
    print(missing_after)

    # Section 10: Save the cleaned DataFrame so every modification persists.
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)
    print(f"\nCleaned dataset saved to: {output_path}")

    return df


def parse_args() -> argparse.Namespace:
    """Read optional input and output file paths from the command line."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("Realestate.csv"),
        help="Path to the original CSV file (default: Realestate.csv).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("Realestate_cleaned.csv"),
        help="Path for the cleaned CSV file (default: Realestate_cleaned.csv).",
    )
    return parser.parse_args()


if __name__ == "__main__":
    arguments = parse_args()
    clean_real_estate(arguments.input, arguments.output)
