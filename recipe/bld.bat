
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

echo TBB_CXX_TYPE=gcc >> make\local
if errorlevel 1 exit 1

mingw32-make print-compiler-flags
if errorlevel 1 exit 1

mingw32-make clean-all
if errorlevel 1 exit 1

mingw32-make build -j%CPU_COUNT%
if errorlevel 1 exit 1
:: also compile threads header
mingw32-make build -j%CPU_COUNT% STAN_THREADS=TRUE
if errorlevel 1 exit 1

:: not read-only
attrib -R /S
if errorlevel 1 exit 1

copy stan\lib\stan_math\lib\tbb\tbb.dll ..
if errorlevel 1 exit 1
