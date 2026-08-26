package com.example.agentictemplate.ui

import androidx.lifecycle.ViewModel
import com.example.agentictemplate.domain.TemplateHealthUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class MainViewModel(
    healthUseCase: TemplateHealthUseCase = TemplateHealthUseCase(),
) : ViewModel() {
    private val _state = MutableStateFlow(
        MainUiState(templateStatus = healthUseCase().label),
    )
    val state: StateFlow<MainUiState> = _state.asStateFlow()
}
