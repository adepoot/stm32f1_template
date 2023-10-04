# STM32 - Environment setup template

This project is a template for setting up a simple STM32 project environment, using `make`, `cmake` and `Docker`.

The original project files were generated using [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html).
Additional setup files were inspired by [this GitHub project](https://github.com/prtzl/stm32).

# Prerequisites

- [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html)
- [CMake](https://cmake.org/)
- [Make](https://www.gnu.org/software/make/)
- [Docker](https://www.docker.com/)
- [stlink-tools](https://github.com/stlink-org/stlink)
- (optional) [Dev Containers (VS Code extension)](https://code.visualstudio.com/docs/devcontainers/containers)
- (optional) [Cortex-Debug (VS Code extension)](https://github.com/Marus/cortex-debug)

# Project structure

```
bluepill_makefile-example
├── .devcontainer
|   ├── ...
├── .vscode
|   ├── ...
├── Core  (generated by STM32CubeMX)
|   ├── ...
├── Drivers  (generated by STM32CubeMX)
|   ├── ...
├── project
|   ├── ...
├── toolchain  (generated by STM32CubeMX)
|   ├── ...
├── .mxproject  (generated by STM32CubeMX)
├── .bluepill_makefile-example.ioc  (generated by STM32CubeMX)
├── CMakeLists.txt
├── Dockerfile
├── gcc-arm-none-eabi.cmake
├── Makefile
```

`.devcontainer`
contains the configuration for development using `Dev Containers`. More info can be found in the `Development` section.

`.vscode`
contains templates that can be used for building, developing, debugging ... the project. Copy-paste these files, adapt them to your workstation and remove the `template_` prefix.

`project`
contains the project's application files.

`CMakeLists.txt`
contains MCU specific information and needs to be adapted to your MCU.

`Dockerfile`
used to create the image which contains the necessary tools to build the project.

`gcc-arm-none-eabi.cmake`
contains info for compiler and linker, does not necessarily need to be changed.

`Makefile`
contains different commands to build and flash the project.


# Development

There are two possibilities for development: local development on your own workstation or using `Dev Containers` provided as an extension by `Visual Studio Code`.

Local development on your own workstation requires you to have the necessary compilers, linkers ... installed locally on your workstation.
In some cases, you might not want to install the complete toolchain and other building tools on your workstation, in order to keep it as clean as possible.

In that case, you can use the `Dev Containers` extension from `VS Code`. This tool lets you develop using `VS Code` inside a container.
This has the advantage that your toolchain and other building tools only need to be installed inside that container and not on your own workstation.
It also has the advantage that Intellisense can look up files inside this container, including the header files that weren't installed on your workstation, which makes development for your chosen architecture much easier.

To open the project using `Dev Containers`, open the Command Palette and choose `Dev Containers: Reopen in Container`.
This will build the container, open a new `VS Code` project inside this container, install the necessary `VS Code` extensions and copy the `.devcontainer/c_cpp_properties.json` to the `.vscode` folder.

# Building

In order for the build-process to be independent from one workstation to the other, a Docker container is used to build the application.

The `Makefile` contains all the possible build steps.

The most important/used ones are listed here.

---

```
make
```
`make`, or `make build`, executes the default `build` goal. This will check whether the command is being ran in a container or not.
If it is running in a container, it will execute the goal `build-local` and use the local tools to compile and link the application.
If it is running on your workstation, it will execute the goal `build-via-container` and use a Docker container to build your application.

---

```
make build-local
```
build the application and puts the output inside the `build` folder.
This requires the `arm-none-eabi` tools (compilers, linkers ...) to be installed locally on your workstation.

---

```
make build-via-container
```
uses a Docker container to build the application. The output of this build process is put in the `build` folder of your workstation.

---

```
make shell
```
creates the Docker image, spins up a container and lets you enter the container. This container contains the necessary tools (compilers, linkers ...) to build the application.

---

```
make format
```
formats the project code according to the `.clang-format` file. The project code is located in the `project` folder.

---

```
make clean
```
deletes the `build` folder.

```
make clean-all
```
deletes the `build` folder and removes the Docker container and image.

# Flashing

For flashing the application to your device, a `make` goal has been added.

```
make flash
```
builds and flashed the built `.bin` file to the device using the `st-flash` command from [STLINK Tools](https://github.com/stlink-org/stlink).

For listing the connected programmers before flashing, you can use:
```
make discover
```

# Debugging

Three methods for debugging have been added to the [launch.json](.vscode/launch.json) VS Code configuration file:

1. Using the tools provided by the [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html)
2. Using [OpenOCD](https://openocd.org/)
3. Using [STLINK Tools](https://github.com/stlink-org/stlink)

All of these work in conjunction with the [Cortex-Debug extension](https://github.com/Marus/cortex-debug) in VS Code.

> DISCLAIMER: When using a counterfeit STM32 MCU, the first two options might not work. The third option, using STLINK Tools, should still work.

> NOTE: debugging has not yet been enabled from inside the Docker container. For debugging, the application will be built and launched from your local workstation.