{{- /*
  Takes a map of maps, turns it into a .gcfg (go configuration) file
  Useful for RStudio Connect and RStudio Package Manager
  i.e.
  { "Server" = {"Host" = "value", "another" = ["multiple", "values"]}}
  Valid values depend on the product
*/ -}}

{{- define "rstudio-library.config.gcfg" -}}
{{- range $section,$keys := . -}}
[{{ $section }}]
  {{- range $key, $val := $keys }}
    {{- if kindIs "slice" $val }}
      {{- range $eachval := $val }}
{{ $key }} = {{ $eachval }}
      {{- end }}
    {{- else }}
{{ $key }} = {{ $val }}
    {{- end }}
  {{- end }}

{{ end }}
{{- end -}}

{{- /*
  Takes a map of maps, turns each into a generic text file

  Config data is passed into `.data`
  A comment delimiter (used for keys) is passed as `.commentDelimiter`
*/ -}}
{{- define "rstudio-library.config.txt" -}}
{{- $commentDelim := .commentDelimiter | default "#" }}
{{- range $file, $keys := .data -}}
{{- printf "%s: |" $file | nindent 0 }}
{{- if kindIs "string" $keys }}
  {{- $keys | nindent 2 }}
{{- else }}
{{- range $parent, $child := $keys -}}
  {{- printf "%s %s" (toString $commentDelim) (toString $parent) | nindent 2 }}
  {{- printf "%s" (toString $child) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "rstudio-library.config.ini" -}}
{{- range $file, $keys := . -}}
{{- printf "%s: |" $file | nindent 0 }}
{{- if kindIs "string" $keys }}
  {{- $keys | nindent 2 }}
{{- else }}
{{- range $parent, $child := $keys -}}
  {{/* ini files may have multiple sections with the same name */}}
  {{- $sections := ( (kindIs "slice" $child) | ternary $child ( list $child ))}}
  {{- range $i, $section := $sections -}}
    {{- if kindIs "map" $section }}
      {{- if not ( kindIs "slice" $keys ) -}}
        {{- printf "[%s]" (toString $parent) | nindent 2 }}
      {{- end }}
      {{- range $key, $val := $section }}
        {{- printf "%s=%s" (toString $key) (toString $val) | nindent 2 }}
      {{- end }}
      {{- printf "" | nindent 0 }}
    {{- else }}
      {{- printf "%s=%s" (toString $parent) (toString $section) | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "rstudio-library.config.dcf" -}}
{{- range $file, $keys := $ -}}
  {{- printf "%s: |" $file | nindent 0 }}
  {{- if kindIs "string" $keys }}
    {{- $keys | nindent 2 }}
  {{- else }}
    {{- range $parent, $child := $keys -}}
      {{- if kindIs "map" $child }}
        {{- range $key, $val := $child }}
          {{- if kindIs "map" $val }}
            {{- printf "" | nindent 0 }}
            {{- printf "%s:" (toString $key) | nindent 2 }}
            {{- range $name, $el := $val }}
              {{- printf "%s=%s" (toString $name) (toString $el) | nindent 4 }}
            {{- end }}
          {{- else }}
            {{- printf "%s: %s" (toString $key) (toString $val) | nindent 2 }}
          {{- end }}
        {{- end }}
        {{- printf "" | nindent 0 }}
      {{- else }}
        {{- printf "%s: %s" (toString $parent) (toString $child) | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{ end }}

{{- define "rstudio-library.config.json" -}}
{{- range $file,$content := . }}
{{ $file }}: |
{{ $content | toPrettyJson | indent 2 }}
{{- end }}
{{- end -}}
