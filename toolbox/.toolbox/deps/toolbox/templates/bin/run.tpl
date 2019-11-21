#!/usr/bin/env bash

if [ "${TOOLBOX_DEBUG}" == "true" ]; then
  set -x
fi

{{ if has .task "env" -}}
{{- range $k, $v := .task.env -}}
{{- if $v }}
export {{ $k }}=${ {{- $k }}:-{{ $v }}}
{{ end -}}
{{ end -}}
export DOCKER_ENV_VARS="-e {{ $s := coll.Keys .task.env }}{{ join $s " -e " }}"
{{ end -}}

export TOOLBOX_TOOL_DIRS="toolbox,{{ $l := reverse .task.tool_dirs }}{{ join $l "," }}"

{{ if has .task "config_context_prefix" -}}
if [ -z "${VARIANT_CONFIG_CONTEXT-}" ]; then
export VARIANT_CONFIG_CONTEXT="{{ $l := reverse .task.config_context_prefix }}{{ join $l "," }}"
else
  export VARIANT_CONFIG_CONTEXT="${VARIANT_CONFIG_CONTEXT},{{ $l := reverse .task.config_context_prefix }}{{ join $l "," }}"
fi
{{ end -}}

export TOOLBOX_TOOL_DOCKER_IMAGE=${TOOLBOX_TOOL_DOCKER_IMAGE:-{{ .task.image }}}


eval "toolbox/.toolbox/deps/toolbox/run tools/{{ .task.cmd }} $*"

