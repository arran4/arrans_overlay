cmake_minimum_required(VERSION 3.20)

project(cyd_simulator LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

find_package(PkgConfig REQUIRED)

pkg_check_modules(
	LVGL
	REQUIRED
	IMPORTED_TARGET
	lvgl>=9.5.0
)

add_executable(
	cyd-sim
	main.c
	../common/ui.c
)

target_include_directories(
	cyd-sim
	PRIVATE
	../common
)

target_link_libraries(
	cyd-sim
	PRIVATE
	PkgConfig::LVGL
)
