/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vcam.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp_clk[1024];
        extern "C" int port_clk;
        extern "C" int temp_cam_enable[1024];
        extern "C" int port_cam_enable;
        extern "C" int temp_cam_data_in[1024];
        extern "C" int port_cam_data_in;
        extern "C" int temp_cam_hit_out[1024];
        extern "C" int port_cam_hit_out;
        extern "C" int temp_cam_addr_out[1024];
        extern "C" int port_cam_addr_out;
        extern "C" int foocam(int,int);
        
        void int2arrcam(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intcam(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foocam(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vcam* cam[1024];
            count--;
            if (init==0) 
            {
                cam[count]=new Vcam{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============cam : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("clk=%d\n", cam[count] ->clk);
				printf("cam_enable=%d\n", cam[count] ->cam_enable);
				printf("cam_data_in=%d\n", cam[count] ->cam_data_in);
				printf("cam_hit_out=%d\n", cam[count] ->cam_hit_out);
				printf("cam_addr_out=%d\n", cam[count] ->cam_addr_out);
				cam[count]->clk = arr2intcam(temp_clk, port_clk);
				cam[count]->cam_enable = arr2intcam(temp_cam_enable, port_cam_enable);
				cam[count]->cam_data_in = arr2intcam(temp_cam_data_in, port_cam_data_in);
				cam[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("clk=%d\n", cam[count] ->clk);
				printf("cam_enable=%d\n", cam[count] ->cam_enable);
				printf("cam_data_in=%d\n", cam[count] ->cam_data_in);
				printf("cam_hit_out=%d\n", cam[count] ->cam_hit_out);
				printf("cam_addr_out=%d\n", cam[count] ->cam_addr_out);
				int2arrcam(cam[count] -> cam_hit_out, temp_cam_hit_out, port_cam_hit_out);
				int2arrcam(cam[count] -> cam_addr_out, temp_cam_addr_out, port_cam_addr_out);

            }
            return 0;
        }