mod_path <- commandArgs(TRUE) # models/%.rdata

load(mod_path) # gets pre-trained `mod`` object
load("./data/processed/test.rdata")

# Get model's predict function
mod_name     = basename(mod_path)
stem      = strsplit(mod_name, '\\.rdata')[1]
mod_funcs = paste0("src/modeling/models/", stem, '.r')
source(mod_funcs)

scored = predict_model(mod, X, Y, type="class")
confusion <- table(Y, scored)

# Assume mod_path is of the form `models/mod_name.rdata`
mod_name = basename(mod_path)

fname = paste0("./reports/holdout_confusion_", mod_name, ".txt")
write.csv(confusion, file = fname)

source("src/eval/eval_db/dbapi.r")

#m = prep_results(confusion)
m = data.frame(confusion)
m$row_id = 1:nrow(m)
m$field_name = paste0(m$Y, "_", m$scored)
m$value = m$Freq
m = m[,-c(1:3)]

log_model_result(mod_name, "holdout_confusion", m)
dbDisconnect(conn)