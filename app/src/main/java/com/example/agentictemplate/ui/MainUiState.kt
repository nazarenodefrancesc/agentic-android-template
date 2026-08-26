package com.example.agentictemplate.ui

data class MainUiState(
    val templateStatus: String = "Checking…",
    val architectureNote: String = "Domain logic is isolated from Android UI.",
)
