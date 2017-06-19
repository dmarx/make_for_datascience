data(iris)

rawdata = iris

# Let's pretend like we have a few datasets we need to merge
iris$Flower.Id = 1:nrow(iris)

#save(rawdata, file="data/raw/rawdata.rdata")

sepal_cols = paste("Sepal", c("Length", "Width"), sep=".")
petal_cols = paste("Petal", c("Length", "Width"), sep=".")

sepals = iris[,c("Flower.Id", sepal_cols)]
petals = iris[,c("Flower.Id", petal_cols)]
species = iris[,c("Flower.Id", "Species")]

write.csv(sepals,  file = "data/raw/iris_sepals.csv", row.names=FALSE)
write.csv(petals,  file = "data/raw/iris_petals.csv", row.names=FALSE)
write.csv(species, file = "data/raw/iris_species.csv", row.names=FALSE)
