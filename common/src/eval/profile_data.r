outpath <- commandArgs(TRUE)

source('common/src/utils/data_quality_report.r')
source('common/src/eval/eval_db/dbapi.r')

#pat_str = "(task.*)/reports/(.*\\.rdata)_data_profile.txt"
pat_str = "(task.*)/reports/(.*)_data_profile.txt"
task_name    = gsub(pat_str,"\\1", outpath)
dataset_name = gsub(pat_str,"\\2", outpath)

data_path = paste0(task_name, "/data/processed/",dataset_name,".rdata")

load(data_path)

# This assumes that the object we're interested in has the same name as the 
# rdata object.
report = data_quality_report(eval(as.name(dataset_name)))
#report = data_quality_report(analyticBaseTable)

sink(outpath)
stringify_report(report)
sink(NULL)

log_data_profile(dataset_name, report, data_path)