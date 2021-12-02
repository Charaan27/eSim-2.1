/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vlfsr.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp_enable[1024];
        extern "C" int port_enable;
        extern "C" int temp_clk[1024];
        extern "C" int port_clk;
        extern "C" int temp_reset[1024];
        extern "C" int port_reset;
        extern "C" int temp_out[1024];
        extern "C" int port_out;
        extern "C" int foolfsr(int,int);
        
        void int2arrlfsr(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intlfsr(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foolfsr(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vlfsr* lfsr[1024];
            count--;
            if (init==0) 
            {
                lfsr[count]=new Vlfsr{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============lfsr : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("enable=%d\n", lfsr[count] ->enable);
				printf("clk=%d\n", lfsr[count] ->clk);
				printf("reset=%d\n", lfsr[count] ->reset);
				printf("out=%d\n", lfsr[count] ->out);
				lfsr[count]->enable = arr2intlfsr(temp_enable, port_enable);
				lfsr[count]->clk = arr2intlfsr(temp_clk, port_clk);
				lfsr[count]->reset = arr2intlfsr(temp_reset, port_reset);
				lfsr[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("enable=%d\n", lfsr[count] ->enable);
				printf("clk=%d\n", lfsr[count] ->clk);
				printf("reset=%d\n", lfsr[count] ->reset);
				printf("out=%d\n", lfsr[count] ->out);
				int2arrlfsr(lfsr[count] -> out, temp_out, port_out);

            }
            return 0;
        }