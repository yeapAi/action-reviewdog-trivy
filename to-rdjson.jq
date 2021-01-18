# Convert trivy JSON output to Reviewdog Diagnostic Format (rdjson)
{
  source: {
    name: "trivy",
    url: "https://github.com/aquasecurity/trivy"
  },
  "severity": (if .[].Vulnerabilities|map(.Severity)|unique|contains(["CRITICAL"]) then
                "ERROR"
              elif .[].Vulnerabilities|map(.Severity)|unique|contains(["HIGH"]) then
                "ERROR"
              elif .[].Vulnerabilities|map(.Severity)|unique|contains(["MEDIUM"]) then
                "WARNING"
              else
                "INFO"
              end),
  diagnostics: .[].Vulnerabilities | map({
    message: "\(.Title). \(.Description) | PkgName: \(.PkgName) | InstalledVersion: \(.InstalledVersion) | FixedVersion: \(.FixedVersion)",
    code: {
      value: .VulnerabilityID,
      url: .PrimaryURL,
    },
    location: {
      path: $file,
      range: {
        start: {
          line: "1",
          column: "1"
        }
      }
    },
    severity: ( if .Severity == "CRITICAL" or .Severity == "HIGH" then
                  "ERROR"
                elif .Severity == "MEDIUM" then
                  "WARNING"
                else
                  "INFO"
                end)
  })
}
