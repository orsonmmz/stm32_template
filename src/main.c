#include "stm32f4xx_conf.h"

#ifdef NUCLEO_F401RE
    #define LED_RCC  RCC_AHB1Periph_GPIOA
    #define LED_PORT GPIOA
    #define LED_PIN  GPIO_Pin_5
#endif /* NUCLEO_F401RE */
#ifdef DISCOVERY_F407VG
    #define LED_RCC  RCC_AHB1Periph_GPIOD
    #define LED_PORT GPIOD
    #define LED_PIN  (GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15)
#endif /* DISCOVERY_F407VG */
#ifdef DIYMORE_F407VG
    #define LED_RCC  RCC_AHB1Periph_GPIOE
    #define LED_PORT GPIOE
    #define LED_PIN  (GPIO_Pin_0)
#endif /* DISCOVERY_F407VG */

int main(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;

    SystemCoreClockUpdate();
    RCC_AHB1PeriphClockCmd(LED_RCC, ENABLE);

    GPIO_InitStructure.GPIO_Pin = LED_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_2MHz;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
    GPIO_Init(LED_PORT, &GPIO_InitStructure);

    RCC_ClearFlag();
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);

    while(1) {
        GPIO_ToggleBits(LED_PORT, LED_PIN);
        for(int i = 0; i < 1048576; ++i) __NOP();
    }
}


#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{
    /* User can add his own implementation to report the file name and line number,
        ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

    /* Infinite loop */
    while (1);
}
#endif
