## 1. Project Overview

This project aims to predict the presence of depression using demographic, academic, lifestyle, and mental health–related variables. Two modeling approaches are compared:

* Logistic Regression (statistical inference)
* Random Forest (machine learning prediction)

The analysis focuses on:

* Predictive performance (AUC)
* Model interpretability
* Identification of key risk factors associated with depression

## 2. Data Preprocessing

The raw dataset was cleaned and prepared prior to model training. The main steps included:

* Removal of the ID column
* Imputation of missing values in *Financial Stress* using the median
* Conversion of categorical variables to factors
* Specification of ordinal variables with meaningful ordering
* Reordering levels for sleep duration and dietary habits
* Removal of low-variance variables (Work Pressure, Job Satisfaction, Profession)

The processed dataset was then used for model training and evaluation.

## 3. Model Training and Hyperparameter Tuning

### 3.1 Random Forest Hyperparameter Tuning

Sequential cross-validation was performed to tune the main hyperparameters of the Random Forest model.

#### Objective

To identify the optimal combination of:

* `mtry` (number of variables sampled at each split)
* `ntree` (number of trees)
* `nodesize` (minimum size of terminal nodes)

The optimization criterion was the **Area Under the ROC Curve (AUC)** using **5-fold cross-validation**.

#### Tuning procedure

**Step 1. Tuning `mtry`**

* Grid: 1 to 13
* Fixed:

  * `ntree = 500`
  * `nodesize = 2`

**Step 2. Tuning `ntree`**

* Grid: 100, 200, 300, 400, 500
* Fixed:

  * `mtry = 2`
  * `nodesize = 2`

**Step 3. Tuning `nodesize`**

A three-stage refinement strategy was used to reduce computational cost:

* Coarse search (step = 1200)
* Intermediate search (step = 70)
* Fine search (step = 10)

**Final optimal values**

* `mtry = 2`
* `ntree = 500`
* `nodesize = 11`

#### Cross-validation details

* 5-fold cross-validation
* Random fold assignment
* Different seeds per fold to ensure reproducibility despite bootstrap sampling
* Performance metric: **AUC (pROC)**

#### Output files

The following files store cross-validation results:

* `CV_RF_x_MTRY.RDS`
* `CV_RF_x_NTREE.RDS`
* `CV_RF_x_NODE1200.RDS`
* `CV_RF_x_NODE70.RDS`
* `CV_RF_x_NODE_FINAL.RDS`
* `AUC_CV_RAND.F.RDS`

Each file contains the mean AUC and standard deviation for the evaluated hyperparameter configurations.

## 4. Final Models and Interpretation

Two final models were trained using the full dataset:

* Logistic Regression (for statistical inference)
* Random Forest (for predictive modeling)

The objective of this stage is to compare:

* Effect size interpretation and statistical significance (logistic regression)
* Predictive contribution of variables through permutation importance (Random Forest)

### 4.1 Final Random Forest Model

The model was trained using the optimal hyperparameters obtained from cross-validation:

* `ntree = 500`
* `mtry = 2`
* `nodesize = 11`

Performance was evaluated using **AUC** on the full dataset.

### 4.2 Permutation Importance (ΔAUC)

Feature importance was assessed using a permutation-based approach:

1. Compute the original AUC.
2. For each predictor:

   * Randomly permute its values.
   * Generate new predictions.
   * Recalculate AUC.
3. Importance is defined as:

ΔAUC = AUC_original − AUC_permuted

Interpretation:

* **Large positive ΔAUC** → strong predictive contribution
* **Values near zero** → minimal contribution
* **Negative values** → potential noise or instability

A bar plot of the **top 20 variables** is produced.

### 4.3 Final Logistic Regression Model

A full model was fitted using:

`glm(Depression ~ ., family = binomial)`

Outputs include:

* Predicted probabilities
* ROC curve and AUC
* Model summary:

  * Coefficients (log-odds)
  * Standard errors
  * z-statistics
  * p-values

Exponentiated coefficients are interpreted as **odds ratios**, representing the multiplicative change in the odds of depression.

## 5. Results

### 5.1 Random Forest: Permutation Importance

