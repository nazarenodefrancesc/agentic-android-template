package com.example.agentictemplate

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.agentictemplate.ui.AgenticTemplateApp
import com.example.agentictemplate.ui.theme.AgenticTemplateTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AgenticTemplateTheme {
                AgenticTemplateApp()
            }
        }
    }
}
