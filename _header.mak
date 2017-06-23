# Infer current directory from most recently included makefile's path
_MAKEFILES := $(filter-out _header.mak _footer.mak,$(MAKEFILE_LIST))
_MODULE := $(patsubst %/,%,$(dir $(word $(words $(_MAKEFILES)),$(_MAKEFILES))))
$(_MODULE)_OUTPUT := $(_OUTTOP)/$(_MODULE)

# Reset the eval metric for each modeling task. This way it can default to the
# value below, or be specified separately for a particular modeling task in that
# task's makefile

_EVAL_METRIC := accuracy