@echo on
echo %CMDSTAN%

cd %PREFIX%\Library\bin\cmdstan
if errorlevel 1 exit 1


:: test binaries
bin\stanc.exe --help
if errorlevel 1 exit 1
bin\stansummary.exe --help
if errorlevel 1 exit 1

:: run bernoulli example
make examples/bernoulli/bernoulli.exe -d
if errorlevel 1 exit 1
examples\bernoulli\bernoulli.exe
examples\bernoulli\bernoulli.exe sample data file=examples/bernoulli/bernoulli.data.json
if errorlevel 1 exit 1
bin\stansummary.exe output.csv
if errorlevel 1 exit 1

del examples\bernoulli\bernoulli.exe
dir examples\bernoulli

:: run bernoulli example with parallelism
make examples/bernoulli/bernoulli.exe STAN_THREADS=TRUE
if errorlevel 1 exit 1
examples\bernoulli\bernoulli.exe
examples\bernoulli\bernoulli.exe sample num_chains=2 data file=examples/bernoulli/bernoulli.data.json num_threads=2
if errorlevel 1 exit 1
bin\stansummary.exe output_2.csv
if errorlevel 1 exit 1


