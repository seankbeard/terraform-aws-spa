package buildstagetests

import (
	. "github.com/Kiwibank/kb-go-modules/tfquality/types"
)

func getIgnoredDiagnostics() []Diagnostic {
	var ignoredDiagnostics []Diagnostic

	// ignoredDiagnostics = append(ignoredDiagnostics,
	// 	Diagnostic{
	// 		Severity: "warning",
	// 		Summary:  "Reference to undefined provider",
	// 		Detail: "There is no explicit declaration for local provider name \"aws\" in " +
	// 			"module.cip_business_owners_sso_permission_sets",
	// 		Range: DiagnosticsRange{
	// 			Filename: "sso_assignments.tf",
	// 		},
	// 	},
	// )
	return ignoredDiagnostics
}
