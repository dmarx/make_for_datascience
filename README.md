## Minimal demo of Gnu Make data analytics pipeline

To see a list of commands, run: 

    make

The makefile is designed to intelligently construct the modeling pipeline. 

My original intention was for this demo to be extremely minimalistic, but as I have expanded it to increasingly approximate and accomodate the complexity of a real data science project, it has spiraled into something of a self-contained system. I'm very pleased with the result, but it does require adhering to some project standards and utilizes a few fancy Make tricks to work properly, which has resulted in the Makefile being a bit less straightforward to someone who isn't steeped in make than I'd've liked. Someone building on this demo to use on their own project absolutely wouldn't be precluded from incorporating their own make rules, but one of my goals is to minimize the amount someone using this system would need to play with the makefile.

This is very much a work in progress, which is why there's basically no documentation on how it works. In the near future (i.e. after the system has stabilized a bit more and I'm satisfied that I've addressed all the use cases I'm targetting) I'll add documentation explaining both how to use this, how to expand on it, how it works, and lessons learned constructing this system.