/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vjtransmissiongate.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp_a[1024];
        extern "C" int port_a;
        extern "C" int temp_control[1024];
        extern "C" int port_control;
        extern "C" int temp_y[1024];
        extern "C" int port_y;
        extern "C" int foojtransmissiongate(int,int);
        
        void int2arrjtransmissiongate(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intjtransmissiongate(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foojtransmissiongate(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vjtransmissiongate* jtransmissiongate[1024];
            count--;
            if (init==0) 
            {
                jtransmissiongate[count]=new Vjtransmissiongate{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============jtransmissiongate : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("a=%d\n", jtransmissiongate[count] ->a);
				printf("control=%d\n", jtransmissiongate[count] ->control);
				printf("y=%d\n", jtransmissiongate[count] ->y);
				jtransmissiongate[count]->a = arr2intjtransmissiongate(temp_a, port_a);
				jtransmissiongate[count]->control = arr2intjtransmissiongate(temp_control, port_control);
				jtransmissiongate[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("a=%d\n", jtransmissiongate[count] ->a);
				printf("control=%d\n", jtransmissiongate[count] ->control);
				printf("y=%d\n", jtransmissiongate[count] ->y);
				int2arrjtransmissiongate(jtransmissiongate[count] -> y, temp_y, port_y);

            }
            return 0;
        }