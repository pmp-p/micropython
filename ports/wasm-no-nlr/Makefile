include ../../py/mkenv.mk

QSTR_DEFS = qstrdefsport.h

include $(TOP)/py/py.mk

INC += -I.
INC += -I$(TOP)
INC += -I$(BUILD)


CFLAGS += -Wall -Werror $(INC) -std=gnu11 $(COPT)
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += $(CFLAGS_MOD)


ifdef EMSCRIPTEN
	#default debug options for browser debugger
	JSFLAGS ?= --source-map-base http://localhost:8000

	#Debugging/Optimization
	ifeq ($(DEBUG), 1)
		CFLAGS += -O0 -g4
	else
		CFLAGS += -Oz -g0 -DNDEBUG
	endif
	
	JSFLAGS += -s WASM=1
	JSFLAGS += --memory-init-file 0 --js-library library.js
	JSFLAGS += -s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']"
	JSFLAGS += -s EXPORTED_FUNCTIONS="['_mp_js_init', '_Py_NewInterpreter',\
 '_mp_js_do_str', '_mp_js_do_repl', '_mp_js_process_char',\
 '_mp_hal_get_interrupt_char', '_mp_keyboard_interrupt' ]"

	CC = emcc $(JSFLAGS)
	LD = emcc $(JSFLAGS)
	CPP = clang -E -undef -D__CPP__ -D__EMSCRIPTEN__ -U__STDC_VERSION__
	CPP += --sysroot $(EMSCRIPTEN)/system
	CPP += -include $(BUILD)/clang_predefs.h
	CPP += $(addprefix -isystem, $(shell env LC_ALL=C $(CC) $(CFLAGS_EXTRA) -E -x c++ /dev/null -v 2>&1 |sed -e '/^\#include <...>/,/^End of search/{ //!b };d'))
	
	#check if not using emscripten-upstream branch
	ifeq (,$(findstring upstream/bin, $(EMMAKEN_COMPILER)))
		JSFLAGS += -s "BINARYEN_TRAP_MODE='clamp'"
	else 
		CFLAGS += -D__WASM__=1
		CPP += -D__WASM__=1
		LDFLAGS += -Wl,--gc-sections
	endif  
	

else
	ifdef WASI
		CC += -D__WASM__ -D__WASI__
		CPP =$(CC) -D__CPP__ -E
	else
		ifdef CLANG
			CC=clang
			CPP=clang -D__CPP__ -E
		else
			CC = gcc
			CPP = gcc -D__CPP__ -E
		endif
	endif

	#Debugging/Optimization
	ifeq ($(DEBUG), 1)
		CFLAGS += -O0 -g3
	else
		CFLAGS += -O0 -g3 -DNDEBUG
	endif		

endif


SRC_LIB = $(addprefix lib/,\
	utils/interrupt_char.c \
	utils/stdout_helpers.c \
	utils/pyexec.c \
	mp-readline/readline.c \
	)

SRC_C = \
	main.c \
	mphalport.c \
	modutime.c \


SRC_C += $(SRC_MOD)

SRC_QSTR += $(BUILD)/clang_predefs.h $(SRC_C) $(SRC_LIB)

OBJ = $(PY_O) 
OBJ += $(addprefix $(BUILD)/, $(SRC_LIB:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(SRC_C:.c=.o))

$(BUILD)/clang_predefs.h:
	$(Q)mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CFLAGS_EXTRA) $(JSFLAGS) -E -x c /dev/null -dM > $@

# Create `clang_predefs.h` as soon as possible, using a Makefile trick


ifdef EMSCRIPTEN
Makefile: $(BUILD)/clang_predefs.h

all: $(BUILD)/micropython.js

$(BUILD)/micropython.js: $(OBJ) library.js wrapper.js
	$(ECHO) "LINK $(BUILD)/firmware.js"
	$(Q)emcc $(LDFLAGS) -o $(BUILD)/firmware.js $(OBJ) $(JSFLAGS)
	cat wrapper.js $(BUILD)/firmware.js > $@

min: $(BUILD)/micropython.js
	uglifyjs $< -c -o $(BUILD)/micropython.min.js

test: $(BUILD)/micropython.js $(TOP)/tests/run-tests
	$(eval DIRNAME=ports/$(notdir $(CURDIR)))
	cd $(TOP)/tests && MICROPY_CPYTHON3=python3 MICROPY_MICROPYTHON=../$(DIRNAME)/node_run.sh ./run-tests
else


ifdef WASI
all: $(BUILD)/micropython.wasm

$(BUILD)/micropython.wasm: $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $(OBJ)

else

test: 
	$(eval DIRNAME=ports/$(notdir $(CURDIR)))
	cd $(TOP)/tests &&\
 MICROPY_CPYTHON3=python3 MICROPY_MICROPYTHON=../$(DIRNAME)/node_run.sh ./run-tests-exp.sh
endif
endif


include $(TOP)/py/mkrules.mk


check:
	$(ECHO) "CC=[$(CC)]"	
	$(ECHO) "CPP=[$(CPP)]"
	$(ECHO) CXX=$(CXX)
	$(ECHO) AS=$(AS)
	$(ECHO) LD=$(LD)
	$(ECHO) OBJCOPY=$(OBJCOPY)
	$(ECHO) SIZE=$(SIZE)
	$(ECHO) STRIP=$(STRIP)
	$(ECHO) AR=$(AR)
#emscripten specifics
	$(ECHO) EMSDK=$(EMSDK)
	$(ECHO) UPSTREAM=$(UPSTREAM)	
	$(ECHO) EMSCRIPTEN=$(EMSCRIPTEN)
	$(ECHO) EMSDK_NODE=$(EMSDK_NODE)
	$(ECHO) EMSCRIPTEN_TOOLS=$(EMSCRIPTEN_TOOLS)
	$(ECHO) EM_CONFIG=$(EM_CONFIG)
	$(ECHO) EMMAKEN_COMPILER=$(EMMAKEN_COMPILER)
	$(ECHO) EMMAKEN_CFLAGS=$(EMMAKEN_CFLAGS)
	$(ECHO) EMCC_FORCE_STDLIBS=$(EMCC_FORCE_STDLIBS)
	$(ECHO) EM_CACHE=$(EM_CACHE)
	$(ECHO) EM_CONFIG=$(EM_CONFIG)
	$(ECHO) JSFLAGS=$(JSFLAGS)
	$(shell env|grep ^EM)
