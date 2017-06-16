boot_sample = function(x){
  n = nrow(x)
  ix = sample(n, replace=TRUE)
  x[ix,]
}

boot_stat = function(k, x, y, fitModel, stat){
  results = rep(NULL, k)
  full_dat = cbind(y,x)
  for(i in 1:k){
    boot_dat = boot_sample(full_dat)
    xb = boot_dat[,2:(NCOL(x)+1)]
    yb = boot_dat[,1]
    results[i] = stat(fitModel(xb, yb))
  }
  results
}

accuracy = function(mod, X, Y=y){
  mean(Y == predict_model(mod, X, type="class") )
}

rsqrd = function(mod){
  summary(mod)$r.squared
}

# Add more stats later
statistics = list(accuracy = accuracy, 
             rsqrd=rsqrd)

args <- commandArgs(TRUE)
if(length(args)>0){
  mod_funcs = args[1]
  stat_name = args[2]
  stat = statistics[stat_name]
  
  
}
