package com.example.agentictemplate.domain

data class TemplateHealth(val label: String)

class TemplateHealthUseCase {
    operator fun invoke(): TemplateHealth = TemplateHealth(label = "READY")
}
