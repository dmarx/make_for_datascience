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
  results = boot_stat(k, X, Y, train_model, stat_func)
  
  fname = paste0("data/bootstrap_", mod_name, ".rdata")
  save(results, file = fname)
  
  agg_results = t(data.frame(quantile(results, c(.05, .5, .95))))
  rownames(agg_results) = stat_name
  
  fname = paste0("reports/bootstrap_", mod_name, ".txt")
  write.csv(agg_results, file = fname)
  
  source("src/eval/eval_db/dbapi.r")
  result_name = paste("bootstrap",stat_name, k, sep="_") 
  m = prep_results(agg_results)
  m$field_name = gsub("X([0-9]{1,2})\\.$", "\\1%", m$field_name)
  m$field_name = gsub("X([0-9]{1,2}\\.[0-9]+)$", "\\1%", m$field_name)
  
  log_model_result(mod_name_full, result_name, m)
  dbDisconnect(conn)
}