| Rank | Variable          | ΔAUC       |
| ---- | ----------------- | ---------- |
| 1    | Suicidal thoughts | **+0.086** |
| 2    | Academic Pressure | **+0.043** |
| 3    | Financial Stress  | +0.001     |
| 4–12 | Other variables   | ~0         |

The results indicate that **suicidal thoughts** and **academic pressure** are the main predictors of depression, while most other variables provide little additional predictive value.

---

### 5.2 Logistic Regression: Odds Ratios

| Variable                         | Odds Ratio      |
| -------------------------------- | --------------- |
| Suicidal thoughts (Yes)          | **≈ 12.3**      |
| Academic Pressure (Level 5)      | ≈ 12.4          |
| Financial Stress (Level 5)       | ≈ 9.2           |
| Financial Stress (Level 4)       | ≈ 4.7           |
| Work–Study Hours                 | ≈ 1.13 per hour |
| Age                              | ≈ 0.89 per year |
| Sleep < 5 hours                  | ≈ 1.43          |
| Sleep > 8 hours                  | ≈ 0.77          |
| Unhealthy diet                   | ≈ 3.0           |
| Family history of mental illness | ≈ 1.28          |
| CGPA                             | ≈ 1.06 per unit |

Key interpretations:

* The odds of depression are **approximately 12 times higher** among individuals reporting suicidal thoughts compared to those who do not.
* Extremely high academic pressure is also associated with a **substantial increase in risk**.
* Higher financial stress and unhealthy lifestyle patterns are additional risk factors.
* Older age appears to be associated with a lower probability of depression.

Overall, both models consistently identify **suicidal ideation and academic pressure** as the most influential factors.

## 6. Key Findings and Discussion

This project highlights the practical trade-offs between a **parametric statistical model** (Logistic Regression) and a **non-parametric machine learning model** (Random Forest) when applied to a psychological prediction problem.

---

### 6.1 Interpretability: Statistical Inference vs Predictive Contribution

A major strength of Logistic Regression is its **inferential interpretability**.  
Because the model is parametric and based on an explicit probability model:

- Coefficients have a clear interpretation in terms of **log-odds** and **odds ratios**
- Each parameter is accompanied by:
  - Standard errors  
  - Confidence intervals  
  - p-values  

This allows conclusions such as:

> “Individuals with suicidal thoughts have approximately 12 times higher odds of depression.”

Thus, Logistic Regression supports **probabilistic reasoning and uncertainty quantification**, which is especially valuable in psychological and clinical contexts where explanation and justification are critical.

In contrast, the Random Forest does not provide parameter estimates or statistical significance.  
Interpretation is instead based on **predictive contribution**, such as permutation importance (ΔAUC).

This type of interpretation answers a different question:

> “How much does this variable improve the model’s predictive performance?”

While useful for model understanding, it does not provide:
- Direction of effect  
- Magnitude in probabilistic terms  
- Statistical evidence for the relationship  

Therefore, machine learning interpretability is **performance-oriented rather than inferential**.

---

### 6.2 Robustness to High-Cardinality Predictors

The parametric nature of Logistic Regression also introduces limitations.

Categorical variables with many levels (high cardinality) can lead to:

- A large number of parameters  
- Sparse observations per level  
- Extremely large or unstable coefficients  
- Inflated standard errors  
- Reduced reliability of interpretation  

This makes the model sensitive to overfitting and instability when such variables are present.

Random Forest, being a tree-based non-parametric method, is **more robust** in this context:

- It handles high-cardinality variables without explicit parameter estimation
- Splits are selected based on predictive gain rather than parameter stability
- The model remains stable even when some levels are rare

This illustrates an important trade-off:  
Logistic Regression offers richer interpretation **when its assumptions are satisfied**, but Random Forest is more flexible and robust in complex data settings.

---

### 6.3 Complementary Roles

The results suggest that these approaches should not be seen as competitors, but as **complementary tools**:

- **Logistic Regression**
  - Best for explanation, inference, and decision support  
  - Provides effect sizes and uncertainty estimates  
  - Suitable for theory-driven psychological research  

- **Random Forest**
  - Best for predictive accuracy and robustness  
  - Handles nonlinearities, interactions, and complex structures  
  - Useful for variable screening and performance optimization  

In applied psychological and behavioral data science, a combined strategy—using machine learning for prediction and statistical models for interpretation—can provide both **accuracy and scientific insight**.
