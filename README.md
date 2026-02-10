### Data preprocessing

The raw dataset was cleaned and prepared prior to model training. The main steps included:

- Removal of the ID column
- Imputation of missing values in *Financial Stress* using the median
- Conversion of categorical variables to factors
- Specification of ordinal variables with meaningful order
- Reordering of levels for sleep duration and dietary habits
- Removal of low-variance variables (Work Pressure, Job Satisfaction, Profession)

The processed dataset is then used for model training and evaluation.
