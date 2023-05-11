# MelonOS

# How to build

There are 2 ways to build this project.
The first way is building locally, which requires
the amd64-elf compiler to be in PATH. The second
way is through a dockerfile, which does this for you.

## 1. Using amd64-elf toolchain
Installing the toolchain is difficult,
and only works on Linux and MacOS, but compiling
is very simple. A guide on how to install the toolchain
is [here](https://wiki.osdev.org/GCC_Cross-Compiler).

To build with this method, simply execute
```
./build.sh
```
in the root folder. This will create the os.img file. 
Its that easy!

## 2. Using [docker](https://docs.docker.com/engine/install/)
This takes longer to compile, but is much simpler
to setup as it does all the toolchain hassle for you. 
The dockerfile included in the project will build
a debian container which will include the amd64-elf toolchain.

To build the container, run
```
docker build -t melonos-dev .   
```

Once built, you can compile with
```
./build-docker.sh
```
