BUILDDIR ?= build
SRC := ads_fixed.vhd tb_ads_fixed.vhd
OBJ := $(SRC:%.vhd=$(BUILDDIR)/%.o)

TEST ?= tb_ads_sfixed

OPTS = --std=08 --work=ads
RUNOPTS = --wave=$(TEST).ghw

.PHONY: all clean

all: $(BUILDDIR)/$(TEST)

clean:
	-rm -rf $(BUILDDIR)

run: all
run:
	cd $(BUILDDIR) && ghdl run $(TEST) $(RUNOPTS)

$(BUILDDIR)/$(TEST): $(BUILDDIR) $(OBJ)
	cd $(BUILDDIR) && ghdl elaborate $(OPTS) $(TEST)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: %.vhd
	cd $(BUILDDIR) && ghdl analyze $(OPTS) ../$<

