apply_transformations = function(in_data, features, transformations){
  new_feats = rep("", length(features) * length(transformations))
  out_data = list()
  i = 1
  for(f in features){
    for(trans_name in names(transformations)){
      feat = paste0(f, "_", trans_name)
      trans = transformations[trans_name][[1]]
      out_data[feat] = list(trans(in_data[,f]))
      
      new_feats[i] = feat
      i = i + 1
    }
  }
  data.frame(out_data)
}
