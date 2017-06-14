load("./data/raw/rawdata.rdata")

n = nrow(rawdata)
ix = sample(n, .8*n)

train <- rawdata[ix,]
test  <- rawdata[-ix,]

save(train, file="./data/processed/train.rdata")
save(test, file="./data/processed/test.rdata")