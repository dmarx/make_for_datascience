boot_stat = function(k, x, y, fitModel, stat){
  results = rep(NULL, k)
  full_dat = cbind(y,x)
  n = nrow(x)
  for(i in 1:k){
    ix = sample(n, replace=TRUE)
    xa = x[ix,]
    ya = y[ix]
    xb = x[-ix,]
    yb = y[-ix]
    
    mod = fitModel(xa, ya)
    results[i] = stat(mod, xb, yb)
  }
  results
}

accuracy = function(mod, X, Y){
  mean(Y == predict_model(mod, X, type="class") )
}

rsqrd = function(mod, ...){
  summary(mod)$r.squared
}

# Add more stats later
statistics = list(accuracy = accuracy, 
             rsqrd=rsqrd)

args <- commandArgs(TRUE)  ## reports/task0/logreg.r_bootstrap.txt accuracy
if(length(args)>0){
  outpath = args[1]
  mod_name = gsub("reports/(task.*/.*\\.r)_bootstrap.txt","\\1", outpath)
  stat_name = args[2]
  task_name = dirname(mod_name)
  data_path = paste0("data/processed/", task_name, "/train.rdata")
  
  load(data_path) 
  stat_func = statistics[[stat_name]]
  
  mod_funcs = paste0("src/modeling/models/", mod_name)
  source(mod_funcs)
  
  k = 200
  results = boot_stat(k, X, Y, train_model, stat_func)
  
  fname = paste0("data/processed/", mod_name, "_bootstrap.rdata")
  dir.create(dirname(fname), showWarnings = FALSE)
  save(results, file = fname)
  
  agg_results = t(data.frame(quantile(results, c(.05, .5, .95))))
  rownames(agg_results) = stat_name
  
  dir.create(dirname(outpath), showWarnings = FALSE)
  write.csv(agg_results, file = outpath)
  
  source("src/eval/eval_db/dbapi.r")
  result_name = paste("bootstrap",stat_name, k, sep="_") 
  m = prep_results(agg_results)
  m$field_name = gsub("X([0-9]{1,2})\\.$", "\\1%", m$field_name)
  m$field_name = gsub("X([0-9]{1,2}\\.[0-9]+)$", "\\1%", m$field_name)
  
  log_model_result(mod_name, result_name, m)
  dbDisconnect(conn)
}
