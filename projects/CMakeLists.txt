cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

include_directories(${SHADER_PARTY_DIR})

project(projects)

add_subdirectory(dxc_test)
add_subdirectory(fxc_test)