# Apparently I need to re-write this thing...
# ... man, I spent like all day Friday writing this goddamn thing.

suppressWarnings(library(RSQLite))

conn = dbConnect(SQLite(), "common/data/modeling_results.db")

commit_id = system("git rev-parse HEAD", intern=TRUE)
current_date = Sys.time()

#####################################################
# Functions for logging model results               #
#                                                   #
# Workhorse function:            log_model_result() #
# Useful supplementary function: prep_results()     #
#                                                   #
# o.w. functions can be interpreted as private      #
#####################################################


get_exp_id = function(task_name, mod_name){
  qry = "
    select id from experiments 
    where 1=1
    and task_name = ?
    and model_name = ?
    and commit_id = ?
  "
  payload = data.frame(task_name, mod_name, commit_id)
  exp_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  if(is.na(exp_id)){
    insrt = "
      INSERT into experiments (task_name, model_name, commit_id, created_date) VALUES (?,?,?,?)
    "
    payload2 = payload; payload2$created_date = current_date
    dbSendPreparedQuery(conn, insrt, bind.data=payload2)
    exp_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  }
  exp_id
}

get_result_id = function(exp_id, result_name){
  qry = "select id from results where exp_id = ? and result_name = ?"
  payload = data.frame(exp_id, result_name)
  res_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  if(is.na(res_id)){
    insrt = "
      INSERT into results (exp_id, result_name, created_date) VALUES (?,?,?)
    "
    payload2 = payload; payload2$created_date = current_date
    dbSendPreparedQuery(conn, insrt, bind.data=payload2)
    res_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  }
  res_id
}

prep_results = function(results){
  suppressWarnings(library(tidyr))
  n = nrow(results)
  m = gather(data.frame(row_id=1:n, results, stringsAsFactors=FALSE), "row_id")
  names(m) = c("row_id", "field_name", "value")
  m
}

insert_results = function(result_id, results, overwrite=TRUE){
  if(overwrite){
    dbSendQuery(conn, "DELETE FROM RESULTS_DATA_NUMERIC where result_id = ?", list(result_id))
    dbSendQuery(conn, "DELETE FROM RESULTS_DATA_TEXT    where result_id = ?", list(result_id))
  }
  
  # assumes "results" doesn't need to be melted 
  is_numeric = !is.na(as.numeric(results$value))
  insert_results_helper(result_id, results[is_numeric,], 'NUMERIC')
  insert_results_helper(result_id, results[!is_numeric,], 'TEXT')
}

insert_results_helper=function(result_id, payload, type){
  tbl_tgt = paste0("RESULTS_DATA_", type)
  tbl_stg = paste0("STG_",tbl_tgt)
  if(nrow(payload)>0){
    dbWriteTable(conn, tbl_stg, payload, overwrite=TRUE)
    insrt = paste0("INSERT INTO ", tbl_tgt," (result_id, result_row, result_field, value) ",
                   "select ",result_id, ", * from ", tbl_stg)                
    dbSendPreparedQuery(conn, insrt, payload)
    dbRemoveTable(conn, tbl_stg)
  }
}

log_model_result = function(task_name, model_name, result_name, results){
  exp_id = suppressWarnings(get_exp_id(task_name, model_name))
  res_id = suppressWarnings(get_result_id(exp_id, result_name))
  suppressWarnings(insert_results(res_id, results))
}

############################################
# Functions for logging dataset statistics #
# Workhorse function: log_dataset_stats()  #
############################################

# get_exp_id = function(task_name, mod_name){
# get_result_id = function(exp_id, result_name){
# prep_results = function(results){
# insert_results = function(result_id, results, overwrite=TRUE){
# insert_results_helper=function(result_id, payload, type){
# log_model_result = function(task_name, model_name, result_name, results){

get_dataset_id = function(dataset_name, fpath, description=NULL){
    qry = "
        select id from datasets 
        where 1=1
        and name = ?
        and fpath = ?
        and description = ?
        "
    payload = data.frame(dataset_name, fpath, description)
    dataset_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
    if(is.na(dataset_id)){
    insrt = "
      INSERT into datasets (name, fpath, description, created_date) VALUES (?,?,?,?)
    "
    payload2 = payload; payload2$created_date = current_date
    dbSendPreparedQuery(conn, insrt, bind.data=payload2)
    dataset_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  }
  dataset_id
}

# This is super similar to get_experiment_id. I should look into abstracting
# out a generic function for doing this on any table and set of identifiers
get_field_id = function(dataset_id, field_name, field_type=NULL){
    qry = "
        select id from fields 
        where 1=1
        and dataset_id = ?
        and field_name = ?
        and field_type = ?
        "
    payload = data.frame(dataset_id, field_name, field_type)
    field_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
    if(is.na(field_id)){
    insrt = "
      INSERT into fields (dataset_id, field_name, field_type, created_date) VALUES (?,?,?,?)
    "
    payload2 = payload; payload2$created_date = current_date
    dbSendPreparedQuery(conn, insrt, bind.data=payload2)
    field_id = dbGetPreparedQuery(conn, qry, bind.data=payload)[1,1]
  }
  field_id
}

# I really need to break this up into a bunch of different functions
log_dataset_stats_helper = function(dataset_id, report){
    base_insrt_stmt = "
        INSERT INTO field_stats (field_id, stat_name, stat_value, created_date) 
        VALUES (?,?,?,?)
    "

    #source('common/src/utils/data_quality_report.r')
    #report = data_quality_report(dataset)
    
    # 1. Log stats for full dataset
    general_id = get_field_id(dataset_id, "", "GENERAL")
    
    payload = data.frame(field_id = general_id, 
                         stat_name  = 'n', 
                         stat_value = report[['n']],
                         created_date = current_date)
    dbSendPreparedQuery(conn, base_insrt_stmt, payload)
    
    for(i in 1:length(report[['dim']])){
        payload$stat_name  = paste0("dim_",i)
        payload$stat_value = report[['dim']][i]
        dbSendPreparedQuery(conn, base_insrt_stmt, payload)
    }
    
    # 2. Log stats for each field
    for(f in names(report[['columns']])){
        f_meta = report[['columns']][[f]]
        field_id = get_field_id(dataset_id, f, f_meta[['datatype']])
        stats = setdiff(names(report[['columns']][[f]]), 'datatype')
        for(stat in stats){
            if(stat!='table'){
                payload$field_id = field_id
                payload$stat_name = stat
                payload$stat_value = f_meta[[stat]]
                dbSendPreparedQuery(conn, base_insrt_stmt, payload)
            } else {
                log_table_results(field_id, f_meta[['table']] )
            }
        }
    }
}

log_table_results = function(field_id, freq_table){
    insrt_stmt = "INSERT INTO field_values_table (field_id, value, freq, created_date) VALUES (?,?,?,?)"
    values = names(freq_table)
    for(v in values){
        payload = data.frame(field_id = field_id, 
                             value = v, 
                             freq = freq_table[[v]], 
                             created_date = current_date)
        dbSendPreparedQuery(conn, insrt_stmt, payload)
    }
}

log_data_profile = function(dataset_name, report, fpath, description=NULL){
    dataset_id = get_dataset_id(dataset_name, fpath, description)
    log_dataset_stats_helper(dataset_id, report)
}