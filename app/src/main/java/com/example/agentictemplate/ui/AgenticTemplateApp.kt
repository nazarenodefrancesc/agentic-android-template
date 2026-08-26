package com.example.agentictemplate.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.agentictemplate.diagnostics.BuildDiagnostics

@Composable
fun AgenticTemplateApp(viewModel: MainViewModel = viewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    MainScreen(state = state, diagnostics = BuildDiagnostics.current())
}

@Composable
fun MainScreen(
    state: MainUiState,
    diagnostics: BuildDiagnostics,
) {
    val clipboard = LocalClipboardManager.current
    Scaffold(
        topBar = { TopAppBar(title = { Text("Agentic Android Template") }) },
    ) { padding ->
        MainContent(
            padding = padding,
            state = state,
            diagnostics = diagnostics,
            onCopyDiagnostics = { clipboard.setText(AnnotatedString(diagnostics.asText())) },
        )
    }
}

@Composable
private fun MainContent(
    padding: PaddingValues,
    state: MainUiState,
    diagnostics: BuildDiagnostics,
    onCopyDiagnostics: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(padding)
            .padding(20.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Golden skeleton", style = MaterialTheme.typography.headlineMedium)
        Text("Status: ${state.templateStatus}", style = MaterialTheme.typography.titleMedium)
        Text(state.architectureNote)

        Card {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                Text("Build info", style = MaterialTheme.typography.titleMedium)
                Text("${diagnostics.channel} • ${diagnostics.buildNumber}")
                Text("Git ${diagnostics.gitSha} (${diagnostics.gitState})")
                Text("Signing: ${diagnostics.signingMode}")
                Button(onClick = onCopyDiagnostics) {
                    Text("Copy diagnostic info")
                }
            }
        }

        Text(
            "This screen exists to prove the template can expose deterministic state and build provenance before product-specific UI replaces it.",
        )
    }
}
