## Demonstration of a fairly robust data science pipeline using Gnu Make

To see a list of commands, run: 

    make

The makefile is designed to intelligently construct the modeling pipeline. 

My original intention was for this demo to be extremely minimalistic, but as I have expanded it to increasingly approximate and accomodate the complexity of a real data science project, it has spiraled into something of a self-contained system. I'm very pleased with the result, but it does require adhering to some project standards and utilizes a few fancy Make tricks. Someone building on this demo to use on their own project absolutely wouldn't be precluded from incorporating their own make rules, but one of my goals is to minimize the amount someone using this system would need to play with the makefile.

This is very much a work in progress, which is why there's basically no documentation on how it works. In the near future I'll add documentation explaining how to use this, how to expand on it, how it works, and lessons learned constructing this system.

## Motivation


This system is motivated by specific (sometimes painful) experiences I've had collaborating with other people on projects. Here are a few of the situations I'm hoping to address:

* The team is experimenting with several models for a particular task and needs to evaluate them agains teach other for model selection.
* A structural change is made to one model but not others, and model evaluation needs to be refreshed. Only the results for that one model and any aggregate comparisons across all models for that task need to be refreshed.
* The client made a business decision that changes how we need to calculate a particular feature. All models that depend on this feature need to be updated.
* The team is working on several different modeling tasks that are all leveraging different overlapping subsets of some collection of features. If a change is made to how a feature is calculated or we get new raw data, the base tables and models in all tasks down stream of the updates need to be refreshed. 
* An analyst has joined the project late, or is picking it up after it hasn't been worked on for some time. It should be clear what the main entry point into the project is, which scripts generated which objects, which code is associated with experimental models vs. the model in production (if any are), and how to run a scoring sequence without retraining models or necessarily replacing the data that was used to train them.

## Fundamental principles

* The following are the entities we're concerned with in a data science pipeline:
  * Raw data getters
  * the raw data
  * features
  * analytic base tables
  * modeling tasks
  * models
  * model evaluation strategies 

* The following relationships exist between these entities:

  * data getters -> raw data : one to many
  * raw data -> features : many to many
  * features -> ABTs : many to many
  * ABTs -> to tasks : one to one (this might be contentious)
  * tasks -> models : one to many
  * models -> evaluations : many to many

## How it works at a high level
  
To address these relationships, the raw data is pulled into a "common" area. Features are also engineered in the common area as well. Each task is then characterized by the script that defines its ABT, a collection of model specifications (a spec defines two functions: one that trains a model, and one that generates scores), and choices about which evaluations to perform. The selected evaluations are performed on all models for a given task. Evaluation scripts are defined in the common area, so need only be linked to a task by pattern rules indicating which evaluations to run on all of that task's models. 

Default pattern rules are provided to capture the generalized components of the pipeline, which for the moment are all somewhat downstream: ABT-> models -> evaluations. I'd like to abstract out connecting features to ABTs in a similar way to how I've abstracted out linking models to ABTs (by just dropping model specs in a folder) but I haven't figured out a clean way to accomplish that yet.
