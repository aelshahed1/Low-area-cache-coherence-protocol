#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"

int main()
{
    init_platform();

    unsigned int L1A_full,L1B_full,L2_full,enable_zynq;

    //order from RTL: read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter

    unsigned int L1A_RH,L1A_RM,L1A_WH,L1A_WM; //L1A cache statistics
    unsigned int L1B_RH,L1B_RM,L1B_WH,L1B_WM; //L1B cache statistics
    unsigned int L2_RH,L2_RM,L2_WH,L2_WM; //L2 cache statistics

    float L1A_hit_rate,L1B_hit_rate,L2_hit_rate;

    XGpio L1A,L1B,L2,sw; //gpio pointers

    XGpio_Initialize(&L1A, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_SetDataDirection(&L1A, 1, 1);

    XGpio_Initialize(&L1B, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_SetDataDirection(&L1B, 2, 1);

    XGpio_Initialize(&L2, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_SetDataDirection(&L2, 1, 1);

    XGpio_Initialize(&sw, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_SetDataDirection(&sw, 2, 1);

    print("Program Started ********************************************************\n\r");

    while(1){

    	enable_zynq = XGpio_DiscreteRead(&sw, 2);

    	//reading full statistics from RTL
    	L1A_full = XGpio_DiscreteRead(&L1A, 1);
    	L1B_full = XGpio_DiscreteRead(&L1B, 2);
    	L2_full = XGpio_DiscreteRead(&L2, 1);

    	L1A_RH = 0xFF000000 & L1A_full;
    	L1A_RH = L1A_RH >> 24;
    	L1A_RM = 0x00FF0000 & L1A_full;
    	L1A_RM = L1A_RM >> 16;
    	L1A_WH = 0x0000FF00 & L1A_full;
    	L1A_WH = L1A_WH >> 8;
    	L1A_WM = 0x000000FF & L1A_full;

    	L1A_hit_rate = (float)(L1A_RH+L1A_WH) / (L1A_RH+L1A_RM+L1A_WH+L1A_WM);

    	L1B_RH = 0xFF000000 & L1B_full;
    	L1B_RH = L1B_RH >> 24;
    	L1B_RM = 0x00FF0000 & L1B_full;
    	L1B_RM = L1B_RM >> 16;
    	L1B_WH = 0x0000FF00 & L1B_full;
    	L1B_WH = L1B_WH >> 8;
    	L1B_WM = 0x000000FF & L1B_full;

    	L1B_hit_rate = (float)(L1B_RH+L1B_WH) / (L1B_RH+L1B_RM+L1B_WH+L1B_WM);

    	L2_RH = 0xFF000000 & L2_full;
    	L2_RH = L2_RH >> 24;
    	L2_RM = 0x00FF0000 & L2_full;
    	L2_RM = L2_RM >> 16;
    	L2_WH = 0x0000FF00 & L2_full;
    	L2_WH = L2_WH >> 8;
    	L2_WM = 0x000000FF & L2_full;

    	L2_hit_rate = (float)(L2_RH+L2_WH) / (L2_RH+L2_RM+L2_WH+L2_WM);


    	if(enable_zynq){
    		printf("\n\n Results:    \n");
    		printf("***********************************************************\n");
    		printf("L1A full HEX word = %X,L1B full HEX word = %X,L2 full HEX word= %X,\n\n]n",L1A_full,L1B_full,L2_full);

    		printf("L1A Read Hit = %u, L1A Read Miss = %u, L1A Write Hit = %u , L1A Write Miss = %u\n",L1A_RH,L1A_RM,L1A_WH,L1A_WM);
    		printf("L1A hit rate = %.3f \n",L1A_hit_rate);
    		printf("L1B Read Hit = %u, L1B Read Miss = %u, L1B Write Hit = %u , L1B Write Miss = %u\n",L1B_RH,L1B_RM,L1B_WH,L1B_WM);
    		printf("L1B hit rate = %.3f \n",L1B_hit_rate);
    		printf("L2 Read Hit = %u, L2 Read Miss = %u, L2 Write Hit = %u , L2 Write Miss = %u\n",L2_RH,L2_RM,L2_WH,L2_WM);
    		printf("L2 hit rate = %.3f \n",L2_hit_rate);
    		//sleep(10);

    		break;
    	}else{
    		printf("program is still running\n");
    		sleep(1);
    	}


    }


    print("\n\n end of results\n\r");

    cleanup_platform();
    return 0;
}
