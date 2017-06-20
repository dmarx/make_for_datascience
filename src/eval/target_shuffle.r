target_shuffle = function(k, x, y, fitModel, stat, returnValues=TRUE, estimateSignificance=TRUE, ...){
  results = rep(NULL, k)
  for(i in 1:k){
    shuffled_y = sample(y, length(y))  
    mod = fitModel(x, shuffled_y)
    results[i] = stat(mod, x, shuffled_y, ...)
  }  
  retval=list()
  if(returnValues) retval$values = results
  if(estimateSignificance){
    retval$mod = fitModel(x,y)
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

accuracy = function(mod, X, Y){
  mean(Y == predict_model(mod, X, type="class") )
}

rsqrd = function(mod, ...){
  summary(mod)$r.squared
}

# Add more stats later
statistics = list(accuracy = accuracy, 
             rsqrd=rsqrd)

args <- commandArgs(TRUE) ## src/modeling/models/task0/logreg.r accuracy
if(length(args)>0){
  mod_funcs = args[1]
  stat_name = args[2]
  mod_name = gsub("src/modeling/models/(task.*/.*\\.r)","\\1", mod_funcs) ## task0/logreg.rdata
  task_name = dirname(mod_name)
  data_path = paste0("data/processed/", task_name, "/train.rdata")
  
  load(data_path) 
  stat_func = statistics[[stat_name]]
  
  source(mod_funcs)
  
  k = 200
  results = target_shuffle(k, X, Y, train_model, stat_func, returnValues=TRUE, estimateSignificance=TRUE)
  
  fname = paste0("data/processed/", mod_name, "_tshuffle.rdata")
  dir.create(dirname(fname), showWarnings = FALSE)
  save(results, file = fname)
  
  agg_results = data.frame(est_pval = results$est_pval)
  
  ### If bootstrap has been done, maybe calculate an interval around the p-val estimate.
  fname = paste0("reports/", mod_name, "_tshuffle.txt")
  dir.create(dirname(fname), showWarnings = FALSE)
  write.csv(agg_results, file = fname)
  
  source("src/eval/eval_db/dbapi.r")
  result_name = paste("target_shuffle",stat_name, k, sep="_") 
  m = prep_results(agg_results)

  log_model_result(mod_name, result_name, m)
  dbDisconnect(conn)
}