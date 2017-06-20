
# Assume mod_path is of the form `models/mod_name.rdata`
modname_from_path = function(mod_path, suffix=".rdata", prefix=NULL){
  path_parts = strsplit(mod_path, "/")[[1]]
  fname = path_parts[[length(path_parts)]]
  mod_name = strsplit(fname, suffix)[[1]]
  if(!is.null(prefix)){
    name_parts = strsplit(mod_name, prefix)[[1]]
    mod_name = name_parts[[length(name_parts)]]
  }
  mod_name
}

accuracy=list()
fpaths = list.files("reports", "holdout_confusion", full.names=TRUE, recursive=TRUE)
tasks = gsub("reports/(task.*)/.*", "\\1", fpaths)
for(task in unique(tasks)) accuracy[[task]] = list()
for (i in 1:length(fpaths)){
  fpath = fpaths[i]
  task  = tasks[i]
  
  confmat = read.csv(fpath)
  
  m = as.matrix(confmat)[,-1]
  m = apply(m, 2, as.numeric)
  acc = sum(diag(m)) / sum(m)
  
  mod_name = modname_from_path(fpath, prefix="holdout_confusion_", suffix=".txt")
  
  accuracy[[task]][mod_name] = acc
}

for(task in unique(tasks)){
  task_acc = accuracy[[task]]
  
  all_task_acc = t(data.frame(task_acc))
  
  colnames(all_task_acc) = "accuracy"
  rownames(all_task_acc) = paste0(task, "/", rownames(all_task_acc))
  
  outpath = paste0("reports/", task, "/all_models_accuracy.txt")
  write.csv(all_task_acc, file = outpath)
}
