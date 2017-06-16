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
  stat_func = statistics[[stat_name]]
  
  source(mod_funcs)
  load("data/processed/train.rdata")
  k = 200
  results = boot_stat(k, X, Y, train_model, stat_func)
  
  mod_name = basename(mod_funcs)
  
  fname = paste0("./data/bootstrap_",k,"_", mod_name, ".rdata")
  save(results, file = fname)
}
