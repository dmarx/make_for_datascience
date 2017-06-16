mod_path <- commandArgs(TRUE) # models/%.rdata

load(mod_path)
load("./data/processed/test.rdata")

# Get model's predict function
fname     = basename(mod_path)
stem      = strsplit(fname, '\\.rdata')[1]
mod_funcs = paste0("src/modeling/", stem, '.r')
source(mod_funcs)

scored = predict_model(mod, X, Y, type="class")
confusion <- table(Y, scored)

# Assume mod_path is of the form `models/mod_name.rdata`
mod_name = basename(mod_path)

fname = paste0("./reports/holdout_confusion_", mod_name, ".txt")
write.csv(confusion, file = fname)

