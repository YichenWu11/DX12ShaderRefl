# CMakeList.txt : CMake project for ShaderReflection, include source and define
# project specific logic here.
#
cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

cmake_policy(SET CMP0054 NEW)

project ("ShaderReflection")

# Detect Linux
if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if (GGP)
    message("GGP platform")
elseif (LINUX)
    message("LINUX platform")
elseif (WIN32)
    message("WIN32 platform")
endif()

# ------------------------------------------------------------------------------
# Configure C++ flags
# ------------------------------------------------------------------------------
if(MSVC)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} /MP")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /Zc:__cplusplus /std:c++17")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
endif()

set(CMAKE_CXX_STANDARD 17)

set(ROOT_DIR    ${CMAKE_SOURCE_DIR})
set(THIRD_PARTY_DIR ${ROOT_DIR}/third_party)
set(SHADER_PARTY_DIR ${ROOT_DIR}/shaders)
set(LIBPORTO_DISABLE_SAMPLES ON)
# add_subdirectory(${THIRD_PARTY_DIR}/libporto)

set(ENABLE_DXVK   OFF CACHE BOOL "" FORCE)
set(ENABLE_DXIIVK OFF CACHE BOOL "" FORCE)

# target_compile_definitions(
#         porto
#         PUBLIC  LIBPORTO_EXPERIMENTAL_ENABLE_SPIRV_SHADERS
#     )

# target_compile_definitions(
#         porto_d3dcompiler
#         PUBLIC  LIBPORTO_EXPERIMENTAL_ENABLE_SHADER_REFLECTION
#     )

add_subdirectory(projects)
