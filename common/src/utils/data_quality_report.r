# Generic data QA
#
# For each rdata file in a directory:
# 1. Read in all rdata files
# 2. For each column in each dataframe/datatable/list object added to the environment, report on:
#   a. The data type of the column
#   b. The number of non-null records 
# 3. Flag datasets where any columns contain a significant amount of nulls (relative to the size of the dataset)
#    or where the dataset is itself empty.

# For factors: give number of factor levels. If < 20, call `table()` on levels. if > 100, flag dataset

vector_report = function(v, n, hist_threshold=20){
  # Report for a single vector, i.e. a column from a dataframe
  report = list()
  report$datatype = class(v)
  report$length = length(v)
  report$uniques = length(unique(v))
  if(report$uniques<=hist_threshold){
    report$table = table(v)
  }
  if(is.numeric(v)){
    #report$quantiles = quantile(v,c(0, .0275, .25, .5, .75, .975, 1))
    report$min = min(v, na.rm=TRUE)
    report$max = max(v, na.rm=TRUE)
    report$mean = mean(v, na.rm=TRUE)
    report$median = median(v, na.rm=TRUE)
    report$sd = sd(v, na.rm=TRUE)
  }
  
  report$bad_records = 0
  null = sum(is.null(v))
  if(null) {
    report$null = null
    report$bad_records = report$bad_records + null
  }
  na = sum(is.na(v))
  if(na) {
    report$na = na
    report$bad_records = report$bad_records + na
  }
  if(is.factor(v) | is.character(v)){
    empty = sum(v=="", na.rm=TRUE)
    if(length(empty)>0){
      report$empty = empty
      report$bad_records = report$bad_records + empty
    }
    chars = nchar(as.character(v))
    report$minchars  = min(chars)
    report$maxchars  = max(chars)
    report$meanchars = mean(chars)
  }
  
  if(is.factor(v)){
    report$nlevels = length(levels(v))
  }
  
  report$flag = flag_report(report, n)
  
  list(report)
}

flag_report = function(report, n, bad_perc=.25, max_factor_levels=100){
  flag = c()
  #if(report$bad >= bad_perc*report$length | report$bad >= bad_perc*n) flag = TRUE
  if(report$bad_records >= bad_perc*report$length | report$bad_records >= bad_perc*n) {
    if(report$bad_records == n){
      flag = c(flag, "Empty column")
    } else {
      flag = c(flag, paste("More than",bad_perc,"bad records."))
    }
  }
  if(report$length == 0){ 
    flag= c(flag, "Zero length column.") }
  if (report$datatype == "factor"){
    if(report$nlevels >= max_factor_levels){ 
      flag = c(flag, paste("Greater than",max_factor_levels,"factor levels."))}
    if(report$nlevels != report$uniques){  # This might not be a good flag
      flag = c(flag, "Number of factor levels is different from number of unique values in column.")
    }
  }
  flag
}


data_quality_report_DF = function(dataset, dataset_name){
  # For dataframes/datatables
  d = dim(dataset)
  n = nrow(dataset)
  report = list()
  report$object_name = dataset_name
  report$dim = d
  report$n = n
  if(n==0){
    report$flags="Empty Dataframe"
    return(report)
  }
  report$columns=list()
  flags = list()
  for(i in 1:ncol(dataset)){
    column_name = colnames(dataset)[i]
    col = dataset[,i]
    col_report = list()
    col_report$details = vector_report(col, n)
    # Flag bad column names
    if(length(grep("^V[0-9]*$",column_name))) col_report$details[[1]]$flag = c(col_report$details[[1]]$flag, "Default column name.")
    if(length(grep("^X[.][0-9]*$",column_name))) col_report$details[[1]]$flag = c(col_report$details[[1]]$flag, "Default column name.")
    # Add column to list of flagged columns if necessary. Should make this more detailed.
    if(length(col_report$details[[1]]$flag)>0){
      flags[column_name] = list(col_report$details[[1]]$flag)
    }
    col_report$column_name = colnames(dataset)[i]
    report$columns[col_report$column_name] = col_report$details
  }
  if(length(flags)>0) report$flags = flags
  report
}

