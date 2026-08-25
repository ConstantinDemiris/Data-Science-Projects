# Univariate and Multivariate Analysis

This assignment uses Seaborn's built-in `diamonds` dataset to demonstrate exploratory data analysis in Python.

## Analysis performed

- **Univariate analysis:** Descriptive statistics, histogram, density curve, and box plot for `price`.
- **Multivariate analysis:** Relationship between `carat` and `price`, grouped by `cut`, plus a numeric correlation heatmap.

## Run the notebook

Open `Univariate_and_Multivariate_Analysis.ipynb` in Jupyter Notebook or JupyterLab and select **Run All**. The notebook loads the dataset directly with:

```python
import seaborn as sns
diamonds = sns.load_dataset("diamonds")
```

Required libraries: `seaborn`, `numpy`, `pandas`, and `matplotlib`.
