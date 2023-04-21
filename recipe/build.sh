# don't need test files
rm -rf src/test

mkdir -p $PREFIX/bin
cp -r . $PREFIX/bin/cmdstan

cd $PREFIX/bin/cmdstan

# remove old libraries
rm -rf stan/lib/stan_math/lib/*

# TBB setup
echo "TBB_CXX_TYPE=${c_compiler}"  >> make/local
echo "TBB_INTERFACE_NEW=true" >> make/local
echo "TBB_INC=${PREFIX}/include/" >> make/local
echo "TBB_LIB=${PREFIX}/lib/" >> make/local

# Eigen setup
echo "EIGEN=${PREFIX}/include/eigen3/" >> make/local
# Boost setup
echo "BOOST=${PREFIX}/include/boost/" >> make/local

# SUNDIALS setup
echo "INC_SUNDIALS= -I ${PREFIX}/include/"  >> make/local
echo "LDFLAGS_SUNDIALS= -L ${PREFIX}/lib/" >> make/local
echo "LDLIBS_SUNDIALS= -lsundials_cvodes -lsundials_idas -lsundials_kinsol -lsundials_nvecserial" >> make/local
echo "SUNDIALS_TARGETS=" >> make/local

echo "PRECOMPILED_HEADERS=false" >> make/local

make print-compiler-flags

make clean-all

make build -j1
make build -j1 STAN_THREADS=TRUE

# set up an alias. see https://github.com/stan-dev/cmdstan/issues/1024
echo "#!/bin/bash" > "${PREFIX}/bin/cmdstan_model"
echo "fname=\${1%.stan}" >> "${PREFIX}/bin/cmdstan_model"
echo "make -C ${PREFIX}/bin/cmdstan \$(realpath --relative-to=${PREFIX}/bin/cmdstan \$fname) \"\${@:2}\"" >> "${PREFIX}/bin/cmdstan_model"
chmod +x "${PREFIX}/bin/cmdstan_model"

# activate script
echo "export CMDSTAN=${PREFIX}/bin/cmdstan" >> "${RECIPE_DIR}/activate.sh"
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
