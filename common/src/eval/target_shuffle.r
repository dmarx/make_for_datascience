source("common/src/eval/basic_stats.r") # For "statistics" list

target_shuffle = function(k, x, y, fitModel, stat, returnValues=TRUE, estimateSignificance=TRUE, ...){
  results = rep(NULL, k)
  for(i in 1:k){
    shuffled_y = sample(y, length(y))  
    mod = suppressWarnings(fitModel(x, shuffled_y))
    results[i] = stat(mod, x, shuffled_y, ...)
  }  
  retval=list()
  if(returnValues) retval$values = results
  if(estimateSignificance){
    retval$mod = suppressWarnings(fitModel(x,y))
    retval$obs_stat = stat(retval$mod, x, y, ...)
    retval$est_pval = 1- mean(retval$obs_stat > results)
  }
  retval
}

#####################################
## Scavenged from bootstrap.r      ##
## Should try abstract this out.   ##
## Basically only changed one line ##
#####################################

args <- commandArgs(TRUE) ## reports/task0/logreg.r_tshuffle.txt accuracy
if(length(args)>0){
  outpath = args[1]
  task_name = gsub("(task.*)/reports/(.*\\.r)_tshuffle.txt","\\1", outpath)
  mod_name  = gsub("(task.*)/reports/(.*\\.r)_tshuffle.txt","\\2", outpath)
  stat_name = args[2]
  data_path = paste0(task_name, "/data/processed/train.rdata")
  
  load(data_path) 
  stat_func = statistics[[stat_name]]
  
  mod_funcs = paste0(task_name, "/src/models/", mod_name)
  source(mod_funcs)
  
  k = 200
  results = target_shuffle(k, X, Y, train_model, stat_func, returnValues=TRUE, estimateSignificance=TRUE)
  
  fname = paste0(task_name, "/data/processed/", mod_name, "_tshuffle.rdata")
  dir.create(dirname(fname), showWarnings = FALSE)
  save(results, file = fname)
  
  agg_results = data.frame(est_pval = results$est_pval)
  
  ### If bootstrap has been done, maybe calculate an interval around the p-val estimate.
  dir.create(dirname(outpath), showWarnings = FALSE)
  write.csv(agg_results, file = outpath)
  
  source("common/src/eval/eval_db/dbapi.r")
  result_name = paste("target_shuffle",stat_name, k, sep="_") 
  m = prep_results(agg_results)

  log_model_result(paste0(task_name, '/', mod_name), result_name, m)
  dbDisconnect(conn)
}