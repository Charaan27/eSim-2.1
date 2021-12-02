/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vuser_encoded.h"
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
        extern "C" int temp_data_in[1024];
        extern "C" int port_data_in;
        extern "C" int temp_reset[1024];
        extern "C" int port_reset;
        extern "C" int temp_data_out[1024];
        extern "C" int port_data_out;
        extern "C" int foouser_encoded(int,int);
        
        void int2arruser_encoded(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intuser_encoded(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foouser_encoded(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vuser_encoded* user_encoded[1024];
            count--;
            if (init==0) 
            {
                user_encoded[count]=new Vuser_encoded{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============user_encoded : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("clk=%d\n", user_encoded[count] ->clk);
				printf("data_in=%d\n", user_encoded[count] ->data_in);
				printf("reset=%d\n", user_encoded[count] ->reset);
				printf("data_out=%d\n", user_encoded[count] ->data_out);
				user_encoded[count]->clk = arr2intuser_encoded(temp_clk, port_clk);
				user_encoded[count]->data_in = arr2intuser_encoded(temp_data_in, port_data_in);
				user_encoded[count]->reset = arr2intuser_encoded(temp_reset, port_reset);
				user_encoded[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("clk=%d\n", user_encoded[count] ->clk);
				printf("data_in=%d\n", user_encoded[count] ->data_in);
				printf("reset=%d\n", user_encoded[count] ->reset);
				printf("data_out=%d\n", user_encoded[count] ->data_out);
				int2arruser_encoded(user_encoded[count] -> data_out, temp_data_out, port_data_out);

            }
            return 0;
        }