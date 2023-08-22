#include "project.h"
#include <stdio.h>
#include <main.h>

void print_helloworld() { printf("Hello World!\n"); }

void toggle_led() {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_10);
}