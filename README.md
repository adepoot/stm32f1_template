# Bluepill - Makefile example

This project is an example of how to setup a simple STM32 project using `cmake`.
The original project files where generated using STM32CubeMX.

# Build

The project can be build using the following command, output will be put in the `build` folder:

```
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=gcc-arm-none-eabi.cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=true
```

In the `build`` folder:

```
make
```