
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
for (fpath in list.files("reports", "holdout_confusion", full.names=TRUE, recursive=TRUE)){
  confmat = read.csv(fpath)
  
  m = as.matrix(confmat)[,-1]
  acc = sum(diag(m)) / sum(m)
  
  mod_name = modname_from_path(fpath, prefix="holdout_confusion_", suffix=".txt")
  
  accuracy[mod_name] = acc
}

all_acc = t(data.frame(accuracy))

colnames(all_acc) = "accuracy"

outpath = paste0(dirname(fpath), "all_models_accuracy.txt")
write.csv(all_acc, file = outpath)
