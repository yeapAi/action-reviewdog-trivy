# Convert trivy JSON output to Reviewdog Diagnostic Format (rdjson)
{
  source: {
    name: "trivy",
    url: "https://github.com/aquasecurity/trivy"
  },
  diagnostics: .[].Vulnerabilities | map({
    message: "\(.Title). PkgName \(.PkgName). \(.Description) InstalledVersion: \(.InstalledVersion) FixedVersion: \(.FixedVersion)",
    code: {
      value: .VulnerabilityID,
      url: .PrimaryURL,
    } ,
    location: {
      path: "Dockerfile",
      range: {
        start: {
          line: "1",
          column: "1"
        }
      }
    },
    severity: ( if .Severity == "CRITICAL" or .Severity == "HIGH" then
                  1
                elif .Severity == "MEDIUM" or .Severity == "LOW" then
                  2
                elif .Severity == "LOW" then
                  3
                else
                  null
                end),
    suggestion: {
      text: "PkgName \(.PkgName) FixedVersion: \(.FixedVersion)"
    }
  })
}
