release=RELEASE_362
export GOPATH="/home/noch/go"

svn co https://llvm.org/svn/llvm-project/llvm/tags/$release/final $GOPATH/src/llvm.org/llvm

cd $GOPATH/src/llvm.org/llvm/bindings/go && ./build.sh
go install llvm.org/llvm/bindings/go/llvm
