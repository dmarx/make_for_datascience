
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
for (fpath in list.files("reports", "confusion_matrix", full.names=TRUE)){
  confmat = read.csv(fpath)
  mod_name = modname_from_path(fpath, prefix="confusion_matrix_", suffix=".txt")
  acc = sum(confmat[,"TRUE."]) / sum(confmat[,-1])
  accuracy[mod_name] = acc
}

all_acc = t(data.frame(accuracy))

colnames(all_acc) = "accuracy"

write.csv(all_acc, file = "reports/all_models_accuracy.txt")
