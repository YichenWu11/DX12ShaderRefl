
cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

project ("dxc_test")

set(SR_DIR    ${CMAKE_CURRENT_SOURCE_DIR})
set(SRC_DIR    ${SR_DIR}/src)
set(DXC_DIR    ${THIRD_PARTY_DIR}/dxc)
set(TARGET_NAME dxc_test)

message("SR_DIR: ", ${SR_DIR})

find_path(DXC_INCLUDE_DIR dxcapi.h d3d12shader.h)
find_library(DXC_LIBRARY dxcompiler)

if(DXC_INCLUDE_DIR AND DXC_LIBRARY)
    # you may need that if further action in your CMakeLists.txt depends
    # on detecting your library
    message("I found DXC!!!")
    #set(SIFTGPU_FOUND TRUE)

    # you may need that if you want to conditionally compile some parts
    # of your code depending on library availability
    #add_definitions(-DHAVE_LIBSIFTGPU=1)
else()
    message("Oh noooo! I found nothing!!!")
    set(DXC_INCLUDE_DIR ${DXC_DIR}/inc)
    set(DXC_LIBRARY ${DXC_DIR}/lib/x64/dxcompiler.lib)
endif()

include_directories(${DXC_INCLUDE_DIR})
set(ALL_LIBRARIES ${ALL_LIBRARIES} ${DXC_LIBRARY})

message("DXC_INCLUDE_DIR", ${DXC_INCLUDE_DIR})
message("ALL_LIBRARIES", ${DXC_LIBRARY})

#add_subdirectory(${DXC_DIR})

# Add source to this project's executable.
add_executable (${TARGET_NAME} "src/ShaderReflection.cpp" "include/ShaderReflection.h")

target_include_directories(
            ${TARGET_NAME}
            PUBLIC ${SR_DIR}/include
                    ${DXC_INCLUDE_DIR}
        )

target_link_libraries(${TARGET_NAME} ${ALL_LIBRARIES})

