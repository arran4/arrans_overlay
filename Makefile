.PHONY: \
	sim \
	run-sim \
	clean-sim \
	firmware \
	flash \
	monitor \
	flash-monitor \
	clean-firmware

SIM_BUILD_DIR := build/simulator
FIRMWARE_DIR := firmware

sim:
	cmake \
		-S simulator \
		-B $(SIM_BUILD_DIR) \
		-G Ninja
	cmake --build $(SIM_BUILD_DIR)

run-sim: sim
	./$(SIM_BUILD_DIR)/cyd-sim

clean-sim:
	rm -rf $(SIM_BUILD_DIR)

firmware:
	cd $(FIRMWARE_DIR) && idf.py set-target esp32
	cd $(FIRMWARE_DIR) && idf.py build

flash:
	cd $(FIRMWARE_DIR) && idf.py flash

monitor:
	cd $(FIRMWARE_DIR) && idf.py monitor

flash-monitor:
	cd $(FIRMWARE_DIR) && idf.py flash monitor

clean-firmware:
	cd $(FIRMWARE_DIR) && idf.py fullclean
