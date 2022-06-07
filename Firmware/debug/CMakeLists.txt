cmake_minimum_required(VERSION 3.13)

project(ptunaDebug)

set(CMAKE_C_STANDARD 11)

# rest of your project

add_executable(ptunaDebug
	main.c
)

target_include_directories(ptunaDebug
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/../
)

target_link_libraries(ptunaDebug m)
