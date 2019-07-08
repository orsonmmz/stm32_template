PROJECT_NAME = template

#BOARD = NUCLEO_F401RE
#BOARD = DISCOVERY_F407VG
BOARD = DIYMORE_F407VG

PROJECT_SRC = src
STM_SRC = Drivers/STM32F4xx_StdPeriph_Driver/src/
OBJ_DIR = build

CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
GDB	= arm-none-eabi-gdb

vpath %.c $(PROJECT_SRC)
vpath %.c $(STM_SRC)

ifeq ($(BOARD),NUCLEO_F401RE)
    STARTUP = startup_stm32f401xe.s
    LD_SCRIPT = stm32f401re.ld
    FAMILY = STM32F401xx
    JTAG_IFACE = stlink-v2-1
endif
ifeq ($(BOARD),DISCOVERY_F407VG)
    STARTUP = startup_stm32f40_41xxx.s
    LD_SCRIPT = stm32f407vg.ld
    FAMILY = STM32F40_41xxx
    JTAG_IFACE = stlink-v2
endif
ifeq ($(BOARD),DIYMORE_F407VG)
    STARTUP = startup_stm32f40_41xxx.s
    LD_SCRIPT = stm32f407vg.ld
    FAMILY = STM32F40_41xxx
    JTAG_IFACE = jlink
endif

SRCS = main.c

SRCS += Device/$(STARTUP)

SRCS += stm32f4xx_it.c
SRCS += system_stm32f4xx.c

EXT_SRCS = stm32f4xx_gpio.c
EXT_SRCS += stm32f4xx_rcc.c
EXT_SRCS += stm32f4xx_syscfg.c
EXT_SRCS += misc.c

EXT_OBJ = $(addprefix $(OBJ_DIR)/, $(EXT_SRCS:.c=.o))

INC_DIRS  = src/
INC_DIRS += Drivers/STM32F4xx_StdPeriph_Driver/inc/
INC_DIRS += Drivers/CMSIS/Device/ST/STM32F4xx/Include/
INC_DIRS += Drivers/CMSIS/Include/

INCLUDE = $(addprefix -I,$(INC_DIRS))

DEFS = -D$(FAMILY) -DUSE_STDPERIPH_DRIVER -D$(BOARD)

CFLAGS += -ggdb -O0 -std=c99
CFLAGS += -mlittle-endian -mthumb -mthumb-interwork -mcpu=cortex-m4
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -fsingle-precision-constant
CFLAGS += -Wl,--gc-sections

WFLAGS += -Wall -Wextra -Warray-bounds -Wno-unused-parameter -Wno-unused-function
LFLAGS = -TDevice/$(LD_SCRIPT) -lm -lc -lnosys

# Create a directory for object files
$(shell mkdir $(OBJ_DIR) > /dev/null 2>&1)

.PHONY: all
all: $(PROJECT_NAME)

.PHONY: $(PROJECT_NAME)
$(PROJECT_NAME): $(PROJECT_NAME).elf

$(PROJECT_NAME).elf: $(SRCS) $(EXT_OBJ)
	$(CC) $(INCLUDE) $(DEFS) $(CFLAGS) $^ $(WFLAGS) $(LFLAGS) -o $@
	$(OBJCOPY) -O ihex $(PROJECT_NAME).elf   $(PROJECT_NAME).hex
	$(OBJCOPY) -O binary $(PROJECT_NAME).elf $(PROJECT_NAME).bin

$(OBJ_DIR)/%.o: %.c
	$(CC) -c -o $@ $(INCLUDE) $(DEFS) $(CFLAGS) $^

clean:
	rm -rf $(OBJ_DIR) $(PROJECT_NAME).elf $(PROJECT_NAME).hex $(PROJECT_NAME).bin

flash: $(PROJECT_NAME).elf
	openocd -f interface/$(JTAG_IFACE).cfg -f target/stm32f4x.cfg \
		-c "init; flash probe 0; program $^ 0 verify reset; exit"

debug_ocd: $(PROJECT_NAME).elf
	openocd -f interface/$(JTAG_IFACE).cfg -f target/stm32f4x.cfg -c "init"

debug_gdb: $(PROJECT_NAME).elf
	${GDB} -ex "target remote localhost:3333" -ex "monitor reset halt" $^
