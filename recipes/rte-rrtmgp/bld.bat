@echo off
:: Stop on any error
setlocal ENABLEEXTENSIONS

set BUILD_TYPE=Debug
set RRTMGP_DATA_VERSION=v1.8.2
set FP_MODEL=DP
set RTE_CBOOL=ON
set ENABLE_TESTS=ON
set RTE_KERNELS=default
set FAILURE_THRESHOLD=7.e-4

set FCFLAGS="-ffree-line-length-none -m64 -std=f2008 -march=native -fbounds-check -fmodule-private -fimplicit-none -finit-real=nan -fbacktrace"

set "HOST=x86_64-w64-mingw32"
set "FC=%HOST%-gfortran.exe"

:: CMake configuration
mkdir build
cd build

:: Note: %CMAKE_ARGS% is automatically provided by conda-forge.
cmake %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -DCMAKE_Fortran_COMPILER=%FC% ^
      -DCMAKE_Fortran_FLAGS=%FCFLAGS% ^
      -DRRTMGP_DATA_VERSION=%RRTMGP_DATA_VERSION% ^
      -DPRECISION=%FP_MODEL% ^
      -DUSE_C_BOOL=%RTE_CBOOL% ^
      -DKERNEL_MODE=%RTE_KERNELS% ^
      -DENABLE_TESTS=%ENABLE_TESTS% ^
      -DFAILURE_THRESHOLD=%FAILURE_THRESHOLD% ^
      -G Ninja ..

:: Compile
cmake --build . -- -j%NUMBER_OF_PROCESSORS%

:: Run tests
ctest --output-on-failure --test-dir . -V

:: Manually copy libraries, binaries, and Fortran module files to %PREFIX%
xcopy /s /y rte-kernels\*.a %PREFIX%\lib\
xcopy /s /y rte-frontend\*.a %PREFIX%\lib\
xcopy /s /y rrtmgp-kernels\*.a %PREFIX%\lib\
xcopy /s /y rrtmgp-frontend\*.a %PREFIX%\lib\
xcopy /s /y modules\*.mod %PREFIX%\include\
