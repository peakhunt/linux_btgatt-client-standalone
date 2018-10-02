include Rules.mk

#######################################
# list of source files
########################################
LIB_IO_DRIVER_SOURCES = \
src/btgatt-client.c \
src/uuid-helper.c

#######################################
C_DEFS  = -DHAVE_CONFIG_H

#######################################
# include and lib setup
#######################################
BLUEZ_DIR=/home/hawk/work/bluetooth/bluez-5.50

C_INCLUDES =                              \
-Isrc \
-I$(BLUEZ_DIR) \
-I$(BLUEZ_DIR)/src \
-I$(BLUEZ_DIR)/lib
 
LIBS =  -lbluetooth-internal -lshared-mainloop
LIBDIR =  -Llib

#######################################
# for verbose output
#######################################
# Prettify output
V = 0
ifeq ($V, 0)
  Q = @
  P = > /dev/null
else
  Q =
  P =
endif

#######################################
# build directory and target setup
#######################################
BUILD_DIR = build
TARGET    = btgatt-client

#######################################
# compile & link flags
#######################################
CFLAGS += -g $(C_DEFS) $(C_INCLUDES)

# Generate dependency information
CFLAGS += -MMD -MF .dep/$(*F).d

LDFLAGS +=  $(LIBDIR) $(LIBS) 

#######################################
# build target
#######################################
all: $(BUILD_DIR)/$(TARGET)

#######################################
# target source setup
#######################################
TARGET_SOURCES := $(LIB_IO_DRIVER_SOURCES)
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(TARGET_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(TARGET_SOURCES)))

#######################################
# C source build rule
#######################################
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "[CC]         $(notdir $<)"
	$Q$(CC) -c $(CFLAGS) $< -o $@

#######################################
# main target
#######################################
$(BUILD_DIR)/$(TARGET): $(OBJECTS) Makefile
	@echo "[LD]         $@"
	$Q$(CC) -o $@ $(OBJECTS) $(LIBDIR) $(LIBS)

$(BUILD_DIR):
	@echo "MKDIR          $(BUILD_DIR)"
	$Qmkdir $@

#######################################
# clean up
#######################################
clean:
	@echo "[CLEAN]          $(TARGET) $(BUILD_DIR) .dep"
	$Q-rm -fR .dep $(BUILD_DIR)
	$Q-rm -f test/*.o unit_test/*.o

#######################################
# dependencies
#######################################
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)
