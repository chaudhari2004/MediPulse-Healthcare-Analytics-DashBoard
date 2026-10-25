import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv("data/healthcare_dataset.csv")

print("Data set loaded..")

print("\nDataset Shape:")
print(df.shape)

print("\nColumn Names:")
print(df.columns.tolist())

print("\nDataset Information:")
df.info()

print("\nMissing Values:")
print(df.isnull().sum())

print("\nDuplicated Values:")
print(df.duplicated().sum())

duplicate_count = df.duplicated().sum()
duplicate_percentage = (duplicate_count / len(df)) * 100

print("\nDuplicate Count:", duplicate_count)
print("Duplicate Percentage:", round(duplicate_percentage, 2), "%")

print("\nDuplicate Rows:")
print(df[df.duplicated(keep=False)].head(10))

duplicate_rows = df[df.duplicated(keep=False)]

print("\nTotal rows involved in duplicate groups:")
print(len(duplicate_rows))

print("\nStatistical Summary:")
print(df.describe())

negative_billing = df[df["Billing Amount"] < 0]

print("\nNegative Billing Records:", len(negative_billing))
print(
    "Negative Billing Percentage:",
    round((len(negative_billing) / len(df)) * 100, 2),
    "%"
)

print("\nNegative Billing Records:")
print(negative_billing.head(10))

invalid_age = df[
    (df["Age"] < 0) |
    (df["Age"] > 120)
]

print("\nInvalid Age Records:", len(invalid_age))

print("\nInvalid Age Records:")
print(invalid_age.head(10))

df["Date of Admission"] = pd.to_datetime(
    df["Date of Admission"],
    errors="coerce"
)

df["Discharge Date"] = pd.to_datetime(
    df["Discharge Date"],
    errors="coerce"
)

print("\nDate Conversion Completed")

print("\nInvalid/Missing Admission Dates:")
print(df["Date of Admission"].isna().sum())

print("\nInvalid/Missing Discharge Dates:")
print(df["Discharge Date"].isna().sum())

print("\nAdmission Date Range:")
print("Minimum:", df["Date of Admission"].min())
print("Maximum:", df["Date of Admission"].max())

print("\nDischarge Date Range:")
print("Minimum:", df["Discharge Date"].min())
print("Maximum:", df["Discharge Date"].max())

invalid_discharge = df[
    df["Discharge Date"] < df["Date of Admission"]
]

print("\nInvalid Discharge Dates:")
print("Count:", len(invalid_discharge))

df["Length of Stay"] = (
    df["Discharge Date"] -
    df["Date of Admission"]
).dt.days

print("\nLength of Stay Summary:")
print(df["Length of Stay"].describe())

categorical_columns = [
    "Gender",
    "Blood Type",
    "Medical Condition",
    "Insurance Provider",
    "Admission Type",
    "Medication",
    "Test Results"
]

print("\n" + "=" * 60)
print("STEP 2.2 - CATEGORY FREQUENCY ANALYSIS")
print("=" * 60)

for column in categorical_columns:
    print("\n" + "-" * 50)
    print("Column:", column)

    print("\nUnique Values:")
    print(df[column].unique())

    print("Number of Unique Values:")
    print(df[column].nunique())

    print("\nCategory Counts:")
    print(df[column].value_counts())

    print("\nCategory Percentages:")
    print(
        round(
            df[column].value_counts(normalize=True) * 100,
            2
        )
    )

print("\n" + "=" * 60)
print("MEDICAL CONDITION vs GENDER")
print("=" * 60)

condition_gender = pd.crosstab(
    df["Medical Condition"],
    df["Gender"]
)

print(condition_gender)

print("\n" + "=" * 60)
print("MEDICAL CONDITION vs ADMISSION TYPE")
print("=" * 60)

condition_admission = pd.crosstab(
    df["Medical Condition"],
    df["Admission Type"]
)

print(condition_admission)

print("\n" + "=" * 60)
print("MEDICAL CONDITION vs TEST RESULTS")
print("=" * 60)

condition_test = pd.crosstab(
    df["Medical Condition"],
    df["Test Results"]
)

print(condition_test)

print("\n" + "=" * 60)
print("INSURANCE PROVIDER vs ADMISSION TYPE")
print("=" * 60)

insurance_admission = pd.crosstab(
    df["Insurance Provider"],
    df["Admission Type"]
)

print(insurance_admission)

print("\n" + "=" * 60)
print("2.4.1 MEDICAL CONDITION vs BILLING AMOUNT")
print("=" * 60)

condition_billing = df.groupby(
    "Medical Condition"
)["Billing Amount"].agg(
    ["count", "mean", "median", "min", "max"]
)

print(condition_billing.round(2))

print("\n" + "=" * 60)
print("2.4.2 ADMISSION TYPE vs LENGTH OF STAY")
print("=" * 60)

