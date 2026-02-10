# ==============================================================================
# 01 - Data preprocessing
# ==============================================================================

library(dplyr)

# ------------------------------------------------------------------------------
# Load data
# ------------------------------------------------------------------------------

base <- read.csv("data/student_depression_dataset.csv")

# Remove ID column
df <- base[, -1]

# ------------------------------------------------------------------------------
# Missing values
# ------------------------------------------------------------------------------

df$Financial.Stress[df$Financial.Stress == "?"] <- NA
df$Financial.Stress <- as.numeric(df$Financial.Stress)
df$Financial.Stress[is.na(df$Financial.Stress)] <- median(df$Financial.Stress, na.rm = TRUE)

# ------------------------------------------------------------------------------
# Variable types
# ------------------------------------------------------------------------------

# Nominal variables
cols_factor <- c(1, 3, 4, 12, 13, 16, 17)
df[cols_factor] <- lapply(df[cols_factor], as.factor)

# Ordinal variables
cols_factor_ord <- c(5, 6, 8, 9, 15)
for (v in cols_factor_ord) {
  df[, v] <- factor(df[, v], ordered = TRUE)
}

# Reorder specific ordinal variables
df[, 10] <- factor(df[, 10],
                   levels = c("Others", "'Less than 5 hours'", "'5-6 hours'",
                              "'7-8 hours'", "'More than 8 hours'"),
                   ordered = TRUE)

df[, 11] <- factor(df[, 11],
                   levels = c("Others", "Unhealthy", "Moderate", "Healthy"),
                   ordered = TRUE)

# ------------------------------------------------------------------------------
# Remove low-variance variables
# ------------------------------------------------------------------------------

cols_eliminar <- c("Work.Pressure", "Job.Satisfaction", "Profession")
df <- df[, !(names(df) %in% cols_eliminar)]

# Final dataset
str(df)
