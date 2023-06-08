cmake_minimum_required(VERSION 3.13)

# initialize the SDK based on PICO_SDK_PATH
# note: this must happen before project()
include(pico_sdk_import.cmake)

project(ptuna)

set(CMAKE_C_STANDARD 11)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

add_library(pico_pdm_microphone INTERFACE)

target_sources(pico_pdm_microphone INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/src/pdm_microphone.c
    ${CMAKE_CURRENT_LIST_DIR}/src/OpenPDM2PCM/OpenPDMFilter.c
)

target_include_directories(pico_pdm_microphone INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/src/include
)

pico_generate_pio_header(pico_pdm_microphone ${CMAKE_CURRENT_LIST_DIR}/src/pdm_microphone.pio)

target_link_libraries(pico_pdm_microphone INTERFACE pico_stdlib pico_multicore hardware_dma hardware_pio)

add_library(kiss_fftr kiss/kiss_fftr.c)
add_library(kiss_fft kiss/kiss_fft.c)

target_link_libraries(kiss_fftr kiss_fft)

# rest of your project

add_executable(ptuna
	main.c ./libssd1306/ssd1306.c
)

target_include_directories(ptuna
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/../
)

target_link_libraries(ptuna pico_stdlib pico_multicore hardware_i2c pico_pdm_microphone kiss_fftr)

pico_enable_stdio_usb(ptuna 1)
pico_enable_stdio_uart(ptuna 0)

# create map/bin/hex/uf2 file in addition to ELF.
pico_add_extra_outputs(ptuna)
