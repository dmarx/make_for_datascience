# Scavenged from train_and_save_model.r to be consistent with how it gets called
outpath <- commandArgs(TRUE) ## task0/models/logreg.rdata

task_name = gsub("(task.*)/models/(.*\\.r)data","\\1", outpath) 
mod_name = gsub("(task.*)/models/(.*\\.r)data","\\2", outpath)



source("common/src/eval/eval_db/dbapi.r")

# Construct a folder path out of the model file's last-updated date

mtime = file.info(outpath)$mtime
arch_path = paste0(mtime,'_', mod_name)
arch_path = gsub("\\.", "_", gsub(":","-", gsub(" ", "_", arch_path)))
arch_path = paste0(task_name, "/models/archive/", arch_path)

dir.create(arch_path, showWarnings = FALSE, recursive=TRUE)

fpath = paste0(arch_path, '/', mod_name)
file.rename(from=outpath,  to=fpath)

# Add experiment metadata if we've evaluated this model before

qry= "
  select * 
  from experiments 
  where 1=1
  and task_name = ?
  and model_name = ?
  order by created_date desc, last_updated_date desc
  limit 1
"

exp_meta = suppressWarnings(dbGetPreparedQuery(conn, qry, bind.data=data.frame(task_name, mod_name)))

oldnames = names(exp_meta)
id_ix = which(oldnames=='id')
names(exp_meta)[id_ix] = 'experiment_id'

unix_date_to_string = function(date_str){
  if(!is.na(date_str)){
      date_str = as.character(as.POSIXct(date_str, origin='1970-1-1'))
  }
  date_str
}

nice_dates = sapply(exp_meta[,c("created_date", "last_updated_date")], 
                    unix_date_to_string) 

exp_meta[,c("created_date", "last_updated_date")] = nice_dates
exp_meta = t(exp_meta)

write.table(exp_meta, file=paste0(arch_path, '/metadata.txt'),
           col.names=FALSE, quote=FALSE, sep=':\t'
           )