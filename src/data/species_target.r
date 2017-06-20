species_target = read.csv("data/raw/iris_species.csv")

species_target$target = species_target$Species == 'versicolor'

save(species_target, file="data/processed/species_target.rdata")