data_quality_report = function(dataset, dataset_name = NULL, file=NULL, detailed=TRUE){
  #dataset_name =  get_name(dataset)
  if(is.data.frame(dataset)) {
    if(!is.null(file)){
      sink(file)
    }
    report = data_quality_report_DF(dataset, dataset_name)
    if(!detailed){report$columns=NULL}
    if(!is.null(file)){
      stringify_report(report)
      sink(NULL)
    }
  } else{
    warning("Datatype not supported")
  }
  report
}

stringify_report = function(report){
  # str Doesn't seem to care what parameters I use... :(
  str(report, give.length=FALSE, give.head=FALSE, no.list=TRUE
      ,indent.str = '  ', com.str = " "
  )
}


get_name = function(dataset) deparse(substitute(dataset))

report_on_all_env_objs = function(...){
  reports = list()
  for(obj_name in ls(.GlobalEnv)){
    obj=get(obj_name)
    print(c(obj_name, class(obj)))
    if(is.data.frame(obj)){
      reports[obj_name] = list(data_quality_report(obj, obj_name, ...))
    }
  }
  reports
}

dump_reports = function(reports, report_on_flags=TRUE, flags_only=FALSE, separate_files=TRUE, fname="data_quality_report.txt"){
  flags=list()
  for(i in 1:length(reports)){
    if(separate_files){
      object_name = names(reports)[i]
      report = reports[[i]]
      if(!flags_only){
        fname = paste(object_name, '.txt', sep='')
        sink(fname)
        stringify_report(report)
        sink(NULL)
        print(fname)
      }
      ############
      if(!is.null(report$flags)){flags[object_name] = list(report$flags) }
    } else {
      if(i==1) sink(fname)
      stringify_report(report)
    }
    if(!separate_files) sink(NULL)
  }
  if(report_on_flags){
    sink("__flagged_objects.txt")
    stringify_report(flags)
    sink(NULL)
  }
}

if(1==0){
  data(iris)
  #test = data_quality_report(iris)
  #stringify_report(test)
  #data_quality_report(matrix())
  ##################
  #rm(list=ls())
  setwd("Projects/Toy\ Projects/make_for_datascience")
  
  # Load all RData objs into environment  
  #dummy_ = lapply(list.files(), function(x) tryCatch(load(file=x, envir=.GlobalEnv), except=function(e) print("except"), warning=function(w) print("warning")))
  
  # Calculate data quality reports
  reports = report_on_all_env_objs(detailed=TRUE)
  #dump_reports(reports, report_on_flags=TRUE)
  
  names(reports[['iris']]) # "object_name" "dim"         "n"           "columns" 
  
  reports[['iris']][['object_name']] # iris
  reports[['iris']][['dim']] # 150 5
  reports[['iris']][['n']] # 150
  
  names(reports[['iris']][['columns']]) # "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species" 
  
  names(reports[['iris']][['columns']][['Sepal.Length']])
  #[1] "datatype"    "length"      "uniques"     "min"         "max"         "mean"       
  #[7] "median"      "sd"          "bad_records"
  
  names(reports[['iris']][['columns']][['Species']])
  # [1] "datatype"    "length"      "uniques"     "table"       "bad_records" "empty"      
  # [7] "minchars"    "maxchars"    "meanchars"   "nlevels"
  
  # This is basically for pretty-printing everything
  stringify_report(reports)
  
  dump_reports(reports)
  
  source("common/src/eval/eval_db/dbapi.r")
  
  report = data_quality_report(iris)
  log_data_profile('iris', report, 'path/to/file', description="DQR test")
  dbGetQuery(conn, "select * from datasets")
  dbGetQuery(conn, "select * from fields")
  dbGetQuery(conn, "select * from field_stats")
  dbDisconnect(conn)
}