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

args <- commandArgs(TRUE)
if(length(args)>0){
  mod_funcs = args[1]
  stat_name = args[2]
  mod_name_full = basename(mod_funcs)
  mod_name = strsplit(mod_name_full, '\\.r')[[1]]
  stat_func = statistics[[stat_name]]
  
  source(mod_funcs)
  load("data/processed/train.rdata")
  k = 200
  #results = boot_stat(k, X, Y, train_model, stat_func)
  results = target_shuffle(k, X, Y, train_model, stat_func, returnValues=TRUE, estimateSignificance=TRUE)
  
  #fname = paste0("data/bootstrap_", mod_name, ".rdata")
  fname = paste0("data/tshuffle_", mod_name, ".rdata")
  save(results, file = fname)
  
  #agg_results = t(data.frame(quantile(results, c(.05, .5, .95))))
  #rownames(agg_results) = stat_name
  agg_results = data.frame(est_pval = results$est_pval)
  
  ### If bootstrap has been done, maybe calculate an interval around the p-val estimate.
  
  #fname = paste0("reports/bootstrap_", mod_name, ".txt")
  fname = paste0("reports/tshuffle_", mod_name, ".txt")
  write.csv(agg_results, file = fname)
  
  source("src/eval/eval_db/dbapi.r")
  result_name = paste("target_shuffle",stat_name, k, sep="_") 
  m = prep_results(agg_results)

  log_model_result(mod_name_full, result_name, m)
  dbDisconnect(conn)
}