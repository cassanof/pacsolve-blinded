import csv
import sys

file = sys.argv[1]
print("name,commit,solver,CVE,NDeps,Status,Time")
# original:
# Project,Rosette,AuditFix,Consistency,Minimize,DisallowCycles,Time,NDeps,CVE,Status
with open(file, newline='') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        new_row = [""] * 7
        new_row[0] = row[0]
        new_row[1] = "NA"

        if row[1] == "False" and row[2] == "no":
            new_row[2] = "vanilla"
        elif row[1] == "False" and row[2] == "yes":
            new_row[2] = "audit fix"
        elif row[1] == "False" and row[2] == "force":
            new_row[2] = "audit fix force"
        elif row[1] == "True" and row[4] == "min_cve,min_oldness":
            new_row[2] = "maxnpm_cve_oldness"
        elif row[1] == "True" and row[4] == "min_oldness,min_cve":
            new_row[2] = "maxnpm_oldness_cve"
        else:
            continue

        new_row[3] = row[8]
        new_row[4] = row[7]
        new_row[5] = row[9]
        new_row[6] = row[6]

        print(",".join(new_row))
