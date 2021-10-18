mkdir -p $PREFIX/bin
cp -r . $PREFIX/bin/cmdstan

cd $PREFIX/bin/cmdstan

echo "TBB_CXX_TYPE=${c_compiler}"  >> make/local

make clean-all

make build -j${CPU_COUNT}

# delete precompiled header from build
rm stan/src/stan/model/model_header.hpp.gch

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
