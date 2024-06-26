
:: activate/deactivate setup - cmd, pwsh, and bash
echo SET CMDSTAN=%PREFIX%\Library\bin\cmdstan\>> %RECIPE_DIR%\activate.bat
echo $Env:CMDSTAN="%PREFIX%\Library\bin\cmdstan">> %RECIPE_DIR%\activate.ps1
echo export CMDSTAN=%PREFIX%/Library/bin/cmdstan>> %RECIPE_DIR%\activate.sh
:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    copy %RECIPE_DIR%\%%F.ps1 %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.ps1
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)

:: we don't need test files
del /s /q ".\src\test"

echo d | Xcopy /s /e /y . %PREFIX%\Library\bin\cmdstan > NUL
if errorlevel 1 exit 1

cd %PREFIX%\Library\bin\cmdstan
if errorlevel 1 exit 1

set "fwd_slash_prefix=%PREFIX:\=/%"

echo "Setting up make\local"

echo CC=clang >> make\local
if errorlevel 1 exit 1
echo CXX=clang++ >> make\local
if errorlevel 1 exit 1
echo CXXFLAGS+=-D_REENTRANT -DBOOST_DISABLE_ASSERTS -D_BOOST_LGAMMA  >> make\local
if errorlevel 1 exit 1

echo "TBB"

:: TBB setup
echo TBB_CXX_TYPE=clang >> make\local
if errorlevel 1 exit 1
echo TBB_INTERFACE_NEW=true >> make\local
if errorlevel 1 exit 1
echo TBB_INC=%PREFIX:\=/%/Library/include/ >> make\local
if errorlevel 1 exit 1
echo TBB_LIB=%PREFIX:\=/%/Library/lib/ >> make\local
if errorlevel 1 exit 1

echo PRECOMPILED_HEADERS=false >> make\local
if errorlevel 1 exit 1

type make\local
if errorlevel 1 exit 1

make build -j1
if errorlevel 1 exit 1

::mingw32-make print-compiler-flags
::if errorlevel 1 exit 1

::mingw32-make clean-all
::if errorlevel 1 exit 1

echo "Attempting to build"

:: for now, just try to build bernoulli

clang++ -I %fwd_slash_prefix%/Library/include/ -I src -I stan/src -I stan/lib/rapidjson_1.1.0/ -I lib/CLI11-1.9.1/ -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.4.0 -I stan/lib/stan_math/lib/boost_1.78.0 -std=c++1y -O3 -D_REENTRANT -DBOOST_DISABLE_ASSERTS -D_BOOST_LGAMMA -DTBB_INTERFACE_NEW -Wno-sign-compare -Wno-deprecated-builtins -Wno-ignored-attributes -c -o src/cmdstan/main.o src/cmdstan/main.cpp

.\bin\stanc.exe  --o=examples/bernoulli/bernoulli.cpp examples/bernoulli/bernoulli.stan

clang++ -I %fwd_slash_prefix%/Library/include/ -I src -I stan/src -I stan/lib/rapidjson_1.1.0/ -I lib/CLI11-1.9.1/ -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.4.0 -I stan/lib/stan_math/lib/boost_1.78.0 -std=c++1y -O3 -D_REENTRANT -DBOOST_DISABLE_ASSERTS -D_BOOST_LGAMMA -DTBB_INTERFACE_NEW -Wno-sign-compare -Wno-deprecated-builtins -Wno-ignored-attributes -c -o examples/bernoulli/bernoulli.o examples/bernoulli/bernoulli.cpp


clang++ -I %fwd_slash_prefix%/Library/include/ -I src -I stan/src -I stan/lib/rapidjson_1.1.0/ -I lib/CLI11-1.9.1/ -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.4.0 -I stan/lib/stan_math/lib/boost_1.78.0 -std=c++1y -O3 -D_REENTRANT -DBOOST_DISABLE_ASSERTS -D_BOOST_LGAMMA -DTBB_INTERFACE_NEW -Wno-sign-compare -Wno-deprecated-builtins -Wno-ignored-attributes  examples/bernoulli/bernoulli.o src/cmdstan/main.o -Wl",/LIBPATH:%PREFIX%\Library\lib\" -ltbb -lsundials_nvecserial -lsundials_cvodes -lsundials_idas -lsundials_kinsol -o examples/bernoulli/bernoulli.exe


examples\bernoulli\bernoulli.exe sample data file=examples/bernoulli/bernoulli.data.json


::mingw32-make build -j%CPU_COUNT%
::if errorlevel 1 exit 1
:: also compile threads header
::mingw32-make build -j%CPU_COUNT% STAN_THREADS=TRUE
::if errorlevel 1 exit 1

:: not read-only
attrib -R /S
if errorlevel 1 exit 1
