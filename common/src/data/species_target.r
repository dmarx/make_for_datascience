species_target = read.csv("common/data/raw/iris_species.csv")

species_target$target = species_target$Species == 'versicolor'

save(species_target, file="common/data/processed/species_target.rdata")