include Makefile

.SUFFIXES:

LIST_OF_NODES := $(shell if test -f $(RW_FOLDER)/output/LIST_OF_NODES; then cat $(RW_FOLDER)/output/LIST_OF_NODES; fi)
listFile := $(RW_FOLDER)/output/SPEC_ABBREVS_FILES
PREQUISITE_VO_FILES := HOLLight.vo theory_hol.vo HOLLight.$(BASE)_types.vo $(BASE)_types.vo $(BASE)_type_abbrevs.vo $(BASE)_terms.vo $(BASE)_axioms.vo # $(BASE)_term_abbrevs.vo

.PHONY: spec_abbrevs.v
spec_abbrevs.v: $(LIST_OF_NODES:%=marg%)
	@echo list of nodes is
#	cat $(LIST_OF_NODES)

marg%:
	@echo Hello  $@
	ssh $@ 'bash $(MARGARET_HOME)/hol2dk/generate_on_remote.sh "$(MARGARET_HOME)" "$(listFile).$@"' 
#	touch $@.done

# This entry is executed by each slave node 
# where the SPEC_ABBREVS_FILES was exported by the make_specc_abbrevs_sharedFolder.sh script

.PHONY: spec
spec:
	echo $(PREQUISITE_VO_FILES)

.PHONY: spec_abbrevs_vo
spec_abbrevs_vo: $(SPEC_ABBREVS_FILES:%.v=%.vo)
ifeq ($(PROGRESS),1)
	rm -f .finished
	$(HOL2DK_DIR)/progress &
endif
ifneq ($(INCLUDE_VO_MK),1)
	$(MAKE) INCLUDE_VO_MK=1 vo
	touch .finished
endif

.PHONY: old_spec_abbrevs_vo
old_spec_abbrevs_vo: $(PREQUISITE_VO_FILES) $(SPEC_ABBREVS_FILES:%.v=%.vo)
	echo This is distributed.mk entry spec_abbrevs_vo 

%_spec.v:
	scp $(MASTER):$(RW_FOLDER)/$@ .

%_abbrevs%.v:
	scp $(MASTER):$(RW_FOLDER)/$@ .
