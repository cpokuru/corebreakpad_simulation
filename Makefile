# Makefile for RDK Minidump Generator with Breakpad Wrapper

CC = gcc
CFLAGS = -Wall -Wextra -g -O0
LDFLAGS = -lbreakpadwrapper

TARGET = crash_app
SRC = core_breakpad_wrapper.c
OBJ = $(SRC:.c=.o)

all: $(TARGET)
	@echo ""
	@echo "╔════════════════════════════════════════╗"
	@echo "║  Build Complete!                       ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
	@echo "Usage:"
	@echo "  ./$(TARGET)           - Interactive mode"
	@echo "  ./$(TARGET) <1-6>     - Specific crash type"
	@echo ""
	@echo "After crash:"
	@echo "  ls /minidumps/*.dmp   - Check minidump files"
	@echo ""

$(TARGET): $(OBJ)
	@echo "Linking $(TARGET) with libbreakpadwrapper..."
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ) $(LDFLAGS)

%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	@echo "Running crash app..."
	@./$(TARGET)

crash1: $(TARGET)
	@echo "Testing NULL pointer crash..."
	@./$(TARGET) 1

crash2: $(TARGET)
	@echo "Testing invalid memory access..."
	@./$(TARGET) 2

crash3: $(TARGET)
	@echo "Testing abort signal..."
	@./$(TARGET) 3

crash4: $(TARGET)
	@echo "Testing stack overflow..."
	@./$(TARGET) 4

crash5: $(TARGET)
	@echo "Testing divide by zero..."
	@./$(TARGET) 5

crash6: $(TARGET)
	@echo "Testing illegal instruction..."
	@./$(TARGET) 6

# Check for generated minidumps
check-dumps:
	@echo "╔════════════════════════════════════════╗"
	@echo "║  MINIDUMP FILES                        ║"
	@echo "╚════════════════════════════════════════╝"
	@ls -lhrt /minidumps/*.dmp 2>/dev/null || echo "No minidump files found in /minidumps/"
	@echo ""

# Watch the upload service logs in real-time
watch-upload:
	@echo "Watching coredump-upload service (Ctrl+C to stop)..."
	@journalctl -u coredump-upload.service -f

# Manually trigger the upload service
trigger-upload:
	@echo "Manually triggering coredump-upload service..."
	@systemctl start coredump-upload.service
	@sleep 2
	@systemctl status coredump-upload.service --no-pager

# Show recent upload activity
show-upload-logs:
	@echo "╔════════════════════════════════════════╗"
	@echo "║  RECENT UPLOAD SERVICE ACTIVITY        ║"
	@echo "╚════════════════════════════════════════╝"
	@journalctl -u coredump-upload.service --since "1 hour ago" --no-pager

# Full test: crash, check dump, trigger upload
full-test: $(TARGET)
	@echo "╔════════════════════════════════════════╗"
	@echo "║  FULL MINIDUMP TEST                    ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
	@echo "Step 1: Listing /minidumps before test..."
	@ls -lh /minidumps/ 2>/dev/null || echo "Empty or doesn't exist"
	@echo ""
	@echo "Step 2: Running crash test..."
	@./$(TARGET) 1 || true
	@sleep 1
	@echo ""
	@echo "Step 3: Checking for new minidump..."
	@ls -lhrt /minidumps/*.dmp 2>/dev/null | tail -3 || echo "No minidump generated!"
	@echo ""
	@echo "Step 4: Triggering upload service..."
	@systemctl start coredump-upload.service || echo "Cannot start service"
	@sleep 3
	@echo ""
	@echo "Step 5: Checking upload status..."
	@journalctl -u coredump-upload.service --since "1 minute ago" --no-pager | tail -20
	@echo ""
	@echo "Test complete!"

clean:
	@echo "Cleaning build files..."
	@rm -f $(OBJ) $(TARGET)
	@echo "Clean complete"

clean-all: clean
	@echo "Cleaning minidump files..."
	@rm -f /minidumps/*.dmp
	@echo "All clean"

help:
	@echo "RDK Minidump Generator - Makefile"
	@echo ""
	@echo "Build targets:"
	@echo "  make              - Build the application"
	@echo "  make clean        - Clean build files"
	@echo "  make clean-all    - Clean build files and minidumps"
	@echo ""
	@echo "Run targets:"
	@echo "  make run          - Run interactively"
	@echo "  make crash1       - NULL pointer crash"
	@echo "  make crash2       - Invalid memory access"
	@echo "  make crash3       - Abort signal"
	@echo "  make crash4       - Stack overflow"
	@echo "  make crash5       - Divide by zero"
	@echo "  make crash6       - Illegal instruction"
	@echo ""
	@echo "Check targets:"
	@echo "  make check-dumps      - List minidump files"
	@echo "  make show-upload-logs - Show recent upload activity"
	@echo "  make watch-upload     - Watch upload service live"
	@echo "  make trigger-upload   - Manually trigger upload"
	@echo ""
	@echo "Test targets:"
	@echo "  make full-test    - Complete test (crash + check + upload)"
	@echo ""

.PHONY: all clean clean-all run crash1 crash2 crash3 crash4 crash5 crash6 \
        check-dumps watch-upload trigger-upload show-upload-logs full-test hel
