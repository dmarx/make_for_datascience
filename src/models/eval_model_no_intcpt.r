load("./models/simple_logistic.rdata")
load("./data/processed/test.rdata")

scored = predict(mod, newdata=test, type='response')
confusion <- table(test$Species, scored>.5)

#write.table(data.frame(confusion), file = "./reports/confusion_metrix.txt")
write.csv(confusion, file = "./reports/confusion_metrix_logreg_no_intcpt.txt")
