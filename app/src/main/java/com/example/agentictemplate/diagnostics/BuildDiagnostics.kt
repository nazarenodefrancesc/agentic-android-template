package com.example.agentictemplate.diagnostics

import com.example.agentictemplate.BuildConfig

data class BuildDiagnostics(
    val versionName: String,
    val versionCode: Int,
    val channel: String,
    val buildNumber: String,
    val gitSha: String,
    val gitState: String,
    val builtAtUtc: String,
    val signingMode: String,
) {
    fun asText(): String = buildString {
        appendLine("App: Agentic Android Template")
        appendLine("Version: $versionName ($versionCode)")
        appendLine("Channel: $channel")
        appendLine("Build: $buildNumber")
        appendLine("Git: $gitSha [$gitState]")
        appendLine("Built: $builtAtUtc")
        append("Signing: $signingMode")
    }

    companion object {
        fun current() = BuildDiagnostics(
            versionName = BuildConfig.VERSION_NAME,
            versionCode = BuildConfig.VERSION_CODE,
            channel = BuildConfig.BUILD_CHANNEL,
            buildNumber = BuildConfig.BUILD_NUMBER,
            gitSha = BuildConfig.GIT_SHA,
            gitState = BuildConfig.GIT_STATE,
            builtAtUtc = BuildConfig.BUILD_TIME_UTC,
            signingMode = BuildConfig.SIGNING_MODE,
        )
    }
}
