package com.example.agentictemplate.ui

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import com.example.agentictemplate.diagnostics.BuildDiagnostics
import org.junit.Rule
import org.junit.Test

class MainScreenTest {
    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun rendersStatusAndBuildInfo() {
        composeRule.setContent {
            MainScreen(
                state = MainUiState(templateStatus = "READY"),
                diagnostics = BuildDiagnostics(
                    versionName = "0.1.0-qa",
                    versionCode = 1,
                    channel = "qa",
                    buildNumber = "123",
                    gitSha = "deadbeef",
                    gitState = "clean",
                    builtAtUtc = "2026-08-26T00:00:00Z",
                    signingMode = "persistent-qa",
                ),
            )
        }

        composeRule.onNodeWithText("Status: READY").assertIsDisplayed()
        composeRule.onNodeWithText("qa • 123").assertIsDisplayed()
        composeRule.onNodeWithText("Copy diagnostic info").assertIsDisplayed()
    }
}