admission_los = df.groupby(
    "Admission Type"
)["Length of Stay"].agg(
    ["count", "mean", "median", "min", "max"]
)

print(admission_los.round(2))

print("\n" + "=" * 60)
print("2.4.3 INSURANCE PROVIDER vs BILLING AMOUNT")
print("=" * 60)

insurance_billing = df.groupby(
    "Insurance Provider"
)["Billing Amount"].agg(
    ["count", "mean", "median", "sum"]
)

print(insurance_billing.round(2))

print("\n" + "=" * 60)
print("2.4.4 MEDICAL CONDITION vs LENGTH OF STAY")
print("=" * 60)

condition_los = df.groupby(
    "Medical Condition"
)["Length of Stay"].agg(
    ["count", "mean", "median", "min", "max"]
)

print(condition_los.round(2))

print("\n" + "=" * 60)
print("STEP 2.4 COMPLETED!")
print("=" * 60)

print("\n" + "=" * 60)
print("STEP 2.5 - OUTLIER ANALYSIS")
print("=" * 60)

Q1_billing = df["Billing Amount"].quantile(0.25)
Q3_billing = df["Billing Amount"].quantile(0.75)

IQR_billing = Q3_billing - Q1_billing

lower_billing = Q1_billing - 1.5 * IQR_billing
upper_billing = Q3_billing + 1.5 * IQR_billing

billing_outliers = df[
    (df["Billing Amount"] < lower_billing) |
    (df["Billing Amount"] > upper_billing)
]

print("\n2.5.1 BILLING AMOUNT OUTLIERS")
print("Q1:", round(Q1_billing, 2))
print("Q3:", round(Q3_billing, 2))
print("IQR:", round(IQR_billing, 2))
print("Lower Bound:", round(lower_billing, 2))
print("Upper Bound:", round(upper_billing, 2))
print("Billing Outliers:", len(billing_outliers))
print(
    "Billing Outlier Percentage:",
    round((len(billing_outliers) / len(df)) * 100, 2),
    "%"
)

Q1_age = df["Age"].quantile(0.25)
Q3_age = df["Age"].quantile(0.75)

IQR_age = Q3_age - Q1_age

lower_age = Q1_age - 1.5 * IQR_age
upper_age = Q3_age + 1.5 * IQR_age

age_outliers = df[
    (df["Age"] < lower_age) |
    (df["Age"] > upper_age)
]

print("\n2.5.2 AGE OUTLIERS")
print("Q1:", round(Q1_age, 2))
print("Q3:", round(Q3_age, 2))
print("IQR:", round(IQR_age, 2))
print("Lower Bound:", round(lower_age, 2))
print("Upper Bound:", round(upper_age, 2))
print("Age Outliers:", len(age_outliers))
print(
    "Age Outlier Percentage:",
    round((len(age_outliers) / len(df)) * 100, 2),
    "%"
)

Q1_los = df["Length of Stay"].quantile(0.25)
Q3_los = df["Length of Stay"].quantile(0.75)

IQR_los = Q3_los - Q1_los

lower_los = Q1_los - 1.5 * IQR_los
upper_los = Q3_los + 1.5 * IQR_los

los_outliers = df[
    (df["Length of Stay"] < lower_los) |
    (df["Length of Stay"] > upper_los)
]

print("\n2.5.3 LENGTH OF STAY OUTLIERS")
print("Q1:", round(Q1_los, 2))
print("Q3:", round(Q3_los, 2))
print("IQR:", round(IQR_los, 2))
print("Lower Bound:", round(lower_los, 2))
print("Upper Bound:", round(upper_los, 2))
print("Length of Stay Outliers:", len(los_outliers))
print(
    "Length of Stay Outlier Percentage:",
    round((len(los_outliers) / len(df)) * 100, 2),
    "%"
)

print("\n" + "=" * 60)
print("OUTLIER ANALYSIS COMPLETED!")
print("=" * 60)

plt.figure(figsize=(8, 5))
plt.boxplot(df["Billing Amount"].dropna())
plt.title("Billing Amount - Boxplot")
plt.ylabel("Billing Amount")
plt.show()

plt.figure(figsize=(8, 5))
plt.boxplot(df["Age"].dropna())
plt.title("Age - Boxplot")
plt.ylabel("Age")
plt.show()

plt.figure(figsize=(8, 5))
plt.boxplot(df["Length of Stay"].dropna())
plt.title("Length of Stay - Boxplot")
plt.ylabel("Days")
plt.show()

print("\n" + "=" * 60)
print("STEP 2.6 - ADVANCED DATA QUALITY ANALYSIS")
print("=" * 60)

total_records = len(df)
unique_patients = df["Name"].nunique()

name_counts = df["Name"].value_counts()
repeated_names = name_counts[name_counts > 1]

repeated_patient_records = df[
    df["Name"].isin(repeated_names.index)
]

