# Set working directory
export DIR=$PWD

# Create dist directories
mkdir -p dist
mkdir -p dist/include
mkdir -p dist/lib

# Set tool paths
SDK_PATH=$HOME/Android/Sdk
NDK_PATH=$SDK_PATH/ndk-bundle
CMAKE_EXECUTABLE=$SDK_PATH/cmake/3.10.2.4988404/bin/cmake
TOOLCHAIN_PATH=$NDK_PATH/build/cmake/android.toolchain.cmake

# Declare ABIs to build for
declare -a arr=( "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64" )

for ABI in "${arr[@]}"
do
	# Create ABI specific dirs
	mkdir -p build_${ABI}
	mkdir -p $DIR/dist/lib/${ABI}/

	cd build_${ABI}

	${CMAKE_EXECUTABLE} \
	-DCMAKE_INSTALL_PREFIX=install \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PATH} \
	-DCMAKE_BUILD_TYPE=Release \
	-DANDROID_NDK=${NDK_PATH} \
	-DANDROID_TOOLCHAIN=clang \
	-DANDROID_ABI=${ABI} \
	-DANDROID_NATIVE_API_LEVEL=android-28 \
	-DANDROID_STL=c++_shared \
	-DCMAKE_CXX_FLAGS="-frtti -fexceptions -std=c++11" \
	-DTHIRDPARTY=ON \
	-DCOMPILE_EXAMPLES=OFF \
	${DIR}

	make -j
	make install

	# Copy artifacts to dist folder
	cp install/lib/libfastrtps.so $DIR/dist/lib/${ABI}/
	cp external/install/lib/libfastcdr.so $DIR/dist/lib/${ABI}/

	# Move back to main directory
	cd $DIR
done

# Copy include folders
cp -r include/fastrtps dist/include
cp -r thirdparty/fastcdr/include/fastcdr dist/include

# Zip
FASTRTPS_HASH=$(git rev-parse --short HEAD)
zip -r libfastrtps_${FASTRTPS_HASH}.zip dist/*
