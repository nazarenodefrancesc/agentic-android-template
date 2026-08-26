package com.example.agentictemplate.domain

import org.junit.Assert.assertEquals
import org.junit.Test

class TemplateHealthUseCaseTest {
    @Test
    fun returnsReady() {
        assertEquals("READY", TemplateHealthUseCase()().label)
    }
}
