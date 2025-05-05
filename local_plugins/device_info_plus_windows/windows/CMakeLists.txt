cmake_minimum_required(VERSION 3.10)
project(device_info_plus_windows)

add_library(device_info_plus_windows SHARED
        device_info_plus_windows_plugin.cpp
        )

target_link_libraries(device_info_plus_windows flutter)
