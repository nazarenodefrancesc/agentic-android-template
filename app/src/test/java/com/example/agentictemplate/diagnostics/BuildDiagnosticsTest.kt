package com.example.agentictemplate.diagnostics

import org.junit.Assert.assertTrue
import org.junit.Test

class BuildDiagnosticsTest {
    @Test
    fun diagnosticTextContainsProvenance() {
        val diagnostics = BuildDiagnostics(
            versionName = "1.2.3-qa",
            versionCode = 12,
            channel = "qa",
            buildNumber = "42",
            gitSha = "abc123",
            gitState = "clean",
            builtAtUtc = "2026-08-26T12:00:00Z",
            signingMode = "persistent-qa",
        )

        val text = diagnostics.asText()
        assertTrue(text.contains("Build: 42"))
        assertTrue(text.contains("Git: abc123 [clean]"))
        assertTrue(text.contains("Signing: persistent-qa"))
    }
}
