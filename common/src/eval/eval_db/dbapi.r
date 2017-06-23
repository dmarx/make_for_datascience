# Apparently I need to re-write this thing...
# ... man, I spent like all day Friday writing this goddamn thing.

suppressWarnings(library(RSQLite))

conn = dbConnect(SQLite(), "common/data/modeling_results.db")

commit_id = system("git rev-parse HEAD", intern=TRUE)
current_date = Sys.time()

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