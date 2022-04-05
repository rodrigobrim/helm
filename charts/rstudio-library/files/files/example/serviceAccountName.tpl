{{- define "example.serviceAccountNameFromScript" -}}
   {{- if eq .Job.user "cole" -}}
        service-account-cole
   {{- else -}}
        service-account-other
   {{- end -}}
{{- end -}}
