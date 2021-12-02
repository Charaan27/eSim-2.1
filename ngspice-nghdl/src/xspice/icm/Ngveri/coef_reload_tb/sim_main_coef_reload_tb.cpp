/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vcoef_reload_tb.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp__file[1024];
        extern "C" int port__file;
        extern "C" int temp_fopen[1024];
        extern "C" int port_fopen;
        extern "C" int temp_coef_reload_input[1024];
        extern "C" int port_coef_reload_input;
        extern "C" int temp_txt[1024];
        extern "C" int port_txt;
        extern "C" int temp_r[1024];
        extern "C" int port_r;
        extern "C" int temp_d[1024];
        extern "C" int port_d;
        extern "C" int temp_din_int[1024];
        extern "C" int port_din_int;
        extern "C" int foocoef_reload_tb(int,int);
        
        void int2arrcoef_reload_tb(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intcoef_reload_tb(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foocoef_reload_tb(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vcoef_reload_tb* coef_reload_tb[1024];
            count--;
            if (init==0) 
            {
                coef_reload_tb[count]=new Vcoef_reload_tb{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============coef_reload_tb : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("_file=%d\n", coef_reload_tb[count] ->_file);
				printf("fopen=%d\n", coef_reload_tb[count] ->fopen);
				printf("coef_reload_input=%d\n", coef_reload_tb[count] ->coef_reload_input);
				printf("txt=%d\n", coef_reload_tb[count] ->txt);
				printf("r=%d\n", coef_reload_tb[count] ->r);
				printf("d=%d\n", coef_reload_tb[count] ->d);
				printf("din_int=%d\n", coef_reload_tb[count] ->din_int);
				coef_reload_tb[count]->_file = arr2intcoef_reload_tb(temp__file, port__file);
				coef_reload_tb[count]->fopen = arr2intcoef_reload_tb(temp_fopen, port_fopen);
				coef_reload_tb[count]->coef_reload_input = arr2intcoef_reload_tb(temp_coef_reload_input, port_coef_reload_input);
				coef_reload_tb[count]->txt = arr2intcoef_reload_tb(temp_txt, port_txt);
				coef_reload_tb[count]->r = arr2intcoef_reload_tb(temp_r, port_r);
				coef_reload_tb[count]->d = arr2intcoef_reload_tb(temp_d, port_d);
				coef_reload_tb[count]->din_int = arr2intcoef_reload_tb(temp_din_int, port_din_int);
				coef_reload_tb[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("_file=%d\n", coef_reload_tb[count] ->_file);
				printf("fopen=%d\n", coef_reload_tb[count] ->fopen);
				printf("coef_reload_input=%d\n", coef_reload_tb[count] ->coef_reload_input);
				printf("txt=%d\n", coef_reload_tb[count] ->txt);
				printf("r=%d\n", coef_reload_tb[count] ->r);
				printf("d=%d\n", coef_reload_tb[count] ->d);
				printf("din_int=%d\n", coef_reload_tb[count] ->din_int);

            }
            return 0;
        }