echo %CMDSTAN%

cd %PREFIX%\Library\bin\cmdstan
:: run bernoulli example
mingw32-make examples/bernoulli/bernoulli.exe
if errorlevel 1 exit 1
examples\bernoulli\bernoulli.exe
examples\bernoulli\bernoulli.exe sample data file=examples/bernoulli/bernoulli.data.json
if errorlevel 1 exit 1
bin\stansummary.exe output.csv
if errorlevel 1 exit 1

:: run bernoulli example with parallelism
mingw32-make examples/bernoulli/bernoulli.exe STAN_THREADS=TRUE
if errorlevel 1 exit 1
examples\bernoulli\bernoulli.exe
examples\bernoulli\bernoulli.exe sample num_chains=2 data file=examples/bernoulli/bernoulli.data.json num_threads=2
if errorlevel 1 exit 1
bin\stansummary.exe output_2.csv
if errorlevel 1 exit 1


:: test binaries
bin\stanc.exe --help
if errorlevel 1 exit 1
bin\stansummary.exe --help
if errorlevel 1 exit 1
