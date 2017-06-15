mod_path <- commandArgs(TRUE)

load(mod_path)
load("./data/processed/test.rdata")

scored = predict(mod, newdata=test, type='response')
confusion <- table(test$Species, scored>.5)

# Assume mod_path is of the form `models/mod_name.rdata`
fname = basename(mod_path)
mod_name = strsplit(fname, '.rdata')[1]

fname = paste0("./reports/confusion_matrix_", mod_name, ".txt")
write.csv(confusion, file = fname)

