
cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

project ("fxc_test")

set(FXC_TEST_DIR    ${CMAKE_CURRENT_SOURCE_DIR})
set(FXC_TEST_SRC_DIR    ${FXC_TEST_DIR}/src)
set(FXC_DIR    ${THIRD_PARTY_DIR}/fxc)
set(TARGET_NAME fxc_test)

message("FXC_TEST_DIR: ", ${FXC_TEST_DIR})

find_path(FXC_INCLUDE_DIR d3dcompiler.h)
find_library(FXC_LIBRARY d3dcompiler)

if(FXC_INCLUDE_DIR AND FXC_LIBRARY)
    message("I found FXC!!!")
else()
    message("Oh noooo! I found nothing!!!")
    set(FXC_INCLUDE_DIR ${FXC_DIR}/)
    set(FXC_LIBRARY ${FXC_DIR}/d3dcompiler.lib)
endif()

include_directories(${FXC_INCLUDE_DIR})
set(FXC_ALL_LIBRARIES ${FXC_ALL_LIBRARIES} ${FXC_LIBRARY})

message("FXC_INCLUDE_DIR", ${FXC_INCLUDE_DIR})
message("FXC_ALL_LIBRARIES", ${FXC_LIBRARY})

# Add source to this project's executable.
add_executable (${TARGET_NAME} "src/FxcShaderReflection.cpp" "include/FxcShaderReflection.h")

target_include_directories(
            ${TARGET_NAME}
            PUBLIC ${FXC_TEST_DIR}/include
                    ${FXC_INCLUDE_DIR}
        )

target_link_libraries(${TARGET_NAME} ${FXC_ALL_LIBRARIES})