print("\n2.6.1 DUPLICATE PATIENT / REPEATED NAME ANALYSIS")
print("Total Records:", total_records)
print("Unique Patient Names:", unique_patients)
print("Repeated Patient Names:", len(repeated_names))
print(
    "Repeated Patient Name Percentage:",
    round((len(repeated_names) / unique_patients) * 100, 2),
    "%"
)
print(
    "Records belonging to repeated patient names:",
    len(repeated_patient_records)
)

print("\nTop 10 Repeated Patient Names:")
print(repeated_names.head(10))

age_consistency = df.groupby("Name")["Age"].nunique()
gender_consistency = df.groupby("Name")["Gender"].nunique()
blood_consistency = df.groupby("Name")["Blood Type"].nunique()

age_inconsistent = age_consistency[age_consistency > 1]
gender_inconsistent = gender_consistency[gender_consistency > 1]
blood_inconsistent = blood_consistency[blood_consistency > 1]

print("\n2.6.2 PATIENT IDENTITY CONSISTENCY ANALYSIS")
print("Names with Multiple Ages:", len(age_inconsistent))
print("Names with Multiple Genders:", len(gender_inconsistent))
print("Names with Multiple Blood Types:", len(blood_inconsistent))

print("\nExamples - Multiple Ages:")
print(age_inconsistent.head(10))

print("\nExamples - Multiple Genders:")
print(gender_inconsistent.head(10))

print("\nExamples - Multiple Blood Types:")
print(blood_inconsistent.head(10))

print("\n2.6.3 TEXT / CATEGORY CONSISTENCY ANALYSIS")

text_check_columns = [
    "Gender",
    "Blood Type",
    "Medical Condition",
    "Doctor",
    "Hospital",
    "Insurance Provider",
    "Admission Type",
    "Medication",
    "Test Results"
]

for column in text_check_columns:
    missing_count = df[column].isna().sum()

    blank_count = (
        df[column]
        .astype("string")
        .str.strip()
        .eq("")
        .sum()
    )

    space_count = (
        df[column]
        .astype("string")
        .ne(df[column].astype("string").str.strip())
        .sum()
    )

    print("\nColumn:", column)
    print("Missing Values:", missing_count)
    print("Blank Values:", blank_count)
    print("Values with Extra Spaces:", space_count)

negative_billing = df[df["Billing Amount"] < 0]
zero_billing = df[df["Billing Amount"] == 0]
positive_billing = df[df["Billing Amount"] > 0]

print("\n2.6.4 BILLING BUSINESS VALIDATION")
print("Total Billing Records:", len(df))
print("Negative Billing Records:", len(negative_billing))
print(
    "Negative Billing Percentage:",
    round(len(negative_billing) / len(df) * 100, 2),
    "%"
)
print("Zero Billing Records:", len(zero_billing))
print(
    "Zero Billing Percentage:",
    round(len(zero_billing) / len(df) * 100, 2),
    "%"
)
print("Positive Billing Records:", len(positive_billing))

missing_admission = df["Date of Admission"].isna().sum()
missing_discharge = df["Discharge Date"].isna().sum()

invalid_date_order = df[
    df["Discharge Date"] < df["Date of Admission"]
]

same_day_discharge = df[
    df["Discharge Date"] == df["Date of Admission"]
]

print("\n2.6.5 DATE CONSISTENCY VALIDATION")
print("Missing Admission Dates:", missing_admission)
print("Missing Discharge Dates:", missing_discharge)
print(
    "Discharge Before Admission:",
    len(invalid_date_order)
)
print(
    "Same-Day Admission & Discharge:",
    len(same_day_discharge)
)

print("\nAdmission Date Range:")
print(
    df["Date of Admission"].min(),
    "to",
    df["Date of Admission"].max()
)

print("\nDischarge Date Range:")
print(
    df["Discharge Date"].min(),
    "to",
    df["Discharge Date"].max()
)

negative_los = df[df["Length of Stay"] < 0]
zero_los = df[df["Length of Stay"] == 0]
los_above_30 = df[df["Length of Stay"] > 30]

print("\n2.6.6 LENGTH OF STAY VALIDATION")
print("Negative Length of Stay:", len(negative_los))
print("Zero Length of Stay:", len(zero_los))
print("Length of Stay > 30 Days:", len(los_above_30))

print("\nLength of Stay Statistics:")
print(df["Length of Stay"].describe())

invalid_room = df[
    (df["Room Number"] < 101) |
    (df["Room Number"] > 500)
]

missing_room = df["Room Number"].isna()

print("\n2.6.7 ROOM NUMBER VALIDATION")
print("Missing Room Numbers:", missing_room.sum())
print(
    "Room Numbers Outside 101-500:",
    len(invalid_room)
)

print("\nRoom Number Statistics:")
print(df["Room Number"].describe())

