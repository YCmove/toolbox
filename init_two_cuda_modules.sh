#!/bin/bash

check_cuda_directory() {
    local cuda_version="$1"
    if [ ! -d "/usr/local/cuda-$cuda_version" ]; then
        echo "/usr/local/cuda-$cuda_version does not exist. Program terminated! Make sure you installed CUDA."
        exit 1
    else
        echo "/usr/local/cuda-$cuda_version found."
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <cuda_default_version> <cuda_another_version>"
    exit 1
fi

CUDADEFAULT="$1"
CUDAANOTHER="$2"

check_cuda_directory "$CUDADEFAULT"
check_cuda_directory "$CUDAANOTHER"

sudo mkdir -p /usr/share/modules/modulefiles/cuda

sudo rm /usr/share/modules/modulefiles/cuda/$CUDADEFAULT
sudo bash -c "cat << 'EOF' >> /usr/share/modules/modulefiles/cuda/$CUDADEFAULT
#%Module1.0
##
## cuda $CUDADEFAULT modulefile
##

proc ModulesHelp { } {
    global version
    
    puts stderr \"\tSets up environment for CUDA $CUDADEFAULT\n\"
}

module-whatis \"sets up environment for CUDA $CUDADEFAULT\"

if { [ is-loaded cuda/$CUDAANOTHER ] } {
module unload cuda/$CUDAANOTHER
}

set version $CUDADEFAULT
set root /usr/local/cuda-$CUDADEFAULT
setenv CUDA_HOME \$root

prepend-path PATH \$root/bin
prepend-path LD_LIBRARY_PATH \$root/extras/CUPTI/lib64
prepend-path LD_LIBRARY_PATH \$root/lib64
conflict cuda
EOF"

sudo rm /usr/share/modules/modulefiles/cuda/$CUDAANOTHER
sudo bash -c "cat << 'EOF' >> /usr/share/modules/modulefiles/cuda/$CUDAANOTHER
#%Module1.0
##
## cuda $CUDAANOTHER modulefile
##

proc ModulesHelp { } {
    global version
    
    puts stderr \"\tSets up environment for CUDA $CUDAANOTHER\n\"
}

module-whatis \"sets up environment for CUDA $CUDAANOTHER\"

if { [ is-loaded cuda/$CUDADEFAULT ] } {
module unload cuda/$CUDADEFAULT
}

set version $CUDADEFAULT
set root /usr/local/cuda-$CUDAANOTHER
setenv CUDA_HOME \$root

prepend-path PATH \$root/bin
prepend-path LD_LIBRARY_PATH \$root/extras/CUPTI/lib64
prepend-path LD_LIBRARY_PATH \$root/lib64
conflict cuda
EOF"

echo "Modulefiles created"

sudo rm /usr/share/modules/modulefiles/cuda.version
sudo bash -c "cat << EOF >> /usr/share/modules/modulefiles/cuda.version
#%Module
set ModulesVersion $CUDADEFAULT
EOF"

echo "Set up the default version cuda-$CUDADEFAULT"

. /usr/share/modules/init/profile.sh



echo "===== Aveiable modules ====="
module avail

echo "===== Load the default CUDA ====="
module load cuda/$CUDADEFAULT

echo "===== List current loaded CUDA modules ====="
module list

echo "===== Make sure all CUDA paths are correct ====="
echo "CUDA_HOME=$CUDA_HOME"
echo "PATH=$PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
