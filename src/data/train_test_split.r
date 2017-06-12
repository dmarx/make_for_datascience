load("./data/raw/iris.rdata")

n = nrow(iris)
ix = sample(n, .9*n)

train <- iris[ix,]
test  <- iris[-ix,]

save(train, file="./data/processed/train.rdata")
save(test, file="./data/processed/test.rdata")