quality_summary = {
    "Total Records": len(df),
    "Total Columns": len(df.columns),
    "Missing Values": int(df.isnull().sum().sum()),
    "Exact Duplicate Rows": int(df.duplicated().sum()),
    "Negative Billing": len(df[df["Billing Amount"] < 0]),
    "Zero Billing": len(df[df["Billing Amount"] == 0]),
    "Invalid Age": len(
        df[(df["Age"] < 0) | (df["Age"] > 120)]
    ),
    "Invalid Date Order": len(
        df[df["Discharge Date"] < df["Date of Admission"]]
    ),
    "Negative LOS": len(df[df["Length of Stay"] < 0]),
    "LOS > 30": len(df[df["Length of Stay"] > 30]),
    "Invalid Room Number": len(
        df[
            (df["Room Number"] < 101) |
            (df["Room Number"] > 500)
        ]
    )
}

quality_summary_df = pd.DataFrame(
    list(quality_summary.items()),
    columns=["Quality Check", "Count"]
)

print("\n2.6.8 OVERALL DATA QUALITY SUMMARY")
print(quality_summary_df.to_string(index=False))

print("\n" + "=" * 60)
print("STEP 2.6 COMPLETED!")
print("=" * 60)

print("\n" + "=" * 60)
print("STEP 2.7 - FEATURE ENGINEERING")
print("=" * 60)

df["Age Group"] = pd.cut(
    df["Age"],
    bins=[0, 18, 35, 50, 65, 120],
    labels=[
        "0-18",
        "19-35",
        "36-50",
        "51-65",
        "66+"
    ]
)

print("\nAge Group Created")

df["LOS Category"] = pd.cut(
    df["Length of Stay"],
    bins=[0, 7, 14, 21, 30],
    labels=[
        "1-7 Days",
        "8-14 Days",
        "15-21 Days",
        "22-30 Days"
    ]
)

print("LOS Category Created")

df["Admission Year"] = df["Date of Admission"].dt.year
print("Admission Year Created")

df["Admission Month"] = df["Date of Admission"].dt.month
print("Admission Month Created")

df["Admission Month Name"] = (
    df["Date of Admission"].dt.month_name()
)
print("Admission Month Name Created")

df["Admission Quarter"] = (
    df["Date of Admission"].dt.quarter
)
print("Admission Quarter Created")

df["Admission Day"] = df["Date of Admission"].dt.day
print("Admission Day Created")

df["Admission Weekday"] = (
    df["Date of Admission"].dt.day_name()
)
print("Admission Weekday Created")

df["Weekend Admission"] = (
    df["Date of Admission"].dt.dayofweek >= 5
)
print("Weekend Admission Created")

df["Billing Category"] = np.select(
    [
        df["Billing Amount"] < 0,
        df["Billing Amount"] < 10000,
        df["Billing Amount"] < 25000,
        df["Billing Amount"] < 40000
    ],
    [
        "Negative",
        "Low",
        "Medium",
        "High"
    ],
    default="Very High"
)

print("Billing Category Created")

new_features = [
    "Age Group",
    "LOS Category",
    "Admission Year",
    "Admission Month",
    "Admission Month Name",
    "Admission Quarter",
    "Admission Day",
    "Admission Weekday",
    "Weekend Admission",
    "Billing Category"
]

print("\n" + "=" * 60)
print("NEW FEATURES")
print("=" * 60)

print(df[new_features].head(10))

print("\n" + "=" * 60)
print("FEATURE SUMMARY")
print("=" * 60)

for column in new_features:
    print("\n" + "-" * 50)
    print("Column:", column)
    print(df[column].value_counts(dropna=False))

print("\n" + "=" * 60)
print("STEP 2.7 COMPLETED!")
print("=" * 60)


# ============================================================
# STEP 2.8 - ADVANCED FEATURE ENGINEERING
# ============================================================

print("\n" + "=" * 60)
print("STEP 2.8 - ADVANCED FEATURE ENGINEERING")
print("=" * 60)


# ------------------------------------------------------------
# 2.8.1 PATIENT AGE BAND
# ------------------------------------------------------------

df["Patient Age Band"] = pd.cut(
    df["Age"],
    bins=[0, 18, 30, 45, 60, 75, 120],
    labels=[
        "0-18",
        "19-30",
        "31-45",
        "46-60",
        "61-75",
        "76+"
    ]
)

print("Patient Age Band Created")


# ------------------------------------------------------------
# 2.8.2 LONG STAY FLAG
# ------------------------------------------------------------

df["Long Stay Flag"] = np.where(
    df["Length of Stay"] >= 21,
    "Long Stay",
    "Normal Stay"
)

print("Long Stay Flag Created")


# ------------------------------------------------------------
# 2.8.3 HIGH BILLING FLAG
# ------------------------------------------------------------

billing_median = df["Billing Amount"].median()

