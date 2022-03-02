# Convert trivy JSON output to Reviewdog Diagnostic Format (rdjson)
{
  source: {
    name: "trivy",
    url: "https://github.com/aquasecurity/trivy"
  },
  "severity": (if .Results[0].Vulnerabilities|map(.Severity)|unique|contains(["CRITICAL"]) then
                "ERROR"
              elif .Results[0].Vulnerabilities|map(.Severity)|unique|contains(["HIGH"]) then
                "WARNING"
              elif .Results[0].Vulnerabilities|map(.Severity)|unique|contains(["MEDIUM"]) then
                "WARNING"
              else
                "INFO"
              end),
  diagnostics: .Results[0].Vulnerabilities | group_by(.VulnerabilityID) | map({
      VulnerabilityID: .[0].VulnerabilityID,
      PkgName: map(.PkgName) | unique,
      Title: map(.Title) | unique,
      Description: map(.Description) | unique,
      PrimaryURL: map(.PrimaryURL) | unique,
      InstalledVersion: map(.InstalledVersion) | unique,
      FixedVersion: map(.FixedVersion) | unique,
      Severity: map(.Severity) | unique}) | map({
    message: "\(.Title| join(",")). \(.Description| join(",") | .[0:100])... | PkgName: \(.PkgName| join(",")) | InstalledVersion: \(.InstalledVersion| join(",")) | FixedVersion: \(.FixedVersion| join(","))",
    code: {
      value: .VulnerabilityID,
      url: .PrimaryURL | join(","),
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
    severity: ( if .Severity[] == "CRITICAL" then
                  "ERROR"
                elif .Severity[] == "MEDIUM" or .Severity[] == "HIGH" then
                  "WARNING"
                else
                  "INFO"
                end)
  })
}
