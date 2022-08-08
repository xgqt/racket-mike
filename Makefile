MAKE            := make
RACKET          := racket
RACO            := raco
SCRIBBLE        := $(RACO) scribble

DO-DOCS         := --no-docs
INSTALL-FLAGS   := --auto --skip-installed $(DO-DOCS)
REMOVE-FLAGS    := --force --no-trash $(DO-DOCS)
DEPS-FLAGS      := --check-pkg-deps --unused-pkg-deps
SETUP-FLAGS     := --tidy --avoid-main $(DEPS-FLAGS)
TEST-FLAGS      := --heartbeat --no-run-if-absent --submodule test --table

all: clean compile

clean-pkg-%:
	find $(*) -type d -name 'compiled' -exec rm -dr {} +
compile-pkg-%:
	$(RACKET) -e "(require compiler/compiler setup/getinfo) (compile-directory-zos (path->complete-path \"$(*)\") (get-info/full \"$(*)/info.rkt\") #:skip-doc-sources? #t #:verbose #f)"
install-pkg-%:
	cd $(*) && $(RACO) pkg install $(INSTALL-FLAGS)
setup-pkg-%:
	$(RACO) setup $(SETUP-FLAGS) --pkgs $(*)
test-pkg-%:
	$(RACO) test $(TEST-FLAGS) --package $(*)
remove-pkg-%:
	$(RACO) pkg remove $(REMOVE-FLAGS) $(*)

clean: clean-pkg-mike

compile: compile-pkg-mike

install: install-pkg-mike

setup: setup-pkg-mike

test: test-pkg-mike

remove: remove-pkg-mike
