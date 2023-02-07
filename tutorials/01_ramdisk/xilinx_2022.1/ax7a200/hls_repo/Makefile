################################################################################
# add HLS projects to SUBDIRS for being called recursively
################################################################################

SUBDIRS         := blink

.PHONY:         default build clean $(SUBDIRS)

default:        build

build:          COMMAND := build
build:          $(SUBDIRS)

clean:          COMMAND := clean
clean:          $(SUBDIRS)

$(SUBDIRS):
	make -C $@ $(COMMAND)
