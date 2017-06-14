load("./data/raw/analyticBaseTable.rdata")

n = nrow(analyticBaseTable)
ix = sample(n, .8*n)

train <- analyticBaseTable[ix,]
test  <- analyticBaseTable[-ix,]

save(train, file="./data/processed/train.rdata")
save(test, file="./data/processed/test.rdata")