## Minimal demo of Gnu Make data analytics pipeline

To see a list of commands, run: 

    make

The makefile is designed to intelligently construct the modeling pipeline. 

It looks for instructions for how to build models in the src/models folder, 
assuming that a model is specified a .r file with the prefix "train_". So for 
instance, to train a logistic regression, we would create the script 
`src/models/train_logreg.r` whose last step is to write a model object 
matching the filename, i.e. `models/logreg.rdata`. A confusion matrix is then
generated for each model, and the confusion matrices are aggregated to report
individual model accuracies in a final report.

The make file is self-documenting: adding comments to the line above a target
will add a description of what that target does to the list of commands you get
when you just run `make` by itself.