df["High Billing Flag"] = np.where(
    df["Billing Amount"] > billing_median,
    "High Billing",
    "Normal Billing"
)

print("High Billing Flag Created")


# ------------------------------------------------------------
# 2.8.4 EMERGENCY ADMISSION FLAG
# ------------------------------------------------------------

df["Emergency Flag"] = np.where(
    df["Admission Type"] == "Emergency",
    "Emergency",
    "Non-Emergency"
)

print("Emergency Flag Created")


# ------------------------------------------------------------
# 2.8.5 ABNORMAL TEST FLAG
# ------------------------------------------------------------

df["Abnormal Test Flag"] = np.where(
    df["Test Results"] == "Abnormal",
    "Abnormal",
    "Not Abnormal"
)

print("Abnormal Test Flag Created")


# ------------------------------------------------------------
# 2.8.6 WEEKEND FLAG
# ------------------------------------------------------------

df["Weekend Flag"] = np.where(
    df["Weekend Admission"] == True,
    "Weekend",
    "Weekday"
)

print("Weekend Flag Created")


# ------------------------------------------------------------
# 2.8.7 ADMISSION SEASON
# ------------------------------------------------------------

df["Admission Season"] = np.select(
    [
        df["Admission Month"].isin([12, 1, 2]),
        df["Admission Month"].isin([3, 4, 5]),
        df["Admission Month"].isin([6, 7, 8])
    ],
    [
        "Winter",
        "Summer",
        "Monsoon"
    ],
    default="Autumn"
)

print("Admission Season Created")


# ------------------------------------------------------------
# 2.8.8 STAY SEVERITY
# ------------------------------------------------------------

df["Stay Severity"] = np.select(
    [
        df["Length of Stay"] <= 7,
        df["Length of Stay"] <= 14,
        df["Length of Stay"] <= 21
    ],
    [
        "Short Stay",
        "Moderate Stay",
        "Extended Stay"
    ],
    default="Long Stay"
)

print("Stay Severity Created")


# ------------------------------------------------------------
# 2.8.9 REVENUE PER STAY DAY
# ------------------------------------------------------------

df["Revenue Per Stay Day"] = np.where(
    df["Length of Stay"] > 0,
    df["Billing Amount"] / df["Length of Stay"],
    0
)

print("Revenue Per Stay Day Created")


# ------------------------------------------------------------
# 2.8.10 PATIENT AGE + LENGTH OF STAY SEGMENT
# ------------------------------------------------------------

df["Patient Stay Segment"] = (
    df["Patient Age Band"].astype(str)
    + " - "
    + df["LOS Category"].astype(str)
)

print("Patient Stay Segment Created")


# ============================================================
# DISPLAY ADVANCED FEATURES
# ============================================================

advanced_features = [
    "Patient Age Band",
    "Long Stay Flag",
    "High Billing Flag",
    "Emergency Flag",
    "Abnormal Test Flag",
    "Weekend Flag",
    "Admission Season",
    "Stay Severity",
    "Revenue Per Stay Day",
    "Patient Stay Segment"
]

print("\n" + "=" * 60)
print("ADVANCED FEATURES")
print("=" * 60)

print(
    df[advanced_features].head(10)
)


# ============================================================
# ADVANCED FEATURE SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("ADVANCED FEATURE SUMMARY")
print("=" * 60)

for column in advanced_features:

    print("\n" + "-" * 50)
    print("Column:", column)

    if pd.api.types.is_numeric_dtype(df[column]):

        print(
            df[column]
            .describe()
            .round(2)
        )

    else:

        print(
            df[column]
            .value_counts(dropna=False)
        )


print("\n" + "=" * 60)
print("STEP 2.8 COMPLETED!")
print("=" * 60)


# ============================================================
# STEP 2.9 - ADVANCED BUSINESS ANALYSIS
# ============================================================

print("\n" + "=" * 60)
print("STEP 2.9 - ADVANCED BUSINESS ANALYSIS")
print("=" * 60)


# ------------------------------------------------------------
# 2.9.1 MEDICAL CONDITION PERFORMANCE
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.1 MEDICAL CONDITION PERFORMANCE")
print("=" * 60)

