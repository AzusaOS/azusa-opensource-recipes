#!/bin/sh
source "../../common/init.sh"

get https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${PV}.tar.gz "${P}.tar.gz"

models="tiny base small medium large-v1 large-v2 large-v3 large-v3-turbo"

for model in $models; do
	echo "Downloading $model"
	modelpath="${D}/pkg/main/${PKG}.data.${model}.${PVR}.any.any/model"
	mkdir -p "$modelpath"
	"${S}/models/download-ggml-model.sh" "$model" "$modelpath"
done

acheck

cd "${T}"

docmake

finalize
