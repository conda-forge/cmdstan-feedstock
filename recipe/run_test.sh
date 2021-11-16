echo $CMDSTAN

cd $PREFIX/bin/cmdstan
# bernoulli example
make examples/bernoulli/bernoulli
./examples/bernoulli/bernoulli sample data file=examples/bernoulli/bernoulli.data.json
bin/stansummary output.csv

# bernoulli example
make examples/bernoulli/bernoulli STAN_THREADS=TRUE
./examples/bernoulli/bernoulli sample num_chains=2 data file=examples/bernoulli/bernoulli.data.json num_threads=2
bin/stansummary output_2.csv

# check binaries
bin/stanc --help
bin/stansummary --help

# python3 runCmdStanTests.py src/test/interface/