condition_analysis = df.groupby(
    "Medical Condition"
).agg(
    Patients=("Name", "count"),
    Avg_Age=("Age", "mean"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean"),
    Total_Billing=("Billing Amount", "sum")
).sort_values(
    "Total_Billing",
    ascending=False
)

print(condition_analysis.round(2))


# ------------------------------------------------------------
# 2.9.2 ADMISSION TYPE PERFORMANCE
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.2 ADMISSION TYPE PERFORMANCE")
print("=" * 60)

admission_analysis = df.groupby(
    "Admission Type"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean"),
    Total_Billing=("Billing Amount", "sum")
).sort_values(
    "Patients",
    ascending=False
)

print(admission_analysis.round(2))


# ------------------------------------------------------------
# 2.9.3 INSURANCE PROVIDER PERFORMANCE
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.3 INSURANCE PROVIDER PERFORMANCE")
print("=" * 60)

insurance_analysis = df.groupby(
    "Insurance Provider"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean"),
    Total_Billing=("Billing Amount", "sum")
).sort_values(
    "Total_Billing",
    ascending=False
)

print(insurance_analysis.round(2))


# ------------------------------------------------------------
# 2.9.4 HOSPITAL PERFORMANCE
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.4 HOSPITAL PERFORMANCE")
print("=" * 60)

hospital_analysis = df.groupby(
    "Hospital"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean"),
    Total_Billing=("Billing Amount", "sum")
).sort_values(
    "Patients",
    ascending=False
)

print(
    hospital_analysis.head(20).round(2)
)


# ------------------------------------------------------------
# 2.9.5 MEDICATION ANALYSIS
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.5 MEDICATION ANALYSIS")
print("=" * 60)

medication_analysis = df.groupby(
    "Medication"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean")
).sort_values(
    "Patients",
    ascending=False
)

print(medication_analysis.round(2))


# ------------------------------------------------------------
# 2.9.6 TEST RESULT ANALYSIS
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.6 TEST RESULT ANALYSIS")
print("=" * 60)

test_analysis = df.groupby(
    "Test Results"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean")
).sort_values(
    "Patients",
    ascending=False
)

print(test_analysis.round(2))


# ------------------------------------------------------------
# 2.9.7 AGE BAND ANALYSIS
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.7 AGE BAND ANALYSIS")
print("=" * 60)

age_analysis = df.groupby(
    "Patient Age Band",
    observed=True
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean")
)

print(age_analysis.round(2))


# ------------------------------------------------------------
# 2.9.8 SEASONAL ADMISSION ANALYSIS
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.8 SEASONAL ADMISSION ANALYSIS")
print("=" * 60)

season_analysis = df.groupby(
    "Admission Season"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean")
).sort_values(
    "Patients",
    ascending=False
)

print(season_analysis.round(2))


# ------------------------------------------------------------
# 2.9.9 WEEKEND vs WEEKDAY
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.9 WEEKEND vs WEEKDAY ANALYSIS")
print("=" * 60)

weekend_analysis = df.groupby(
    "Weekend Flag"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean")
)

print(weekend_analysis.round(2))


# ------------------------------------------------------------
# 2.9.10 EMERGENCY ANALYSIS
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("2.9.10 EMERGENCY ADMISSION ANALYSIS")
print("=" * 60)

emergency_analysis = df.groupby(
    "Emergency Flag"
).agg(
    Patients=("Name", "count"),
    Avg_LOS=("Length of Stay", "mean"),
    Avg_Billing=("Billing Amount", "mean"),
    Total_Billing=("Billing Amount", "sum")
)

print(emergency_analysis.round(2))


print("\n" + "=" * 60)
print("STEP 2.9 COMPLETED!")
print("=" * 60)


# ============================================================
# STEP 2.10 - FINAL DATA QUALITY CHECK
# ============================================================

print("\n" + "=" * 60)
print("STEP 2.10 - FINAL DATA QUALITY CHECK")
print("=" * 60)

total_missing = int(
    df.isnull().sum().sum()
)

total_duplicates = int(
    df.duplicated().sum()
)

negative_billing_count = int(
    (df["Billing Amount"] < 0).sum()
)

invalid_age_count = int(
    (
        (df["Age"] < 0) |
        (df["Age"] > 120)
    ).sum()
)

invalid_date_count = int(
    (
        df["Discharge Date"] <
        df["Date of Admission"]
    ).sum()
)

negative_los_count = int(
    (df["Length of Stay"] < 0).sum()
)

los_above_30_count = int(
    (df["Length of Stay"] > 30).sum()
)

print("\nTotal Records:", len(df))
print("Total Columns:", len(df.columns))
print("Total Missing Values:", total_missing)
print("Total Duplicate Rows:", total_duplicates)
print("Negative Billing Records:", negative_billing_count)
print("Invalid Age Records:", invalid_age_count)
print("Invalid Date Records:", invalid_date_count)
print("Negative LOS Records:", negative_los_count)
print("LOS Greater Than 30:", los_above_30_count)


# ------------------------------------------------------------
# FINAL QUALITY SUMMARY TABLE
# ------------------------------------------------------------

final_quality_summary = pd.DataFrame({
    "Quality Check": [
        "Total Records",
        "Total Columns",
        "Missing Values",
        "Duplicate Rows",
        "Negative Billing",
        "Invalid Age",
        "Invalid Date Order",
        "Negative LOS",
        "LOS > 30"
    ],
    "Count": [
        len(df),
        len(df.columns),
        total_missing,
        total_duplicates,
        negative_billing_count,
        invalid_age_count,
        invalid_date_count,
        negative_los_count,
        los_above_30_count
    ]
})

print("\n" + "=" * 60)
print("FINAL QUALITY SUMMARY")
print("=" * 60)

print(
    final_quality_summary.to_string(index=False)
)

print("\n" + "=" * 60)
print("STEP 2.10 COMPLETED!")
print("=" * 60)


# ============================================================
# STEP 2.11 - SAVE FEATURE ENGINEERED DATA
# ============================================================

print("\n" + "=" * 60)
print("STEP 2.11 - EXPORT FEATURE ENGINEERED DATA")
print("=" * 60)

output_path = "data/medipulse_feature_engineered.csv"

df.to_csv(
    output_path,
    index=False
)

print(
    "\nFeature engineered dataset saved successfully:"
)

print(output_path)

print("\nFinal Dataset Shape:")
print(df.shape)

print("\nFinal Dataset Columns:")

for column in df.columns:
    print(column)


print("\n" + "=" * 60)
print("PYTHON EDA & FEATURE ENGINEERING COMPLETED!")
print("=" * 60)
# ============================================================
# STEP 3 - DATA CLEANING
# ============================================================

print("\n" + "=" * 60)
print("STEP 3 - DATA CLEANING")
print("=" * 60)


# ------------------------------------------------------------
# 3.1 BEFORE CLEANING SUMMARY
# ------------------------------------------------------------

print("\n" + "=" * 60)
print("3.1 BEFORE CLEANING")
print("=" * 60)

before_records = len(df)
before_columns = len(df.columns)
before_duplicates = df.duplicated().sum()
before_negative_billing = (
    df["Billing Amount"] < 0
).sum()

print("Records Before Cleaning:", before_records)
print("Columns Before Cleaning:", before_columns)
print("Duplicate Rows:", before_duplicates)
print("Negative Billing Records:", before_negative_billing)


# ------------------------------------------------------------
# 3.2 SAVE NEGATIVE BILLING RECORDS FOR REVIEW
# ------------------------------------------------------------

negative_billing_records = df[
    df["Billing Amount"] < 0
].copy()

print("\nNegative billing records saved for review:")
print(len(negative_billing_records))


# ------------------------------------------------------------
# 3.3 REMOVE EXACT DUPLICATES
# ------------------------------------------------------------

duplicates_removed = df.duplicated().sum()

df = df.drop_duplicates().copy()

print("\nExact Duplicate Rows Removed:", duplicates_removed)


# ------------------------------------------------------------
# 3.4 REMOVE NEGATIVE BILLING FROM ANALYTICAL DATA
# ------------------------------------------------------------

negative_removed = (
    df["Billing Amount"] < 0
).sum()

df = df[
    df["Billing Amount"] >= 0
].copy()

print(
    "Negative Billing Records Removed:",
    negative_removed
)


# ------------------------------------------------------------
# 3.5 STANDARDIZE TEXT COLUMNS
# ------------------------------------------------------------

text_columns = [
    "Name",
    "Gender",
    "Blood Type",
    "Medical Condition",
    "Doctor",
    "Hospital",
    "Insurance Provider",
    "Admission Type",
    "Medication",
    "Test Results"
]

for column in text_columns:

    df[column] = (
        df[column]
        .astype("string")
        .str.strip()
    )

print("\nText Standardization Completed")


# ------------------------------------------------------------
# 3.6 STANDARDIZE GENDER
# ------------------------------------------------------------

df["Gender"] = (
    df["Gender"]
    .str.title()
)

print("Gender Standardization Completed")


# ------------------------------------------------------------
# 3.7 STANDARDIZE BLOOD TYPE
# ------------------------------------------------------------

df["Blood Type"] = (
    df["Blood Type"]
    .str.upper()
    .str.strip()
)

print("Blood Type Standardization Completed")


# ------------------------------------------------------------
# 3.8 STANDARDIZE CATEGORICAL COLUMNS
# ------------------------------------------------------------

categorical_standardization_columns = [
    "Medical Condition",
    "Insurance Provider",
    "Admission Type",
    "Medication",
    "Test Results"
]

for column in categorical_standardization_columns:

    df[column] = (
        df[column]
        .str.title()
    )

print("Categorical Standardization Completed")


# ------------------------------------------------------------
# 3.9 NUMERIC DATA VALIDATION
# ------------------------------------------------------------

df["Age"] = pd.to_numeric(
    df["Age"],
    errors="coerce"
)

df["Billing Amount"] = pd.to_numeric(
    df["Billing Amount"],
    errors="coerce"
)

df["Room Number"] = pd.to_numeric(
    df["Room Number"],
    errors="coerce"
)

print("\nNumeric Data Validation Completed")


# ------------------------------------------------------------
# 3.10 DATE VALIDATION
# ------------------------------------------------------------

df["Date of Admission"] = pd.to_datetime(
    df["Date of Admission"],
    errors="coerce"
)

df["Discharge Date"] = pd.to_datetime(
    df["Discharge Date"],
    errors="coerce"
)

print("Date Validation Completed")


# ------------------------------------------------------------
# 3.11 RECHECK LENGTH OF STAY
# ------------------------------------------------------------

df["Length of Stay"] = (
    df["Discharge Date"] -
    df["Date of Admission"]
).dt.days

print("Length of Stay Recalculated")


# ------------------------------------------------------------
# 3.12 REMOVE INVALID RECORDS
# ------------------------------------------------------------

invalid_age = (
    (df["Age"] < 0) |
    (df["Age"] > 120)
)

invalid_dates = (
    df["Discharge Date"] <
    df["Date of Admission"]
)

invalid_los = (
    df["Length of Stay"] < 0
)

invalid_room = (
    (df["Room Number"] < 101) |
    (df["Room Number"] > 500)
)

invalid_records = (
    invalid_age |
    invalid_dates |
    invalid_los |
    invalid_room
)

invalid_record_count = invalid_records.sum()

print(
    "\nInvalid Records Identified:",
    invalid_record_count
)

df = df[
    ~invalid_records
].copy()

print(
    "Invalid Records Removed:",
    invalid_record_count
)


# ------------------------------------------------------------
# 3.13 MISSING VALUE CHECK
# ------------------------------------------------------------

missing_values = df.isnull().sum()

total_missing_values = (
    missing_values.sum()
)

print("\nTotal Missing Values After Cleaning:")
print(total_missing_values)

if total_missing_values > 0:

    print("\nColumns With Missing Values:")

    print(
        missing_values[
            missing_values > 0
        ]
    )

else:

    print("No Missing Values Found")


# ============================================================
# STEP 3.14 - FINAL CLEANING QUALITY CHECK
# ============================================================

print("\n" + "=" * 60)
print("3.14 FINAL CLEANING QUALITY CHECK")
print("=" * 60)

final_duplicates = df.duplicated().sum()

final_negative_billing = (
    df["Billing Amount"] < 0
).sum()

final_invalid_age = (
    (
        (df["Age"] < 0) |
        (df["Age"] > 120)
    ).sum()
)

final_invalid_dates = (
    (
        df["Discharge Date"] <
        df["Date of Admission"]
    ).sum()
)

final_negative_los = (
    df["Length of Stay"] < 0
).sum()

final_invalid_rooms = (
    (
        (df["Room Number"] < 101) |
        (df["Room Number"] > 500)
    ).sum()
)

final_missing = (
    df.isnull().sum().sum()
)


print("Final Records:", len(df))
print("Final Columns:", len(df.columns))
print("Duplicate Rows:", final_duplicates)
print("Negative Billing:", final_negative_billing)
print("Invalid Age:", final_invalid_age)
print("Invalid Dates:", final_invalid_dates)
print("Negative LOS:", final_negative_los)
print("Invalid Room Numbers:", final_invalid_rooms)
print("Missing Values:", final_missing)


# ============================================================
# STEP 3.15 - BEFORE vs AFTER CLEANING
# ============================================================

print("\n" + "=" * 60)
print("3.15 BEFORE vs AFTER CLEANING")
print("=" * 60)

cleaning_summary = pd.DataFrame({
    "Metric": [
        "Total Records",
        "Duplicate Rows",
        "Negative Billing",
        "Missing Values"
    ],
    "Before Cleaning": [
        before_records,
        before_duplicates,
        before_negative_billing,
        0
    ],
    "After Cleaning": [
        len(df),
        final_duplicates,
        final_negative_billing,
        final_missing
    ]
})

print(
    cleaning_summary.to_string(
        index=False
    )
)


# ============================================================
# STEP 3.16 - SAVE CLEAN DATASET
# ============================================================

print("\n" + "=" * 60)
print("3.16 EXPORT CLEAN DATASET")
print("=" * 60)

cleaned_output_path = (
    "data/medipulse_cleaned.csv"
)

df.to_csv(
    cleaned_output_path,
    index=False
)

print(
    "\nCleaned dataset saved successfully:"
)

print(cleaned_output_path)

print("\nClean Dataset Shape:")
print(df.shape)


# ------------------------------------------------------------
# SAVE INVALID BILLING RECORDS
# ------------------------------------------------------------

negative_billing_output_path = (
    "data/medipulse_negative_billing_review.csv"
)

negative_billing_records.to_csv(
    negative_billing_output_path,
    index=False
)

print(
    "\nNegative billing review file saved:"
)

print(
    negative_billing_output_path
)


# ============================================================
# STEP 3 COMPLETED
# ============================================================

print("\n" + "=" * 60)
print("STEP 3 - DATA CLEANING COMPLETED!")
print("=" * 60)